#!/bin/bash -e -o pipefail
################################################################################
##  File:  update-ssl-certs.sh
##  Desc:  Update system SSL certificates for macOS 15
################################################################################

echo "Updating system SSL certificates..."

# Download latest certificates from curl
if command -v curl &> /dev/null; then
    echo "Downloading latest SSL certificates from curl..."
    curl -o /tmp/curl-ca-bundle.crt https://curl.se/ca/cacert.pem 2>/dev/null || true
    
    if [ -f "/tmp/curl-ca-bundle.crt" ]; then
        # Add to system keychain
        sudo /usr/bin/security add-trusted-cert -d -r trustRoot -k /System/Library/Keychains/SystemRootCertificates.keychain /tmp/curl-ca-bundle.crt 2>/dev/null || true
        
        # Add to user keychain
        security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain-db /tmp/curl-ca-bundle.crt 2>/dev/null || true
        
        echo "Updated system certificates from curl CA bundle"
    fi
fi

# Install Homebrew ca-certificates for additional coverage
if command -v brew &> /dev/null; then
    echo "Installing Homebrew ca-certificates..."
    brew install ca-certificates 2>/dev/null || true
    
    CERT_FILE=$(brew --prefix ca-certificates 2>/dev/null)/share/ca-certificates/cacert.pem
    
    if [ -f "$CERT_FILE" ]; then
        # Add to system keychain
        sudo /usr/bin/security add-trusted-cert -d -r trustRoot -k /System/Library/Keychains/SystemRootCertificates.keychain "$CERT_FILE" 2>/dev/null || true
        
        # Add to user keychain
        security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain-db "$CERT_FILE" 2>/dev/null || true
        
        echo "Updated system certificates from Homebrew ca-certificates"
    fi
fi

# Set up environment variables for SSL
echo "Setting up SSL environment variables..."
export SSL_CERT_FILE="/tmp/curl-ca-bundle.crt"
export SSL_CERT_DIR="/usr/local/etc/ssl/certs"
export CURL_CA_BUNDLE="/tmp/curl-ca-bundle.crt"

# Make environment variables persistent
echo "export SSL_CERT_FILE=/tmp/curl-ca-bundle.crt" >> ~/.bash_profile
echo "export SSL_CERT_DIR=/usr/local/etc/ssl/certs" >> ~/.bash_profile
echo "export CURL_CA_BUNDLE=/tmp/curl-ca-bundle.crt" >> ~/.bash_profile

# Also add to zsh profile if it exists
if [ -f ~/.zshrc ]; then
    echo "export SSL_CERT_FILE=/tmp/curl-ca-bundle.crt" >> ~/.zshrc
    echo "export SSL_CERT_DIR=/usr/local/etc/ssl/certs" >> ~/.zshrc
    echo "export CURL_CA_BUNDLE=/tmp/curl-ca-bundle.crt" >> ~/.zshrc
fi

echo "System SSL certificates updated successfully!"
echo "Environment variables configured:"
echo "  SSL_CERT_FILE: $SSL_CERT_FILE"
echo "  SSL_CERT_DIR: $SSL_CERT_DIR"
echo "  CURL_CA_BUNDLE: $CURL_CA_BUNDLE" 