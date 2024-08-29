#!/bin/bash

# Запрашиваем номер клиента
echo "Введите номер клиента (например, 1 для client1.conf):"
read CLIENT_NUMBER

# Переменные
CLIENT_CONFIG="/home/$USER/client${CLIENT_NUMBER}.conf"

echo "1. Обновляем пакеты..."
sudo apt update && sudo apt upgrade -y
echo "Пакеты обновлены."

echo "2. Устанавливаем WireGuard..."
sudo apt install -y wireguard
echo "WireGuard установлен."

# Проверяем наличие конфигурационного файла
if [ -f "$CLIENT_CONFIG" ]; then
    echo "3. Конфигурационный файл найден. Копируем его в /etc/wireguard/..."
    sudo cp "$CLIENT_CONFIG" /etc/wireguard/wg0.conf
else
    echo "Ошибка: Конфигурационный файл $CLIENT_CONFIG не найден."
    exit 1
fi

echo "4. Устанавливаем права доступа к конфигурационному файлу..."
sudo chmod 600 /etc/wireguard/wg0.conf
echo "Права доступа установлены."

echo "5. Активируем интерфейс WireGuard..."
sudo wg-quick up wg0
echo "Интерфейс WireGuard активирован."

echo "6. Проверяем статус соединения..."
sudo wg
sudo systemctl status wg-quick@wg0.service

echo "Клиент WireGuard успешно подключен."