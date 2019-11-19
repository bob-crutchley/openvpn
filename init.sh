#! /bin/bash

# install openvpn & easy-rsa
sudo apt install -y openvpn easy-rsa

source vars.sh

sudo cp server.conf /etc/openvpn/server.conf
mkdir -p ~/.ovpn
sed "s/{{OVPN_PUBLIC_IP}}/$(curl ifconfig.me)/g" client.ovpn > ~/.ovpn/client.ovpn
sed "s/{{OVPN_PUBLIC_IP}}/$(curl ifconfig.me)/g" client.conf > ~/.ovpn/client.conf

# configure ca
make-cadir ca
cd ca

./clean-all
./build-ca --batch
./build-key-server --batch server 

# default client cert & key
./build-key --batch client
./build-dh

sudo cp keys/{ ca.crt server.crt server.key dh2048.pem } /etc/openvpn/server
cp keys/{ ca.crt client.crt client.key } ~/.ovpn

sudo systemctl start openvpn@server
