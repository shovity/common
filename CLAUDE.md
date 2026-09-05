# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Infrastructure services repository chứa các Docker services dùng chung. Tất cả services chạy trên Docker network `backend` (external).

## Commands

```bash
# Mỗi service folder
yarn up      # docker compose up -d
yarn down    # docker compose down
```

## Service Scripts

### Backend Network (phải chạy trước mọi service)

```bash
./create-backend-network.sh   # idempotent: tạo network `backend` với subnet CỐ ĐỊNH
```

Subnet ghim cứng trong script — đừng tạo network bằng `docker network create backend`
trần, Docker sẽ tự cấp dải khác và làm hỏng rule ufw cho phép container gọi các
cổng publish trên host. Lý do đầy đủ ở đầu file script.

### Cloudflare Tunnel (Domain Management)

```bash
cloudflared-tunnel/scripts/add-domain.sh <subdomain> <service_url>
# Ví dụ: add-domain.sh api http://api:3000 → api.sho.io.vn

cloudflared-tunnel/scripts/remove-domain.sh <subdomain>
cloudflared-tunnel/scripts/list-domains.sh
```

### OpenVPN

```bash
openvnp-server/bin/create-client.sh <name>
openvnp-server/bin/remove-client.sh <name>
```

### Squid Proxy

```bash
squid-proxy/manage_users.sh add <user> <pass>
squid-proxy/manage_users.sh remove <user>
squid-proxy/manage_users.sh list
```

## Architecture

- **Network**: Tất cả services join `backend` network (external, phải tạo trước)
- **Routing**: Traefik auto-discover containers, route theo labels
- **Domain**: `sho.io.vn` qua Cloudflare Tunnel → Traefik → services
- **Image proxy**: Nginx gateway resize/cache images từ MinIO

## Service Pattern

Mỗi service folder chứa:

```
service-name/
├── compose.yaml
├── package.json        # scripts: up, down
├── .env               # secrets (gitignored)
├── .env.example       # template
└── data/              # volumes (gitignored)
```

Naming convention: `<name>-<type>/` với type: `database`, `gateway`, `monitor`, `logging`, `util`, `server`, `proxy`

## Docker Compose Conventions

```yaml
services:
  name:
    restart: unless-stopped
    networks:
      - backend
    logging:
      options:
        max-size: 5m

networks:
  backend:
    name: backend
    external: true
```

## Khi Tạo Service Mới

1. Tạo folder theo pattern `<name>-<type>/`
2. Copy compose.yaml từ service tương tự
3. Tạo package.json với scripts up/down
4. Tạo .env.example với tất cả required vars
5. Join network `backend`, set logging max-size: 5m
6. Nếu cần expose public: dùng `cloudflared-tunnel/scripts/add-domain.sh`
