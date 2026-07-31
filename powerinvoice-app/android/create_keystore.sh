#!/bin/bash

# Script to create Android keystore for PowerInvoice app

echo "Creating Android keystore for PowerInvoice..."
echo ""
echo "You will be asked for:"
echo "1. Keystore password (remember this!)"
echo "2. Key password (can be same as keystore password)"
echo "3. Your name and organization info"
echo ""

keytool -genkey -v -keystore powerinvoice-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias powerinvoice \
  -storetype JKS

echo ""
echo "Keystore created successfully!"
echo "File: powerinvoice-key.jks"
echo ""
echo "IMPORTANT: Keep this file and passwords safe!"
echo "You'll need them to update your app in the future."
