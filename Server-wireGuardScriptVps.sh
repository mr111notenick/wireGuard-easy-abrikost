#!/bin/bash

echo "1. Update packages..."
apt update && apt upgrade -y
echo "Packages was updated."

echo "2. Installing WireGuard..."
apt install -y wireguard
echo "WireGuard installed."

echo "3. Generation private and public keys..."
wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey
echo "Keys are generated and saved in /etc/wireguard/."

echo "4. Change mode on your server privateKey..."
chmod 600 /etc/wireguard/privatekey
echo "The mode is changed"

echo "5. Allow ip Version 4 forwarding on your server..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "Forwarding allowed."

echo "6. Get your ip adress ip Version 4. For clients..."
SERVER_IP=$(curl -4 -s ifconfig.me)
echo "Your IP: $SERVER_IP"

echo "7. Creating config file Wireguard wg0.conf..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/privatekey)
Address = 10.0.0.1/24
ListenPort = 51830
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

for i in {1..5}; do
    CLIENT_PRIV_KEY=$(wg genkey)
    CLIENT_PUB_KEY=$(echo $CLIENT_PRIV_KEY | wg pubkey)
    
    echo "[Peer]" >> /etc/wireguard/wg0.conf
    echo "PublicKey = $CLIENT_PUB_KEY" >> /etc/wireguard/wg0.conf
    echo "AllowedIPs = 10.0.0.$((i+1))/32" >> /etc/wireguard/wg0.conf
    
    echo "8. Create config file client $i..."
    cat <<EOC > /etc/wireguard/client$i.conf
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = 10.0.0.$((i+1))/32
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat /etc/wireguard/publickey)
Endpoint = $SERVER_IP:51830
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOC
    echo "File client$i.conf created."
done

echo "9. Enable WireGuard demon..."
systemctl enable wg-quick@wg0.service  
systemctl start wg-quick@wg0.service  
systemctl status wg-quick@wg0.service
echo "Demon WireGuard started that is the status."

echo "Server is avaliable! Take a nice day!"
