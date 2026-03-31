#!/usr/bin/env bash
set -euo pipefail

CF_TOKEN="Skm8UB17HGVNgcii0-Kf8Y6HdCV3nd0ziVK6FPxL"
ACCOUNT_ID="f56e957e3362e15677552c19512b0a83"
TUNNEL_ID="732dd4eb-efa5-4438-8d3f-5f6434602066"

curl -sf "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
  -H "Authorization: Bearer $CF_TOKEN" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ingress = d['result']['config']['ingress']
rules = [r for r in ingress if r.get('hostname')]
print('{:<35} {:<40}'.format('HOSTNAME', 'SERVICE'))
print('-' * 75)
for r in rules:
    print('{:<35} {:<40}'.format(r['hostname'], r['service']))
print('\n{} domain(s)'.format(len(rules)))
"
