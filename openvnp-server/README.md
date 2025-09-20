# OpenVPN Server

```bash
yarn up
yarn down
```

## Setup

```bash
# Init
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://127.0.0.1
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# Create client
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full client1 nopass
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient client1 > client1.ovpn
```
