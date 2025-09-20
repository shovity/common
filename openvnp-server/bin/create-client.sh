docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full "$1" nopass
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $1 > ./clients/$1.ovpn