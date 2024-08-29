#!/bin/bash

echo "1. Обновляем пакеты..."
apt update && apt upgrade -y
echo "Пакеты обновлены."

echo "2. Устанавливаем WireGuard..."
apt install -y wireguard
echo "WireGuard установлен."

echo "3. Генерация приватного и публичного ключей сервера..."
wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey
echo "Ключи сервера сгенерированы."

echo "4. Меняем доступ к приватному ключу..."
chmod 600 /etc/wireguard/privatekey
echo "Доступ к приватному ключу изменен."

echo "5. Разрешаем переадресацию IP на сервере..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "Переадресация IP разрешена."

echo "6. Получаем внешний IPv4-адрес сервера..."
SERVER_IP=$(curl -4 -s ifconfig.me)
echo "Внешний IPv4-адрес сервера: $SERVER_IP"

echo "7. Создаем конфигурационный файл wg0.conf..."
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
    
    echo "8. Создаем конфигурационный файл клиента $i..."
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
    echo "Файл client$i.conf создан."
done

echo "9. Включаем и запускаем сервис WireGuard..."
systemctl enable wg-quick@wg0.service  
systemctl start wg-quick@wg0.service  
systemctl status wg-quick@wg0.service
echo "Сервис WireGuard запущен."

echo "Настройка завершена!"
