# wireGuard-easy-abrikost
I am trying to develop the simplest installation process WireGuard on VPS Server only Ubuntu support.
### Comming soon
  Arch linux support
  Web-version like wg-easy(with support QR-code and Web-donload)



Getting Start.
1) Download the script on your server
2) Change mode executable
```bash
sudo chmod +x wireGuard-easy-abrikost.sh
```
3) All done. 5 Client already created. The config files in the /etc/wireguard/. Named client1...client5 on your Server
```bash
sudo cd /etc/wireguard
```
4) You can copy the text in the client*.conf like this.
```bash
cat client1.conf
```
5) Or you can download config from you server. 
```bash
#ubuntu client installation
scp YourUserName@your.ip.adress:/etc/wireguard/client1 /home/$USER/
#
#if you have Windows client use this. You will save the client1.conf directly in disk C.
scp YourUserName@your.ip.adress:/etc/wireguard/client1 C:\
```
On windows you need 
- Download wireguard app client. 
  Here
https://download.wireguard.com/windows-client/
- After install click on the button "Add Tunnel"
- Select client1.conf on your disk C:\
- Click Activate
