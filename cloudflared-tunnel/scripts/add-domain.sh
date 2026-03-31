#!/usr/bin/env bash
set -euo pipefail

# Usage: ./add-domain.sh <subdomain> <service>
# Example: ./add-domain.sh myapp http://myapp:3000
#          ./add-domain.sh api http://10.0.0.10:8080

CF_TOKEN="Skm8UB17HGVNgcii0-Kf8Y6HdCV3nd0ziVK6FPxL"
ACCOUNT_ID="f56e957e3362e15677552c19512b0a83"
TUNNEL_ID="732dd4eb-efa5-4438-8d3f-5f6434602066"
ZONE_ID="69fa583c8a14f624d1201a17231fb0c1"
DOMAIN="sho.io.vn"

SUBDOMAIN="${1:-}"
SERVICE="${2:-}"

if [[ -z "$SUBDOMAIN" || -z "$SERVICE" ]]; then
  echo "Usage: $0 <subdomain> <service>"
  echo "  subdomain: e.g. myapp  → will create myapp.sho.io.vn"
  echo "  service:   e.g. http://myapp:3000 or http://localhost:3000"
  exit 1
fi

HOSTNAME="${SUBDOMAIN}.${DOMAIN}"

echo "→ Adding $HOSTNAME → $SERVICE"

# ── 1. Lấy tunnel config hiện tại ──────────────────────────────────────────
CONFIG=$(curl -sf "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_TOKEN")

# Kiểm tra đã có chưa
EXISTING=$(echo "$CONFIG" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ingress = d['result']['config']['ingress']
for r in ingress:
    if r.get('hostname') == '$HOSTNAME':
        print('EXISTS')
        break
" 2>/dev/null || true)

if [[ "$EXISTING" == "EXISTS" ]]; then
  echo "✗ $HOSTNAME đã tồn tại trong tunnel config"
  exit 1
fi

# ── 2. Build config mới (thêm rule trước catch-all) ────────────────────────
NEW_CONFIG=$(echo "$CONFIG" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ingress = d['result']['config']['ingress']
warp = d['result']['config'].get('warp-routing', {})

# Tách catch-all (rule cuối không có hostname)
catchall = [r for r in ingress if not r.get('hostname')]
rules = [r for r in ingress if r.get('hostname')]

# Thêm rule mới
rules.append({'hostname': '$HOSTNAME', 'service': '$SERVICE', 'originRequest': {}})

new_ingress = rules + catchall
print(json.dumps({'config': {'ingress': new_ingress, 'warp-routing': warp}}))
")

# ── 3. PUT tunnel config ────────────────────────────────────────────────────
RESULT=$(curl -sf -X PUT \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "$NEW_CONFIG")

if ! echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('success') else 1)"; then
  echo "✗ Cập nhật tunnel config thất bại:"
  echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('errors'))"
  exit 1
fi
echo "✓ Tunnel ingress updated"

# ── 4. Tạo DNS CNAME record ─────────────────────────────────────────────────
DNS_RESULT=$(curl -sf -X POST \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"CNAME\",\"name\":\"$HOSTNAME\",\"content\":\"$TUNNEL_ID.cfargotunnel.com\",\"proxied\":true}")

if ! echo "$DNS_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('success') else 1)"; then
  echo "✗ Tạo DNS record thất bại:"
  echo "$DNS_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('errors'))"
  exit 1
fi
echo "✓ DNS CNAME created"

echo ""
echo "🎉 Done! https://$HOSTNAME → $SERVICE"
