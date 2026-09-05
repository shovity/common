#!/usr/bin/env bash
sudo systemctl disable ttyd
sudo systemctl stop ttyd
sudo rm -f /etc/systemd/system/ttyd.service
sudo systemctl daemon-reload
