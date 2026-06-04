#!/bin/bash
sudo mkdir -p /home/ryu/holbertonschool-Cybersecurity/network_security/2x05_interceptor/squid/ssl_cert
cd /home/ryu/holbertonschool-Cybersecurity/network_security/2x05_interceptor/squid/ssl_cert

# Generate a new CA key and certificate
sudo openssl genrsa -out myCA.key 2048
sudo openssl req -new -x509 -days 365 -key myCA.key -out myCA.pem -subj "/CN=MySquidCA"
