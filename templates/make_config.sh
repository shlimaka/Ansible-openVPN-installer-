#!/bin/bash
 
# First argument: Client identifier
 
KEY_DIR=~/client-configs/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf
 
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/${1}.ovpn


### Send openvpn config ##
apt-get install ssmtp -y
echo "
root=openvpncert@gmail.com
mailhub=smtp.gmail.com:465
rewriteDomain=gmail.com
AuthUser=openvpncert@gmail.com
AuthPass=ndjshgtvxakyxgna
FromLineOverride=YES
UseTLS=YES" > /etc/ssmtp/ssmtp.conf

ssmtp {{ email }} < /root/client-configs/files/client1.ovpn
