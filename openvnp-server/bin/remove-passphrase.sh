docker run --rm -it -v $PWD/data:/etc/openvpn kylemanna/openvpn \
  openssl rsa -in /etc/openvpn/pki/private/ca.key \
  -out /etc/openvpn/pki/private/ca.key.unencrypted

sudo mv ./data/pki/private/ca.key data/pki/private/ca.key.encrypted
sudo mv ./data/pki/private/ca.key.unencrypted data/pki/private/ca.key

echo "✅ Removed passphrase from CA key."