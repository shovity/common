CLIENT=$1

if [ -z "$CLIENT" ]; then
  echo "❌ You must enter a client name: ./revoke-client.sh <client_name>"
  exit 1
fi

echo "👉 Revoking client certificate: $CLIENT"

# Revoke certificate
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa revoke $CLIENT

# Generate new CRL (Certificate Revocation List)
docker run -v $PWD/data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa gen-crl

# Copy CRL into OpenVPN configuration directory
docker run -v $PWD/data:/etc/openvpn --rm kylemanna/openvpn ovpn_copy_server_files

# Remove clients file
rm -f ./clients/$CLIENT.ovpn

# Restart container to apply CRL
docker compose restart openvpn

echo "✅ Client $CLIENT has been revoked!"
