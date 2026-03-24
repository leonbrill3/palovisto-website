#!/bin/bash

# Domain Status Checker for palovisto.com

echo "========================================="
echo "PaloVisto Domain Status"
echo "========================================="
echo ""
echo "🌐 Domain: palovisto.com"
echo "🎯 Target: Render (palovisto-website.onrender.com)"
echo ""

echo "DNS Records:"
echo "============"
echo -n "  A record (apex):  "
A_RECORD=$(dig +short palovisto.com A)
if [ "$A_RECORD" == "216.24.57.1" ]; then
    echo "✅ $A_RECORD (Render IP)"
else
    echo "❌ $A_RECORD (Expected: 216.24.57.1)"
fi

echo -n "  CNAME (www):      "
CNAME_RECORD=$(dig +short www.palovisto.com CNAME)
if echo "$CNAME_RECORD" | grep -q "palovisto-website.onrender.com"; then
    echo "✅ $CNAME_RECORD"
else
    echo "❌ $CNAME_RECORD (Expected: palovisto-website.onrender.com)"
fi

echo ""
echo "Render Verification:"
echo "==================="
RENDER_STATUS=$(curl -s -H "Authorization: Bearer rnd_42D81Io9Mkxe8DuujV3xm8Sb940Q" \
  "https://api.render.com/v1/services/srv-d70v4affte5s739r41i0/custom-domains" | \
  python3 -c "import sys, json; domains = json.load(sys.stdin); [print(f'  {d[\"customDomain\"][\"name\"]}: {d[\"customDomain\"][\"verificationStatus\"]}') for d in domains]" 2>/dev/null)

if echo "$RENDER_STATUS" | grep -q "verified"; then
    echo "✅ Domains verified"
else
    echo "⏳ Domains not yet verified (this can take 5-30 minutes)"
fi

echo "$RENDER_STATUS"

echo ""
echo "HTTP Connectivity:"
echo "=================="
echo -n "  http://palovisto.com:     "
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://palovisto.com 2>/dev/null)
if [ "$HTTP_STATUS" == "301" ] || [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ $HTTP_STATUS"
else
    echo "❌ $HTTP_STATUS"
fi

echo -n "  https://palovisto.com:    "
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://palovisto.com 2>/dev/null)
if [ "$HTTPS_STATUS" == "200" ]; then
    echo "✅ $HTTPS_STATUS"
elif [ "$HTTPS_STATUS" == "000" ]; then
    echo "⏳ SSL certificate not ready yet"
else
    echo "⚠️  $HTTPS_STATUS"
fi

echo ""
echo "Next Steps:"
echo "==========="
if echo "$RENDER_STATUS" | grep -q "unverified"; then
    echo "  • DNS is configured correctly"
    echo "  • Waiting for Render to verify domain (5-30 minutes)"
    echo "  • SSL certificate will be auto-provisioned after verification"
    echo ""
    echo "  Monitor at:"
    echo "    https://dashboard.render.com/static/srv-d70v4affte5s739r41i0/settings/custom-domains"
elif echo "$HTTPS_STATUS" | grep -q "000\|timeout"; then
    echo "  • Domain is verified but SSL not ready yet"
    echo "  • Usually takes 5-15 minutes after verification"
else
    echo "  ✅ Everything is working!"
    echo "  • Your site is live at https://palovisto.com"
    echo "  • www.palovisto.com redirects to palovisto.com"
fi

echo ""
