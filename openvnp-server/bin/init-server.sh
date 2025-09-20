if [ -z "$1" ]; then
    echo "Error: Domain name argument is required"
    echo "Usage: $0 vpn.example.com"
    exit 1
fi

mkdir -p clients
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$1
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

echo "✅ Initialized server. $1"