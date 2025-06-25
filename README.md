# Open common services

Preset docker compose

## Usage

_Remember make `.env` before run `docker compose up`_

```bash
cd mongodb-database
yarn up # docker compose up -d
```

## Snippets

```bash
# Backup
sudo tar --numeric-owner -cpvzf common-and-services.tar.gz --exclude='*/node_modules' common services

# Restore
sudo tar --numeric-owner -xpvzf common-and-services.tar.gz
```
