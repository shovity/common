sudo systemctl disable docker-supervisor
sudo systemctl stop docker-supervisor.service
sudo systemctl status docker-supervisor.service
sudo rm /etc/systemd/system/docker-supervisor.service