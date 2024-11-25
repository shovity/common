sudo cp ./docker-supervisor.service /etc/systemd/system/
sudo sed -i "s/{app_dir}/$(pwd | sed 's/[\/&]/\\&/g')/" /etc/systemd/system/docker-supervisor.service
sudo systemctl enable docker-supervisor
sudo systemctl start docker-supervisor.service
sudo systemctl status docker-supervisor.service