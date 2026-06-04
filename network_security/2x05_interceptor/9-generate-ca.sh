#!/bin/bash
# Generate self-signed CA for Squid SNI peeking

CERT_DIR="/etc/squid/ssl_cert"
CA_KEY="$CERT_DIR/squidCA.key"
CA_CERT="$CERT_DIR/squidCA.crt"

# Create the certificate directory
mkdir -p "$CERT_DIR"
chmod 700 "$CERT_DIR"

# Generate a self-signed CA certificate
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -keyout "$CA_KEY" -out "$CA_CERT" \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=Squid-CA"

# Initialize Squid SSL certificate database
/usr/lib/squid/security_file_certgen -c -s "$CERT_DIR" -M 4MB
