#!/bin/bash

##Installing OpenVPN and Easy-RSA
apt update -y 
apt install openvpn easy-rsa -y

###Creating a PKI (private key and certificate) for OpenVPN
ln -s /usr/share/easy-rsa/* $PWD

echo "set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"" > vars

echo "yes" | ./easyrsa init-pki
echo "yes" | ./easyrsa gen-req server nopass

cp $PWD/pki/private/server.key /etc/openvpn/server/
cp $PWD/pki/reqs/server.req /tmp
##

###Creating CA
echo "set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "NewYork"
set_var EASYRSA_REQ_CITY       "New York City"
set_var EASYRSA_REQ_ORG        "DigitalOcean"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"" > vars

echo "yes" | ./easyrsa build-ca nopass
##

### Signing cert
echo "yes" | ./easyrsa import-req /tmp/server.req server
echo "yes" | ./easyrsa sign-req server server

cp $PWD/pki/issued/server.crt /tmp
cp $PWD/pki/ca.crt /tmp
cp /tmp/{server.crt,ca.crt} /etc/openvpn/server
##

###Configuring OpenVPN Cryptographic Material
openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/server
##

###Generating a Client Certificate and Key Pair
mkdir -p ~/client-configs/keys
mkdir -p ~/client-configs/files
echo "yes" | ./easyrsa gen-req client1 nopass
cp $PWD/pki/private/client1.key ~/client-configs/keys/

cp $PWD/pki/reqs/client1.req /tmp
echo "yes" | ./easyrsa import-req /tmp/client1.req client1
echo "yes" | ./easyrsa sign-req client client1
cp $PWD/pki/issued/client1.crt /tmp
cp /tmp/client1.crt ~/client-configs/keys/
cp $PWD/ta.key ~/client-configs/keys/
cp /etc/openvpn/server/ca.crt ~/client-configs/keys/

ufw allow 1194/udp
ufw allow OpenSSH

ufw disable
echo "yes" | ufw enable
sysctl -w net.ipv4.conf.all.forwarding=1

