#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env
command -v ttyd >/dev/null || { echo "Cài ttyd..."; sudo apt-get install -y ttyd; }
sudo cp ./ttyd.service /etc/systemd/system/
sudo sed -i "s/{app_dir}/$(pwd | sed 's/[\/&]/\\&/g')/; s/{user}/$(whoami)/" /etc/systemd/system/ttyd.service
sudo systemctl daemon-reload
sudo systemctl enable ttyd
sudo systemctl restart ttyd
sudo systemctl status ttyd --no-pager
