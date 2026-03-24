#!/bin/bash

# GoDaddy DNS Configuration Script
# This script will guide you through configuring DNS for palovisto.com

API_KEY='9EBtFuaCXtg_S4ALqHFDnf6zb7ZZT8QC3f'
API_SECRET='WKv4jsbdj7dAyQJadHuayC'
DOMAIN='palovisto.com'
RENDER_IP='216.24.57.1'
RENDER_CNAME='palovisto-website.onrender.com'

echo "========================================="
echo "Configuring DNS for ${DOMAIN}"
echo "========================================="
echo ""

# Test API credentials first
echo "Testing GoDaddy API credentials..."
RESPONSE=$(curl -s -X GET "https://api.godaddy.com/v1/domains/${DOMAIN}" \
  -H "Authorization: sso-key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json")

if echo "$RESPONSE" | grep -q "MALFORMED_CREDENTIALS\|UNAUTHORIZED"; then
    echo "❌ API credentials are invalid or expired"
    echo ""
    echo "Please get new credentials from:"
    echo "  https://developer.godaddy.com/keys"
    echo ""
    echo "Manual DNS Configuration Required:"
    echo "=================================="
    echo ""
    echo "Go to: https://dcc.godaddy.com/control/${DOMAIN}/dns"
    echo ""
    echo "Add/Edit these records:"
    echo ""
    echo "1. A Record:"
    echo "   Type: A"
    echo "   Name: @"
    echo "   Value: ${RENDER_IP}"
    echo "   TTL: 600"
    echo ""
    echo "2. CNAME Record:"
    echo "   Type: CNAME"
    echo "   Name: www"
    echo "   Value: ${RENDER_CNAME}"
    echo "   TTL: 600"
    echo ""

    # Try to open GoDaddy DNS page
    echo "Opening GoDaddy DNS management..."
    open "https://dcc.godaddy.com/control/${DOMAIN}/dns"

    exit 1
fi

echo "✅ API credentials valid"
echo ""

# Get current DNS records
echo "Fetching current DNS records..."
CURRENT_RECORDS=$(curl -s -X GET "https://api.godaddy.com/v1/domains/${DOMAIN}/records" \
  -H "Authorization: sso-key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json")

echo "Current records:"
echo "$CURRENT_RECORDS" | python3 -m json.tool
echo ""

# Configure A record
echo "Setting A record for apex domain..."
A_RESPONSE=$(curl -s -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/@" \
  -H "Authorization: sso-key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json" \
  -d "[{\"data\": \"${RENDER_IP}\", \"ttl\": 600}]")

if [ -z "$A_RESPONSE" ]; then
    echo "✅ A record set successfully"
else
    echo "Response: $A_RESPONSE"
fi

echo ""

# Configure CNAME record
echo "Setting CNAME record for www..."
CNAME_RESPONSE=$(curl -s -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/CNAME/www" \
  -H "Authorization: sso-key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json" \
  -d "[{\"data\": \"${RENDER_CNAME}\", \"ttl\": 600}]")

if [ -z "$CNAME_RESPONSE" ]; then
    echo "✅ CNAME record set successfully"
else
    echo "Response: $CNAME_RESPONSE"
fi

echo ""
echo "========================================="
echo "DNS Configuration Complete!"
echo "========================================="
echo ""
echo "Verifying records..."
sleep 2

# Verify the changes
UPDATED_RECORDS=$(curl -s -X GET "https://api.godaddy.com/v1/domains/${DOMAIN}/records" \
  -H "Authorization: sso-key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json")

echo "Updated records:"
echo "$UPDATED_RECORDS" | python3 -m json.tool | grep -A 5 '"type": "A"' | head -15
echo "$UPDATED_RECORDS" | python3 -m json.tool | grep -A 5 '"type": "CNAME"' | head -15

echo ""
echo "Monitor propagation at:"
echo "  https://www.whatsmydns.net/#A/${DOMAIN}"
echo "  https://www.whatsmydns.net/#CNAME/www.${DOMAIN}"
echo ""
