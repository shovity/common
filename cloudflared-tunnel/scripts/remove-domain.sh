#!/usr/bin/env bash
set -euo pipefail

# Usage: ./remove-domain.sh <subdomain>
# Example: ./remove-domain.sh myapp

CF_TOKEN="Skm8UB17HGVNgcii0-Kf8Y6HdCV3nd0ziVK6FPxL"
ACCOUNT_ID="f56e957e3362e15677552c19512b0a83"
TUNNEL_ID="732dd4eb-efa5-4438-8d3f-5f6434602066"
ZONE_ID="69fa583c8a14f624d1201a17231fb0c1"
DOMAIN="sho.io.vn"

SUBDOMAIN="${1:-}"

if [[ -z "$SUBDOMAIN" ]]; then
  echo "Usage: $0 <subdomain>"
  exit 1
fi

HOSTNAME="${SUBDOMAIN}.${DOMAIN}"
echo "→ Removing $HOSTNAME"

# ── 1. Cập nhật tunnel config ───────────────────────────────────────────────
CONFIG=$(curl -sf "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_TOKEN")

NEW_CONFIG=$(echo "$CONFIG" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ingress = d['result']['config']['ingress']
warp = d['result']['config'].get('warp-routing', {})
new_ingress = [r for r in ingress if r.get('hostname') != '$HOSTNAME']
if len(new_ingress) == len(ingress):
    print('NOT_FOUND')
    sys.exit(0)
print(json.dumps({'config': {'ingress': new_ingress, 'warp-routing': warp}}))
")

if [[ "$NEW_CONFIG" == "NOT_FOUND" ]]; then
  echo "✗ $HOSTNAME không tồn tại trong tunnel config"
  exit 1
fi

curl -sf -X PUT \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "$NEW_CONFIG" | python3 -c "import sys,json; d=json.load(sys.stdin); print('✓ Tunnel ingress updated' if d.get('success') else '✗ Failed: ' + str(d.get('errors')))"

# ── 2. Xóa DNS record ───────────────────────────────────────────────────────
RECORD_ID=$(curl -sf "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$HOSTNAME" \
  -H "Authorization: Bearer $CF_TOKEN" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d['result'][0]['id'] if d.get('result') else '')")

if [[ -n "$RECORD_ID" ]]; then
  curl -sf -X DELETE \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_TOKEN" | python3 -c "import sys,json; d=json.load(sys.stdin); print('✓ DNS record deleted' if d.get('success') else '✗ DNS delete failed: ' + str(d.get('errors')))"
else
  echo "⚠ DNS record không tìm thấy, bỏ qua"
fi

echo ""
echo "🗑  Done! $HOSTNAME removed"
