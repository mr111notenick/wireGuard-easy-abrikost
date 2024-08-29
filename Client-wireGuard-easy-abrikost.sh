#!/bin/bash

# Ask clients number
echo "What number of client (for example, 1 for client1.conf):"
read CLIENT_NUMBER

# Variable
CLIENT_CONFIG="/home/$USER/client${CLIENT_NUMBER}.conf"

echo "1. Update Packeges..."
sudo apt update && sudo apt upgrade -y
echo "Pakeges updated."

echo "2. Install WireGuard..."
sudo apt install -y wireguard
echo "WireGuard installed."

# Check config wile in /home/$USER
if [ -f "$CLIENT_CONFIG" ]; then
    echo "3. Config file was detected. We are copy this file in /etc/wireguard/..."
    sudo cp "$CLIENT_CONFIG" /etc/wireguard/wg0.conf
else
    echo "Error. Config file $CLIENT_CONFIG not detected."
    exit 1
fi

echo "4. Change mode for more secure for wireguard config..."
sudo chmod 600 /etc/wireguard/wg0.conf
echo "Mode was changed."

echo "5. Activating WireGuard interface..."
sudo wg-quick up wg0
echo "Interface wg0 was activated."

echo "6. If the client avaliable?..."
sudo wg
sudo systemctl status wg-quick@wg0.service

echo "Client WireGuard was successfully connected. Take a nice day"
