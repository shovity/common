mkdir -p clients
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$1
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki