# Domain Setup Guide - palovisto.com

## Current Status
- ✅ Website deployed at: https://palovisto-website.onrender.com
- ✅ Custom domain added to Render: palovisto.com and www.palovisto.com
- ⏳ DNS configuration needed

## Quick Setup

### Option 1: Automated via GoDaddy API

1. **Get GoDaddy API Credentials**
   - Visit: https://developer.godaddy.com/keys
   - Create a new API key for Production environment
   - Save the Key and Secret

2. **Configure DNS Automatically**
   ```bash
   cd /Users/leonbrill/palovisto-website

   # Set your credentials
   export GODADDY_API_KEY='your-key-here'
   export GODADDY_API_SECRET='your-secret-here'

   # Run the setup script
   ./setup-domain.sh
   ```

### Option 2: Manual Configuration

1. **Go to GoDaddy DNS Management**
   - URL: https://dcc.godaddy.com/control/palovisto.com/dns

2. **Add/Update DNS Records**

   **A Record (Apex Domain):**
   - Type: `A`
   - Name: `@`
   - Value: `216.24.57.1`
   - TTL: `600` (10 minutes)

   **CNAME Record (www subdomain):**
   - Type: `CNAME`
   - Name: `www`
   - Value: `palovisto-website.onrender.com`
   - TTL: `600` (10 minutes)

## DNS Records Required

| Type  | Name | Value                          | TTL |
|-------|------|--------------------------------|-----|
| A     | @    | 216.24.57.1                    | 600 |
| CNAME | www  | palovisto-website.onrender.com | 600 |

## Verification

### Check DNS Propagation
```bash
# Check apex domain
dig palovisto.com

# Check www subdomain
dig www.palovisto.com

# Expected results:
# palovisto.com -> 216.24.57.1
# www.palovisto.com -> palovisto-website.onrender.com
```

### Monitor Globally
- https://www.whatsmydns.net/#A/palovisto.com
- https://www.whatsmydns.net/#CNAME/www.palovisto.com

### Render Dashboard
- Custom domains status: https://dashboard.render.com/static/srv-d70v4affte5s739r41i0/settings/custom-domains

## Timeline
- **DNS Propagation:** 2-48 hours (typically 2-4 hours)
- **SSL Certificate:** Automatically provisioned by Render once DNS is verified

## Troubleshooting

### DNS Not Updating
- Clear old records that might conflict
- Ensure TTL is set to 600 (10 minutes) for faster updates
- Use `dig @8.8.8.8 palovisto.com` to check Google DNS

### Render Shows "Unverified"
- Wait for DNS to fully propagate
- Check that A record points to exact IP: 216.24.57.1
- Verify CNAME has no trailing dot

## One-Line API Commands

If you have GoDaddy API credentials:

```bash
# Set A record for apex domain
curl -X PUT "https://api.godaddy.com/v1/domains/palovisto.com/records/A/@" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d '[{"data": "216.24.57.1", "ttl": 600}]'

# Set CNAME for www
curl -X PUT "https://api.godaddy.com/v1/domains/palovisto.com/records/CNAME/www" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d '[{"data": "palovisto-website.onrender.com", "ttl": 600}]'
```
