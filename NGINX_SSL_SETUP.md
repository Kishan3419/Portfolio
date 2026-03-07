# Nginx SSL Setup Guide for Portfolio

## Overview
This configuration sets up a reverse proxy with SSL/TLS termination for your Docker portfolio container.

---

## Prerequisites
- Ubuntu server with root/sudo access
- Docker container running on `localhost:80`
- Domain: `kishankumarportfolio.epic-morse.online`
- IP: `150.136.194.34`

---

## Step 1: Install Nginx and Certbot

```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

---

## Step 2: Copy Nginx Configuration

```bash
# Download the nginx config from GitHub
sudo wget https://raw.githubusercontent.com/Kishan3419/Portfollio/master/nginx-reverse-proxy.conf \
  -O /etc/nginx/sites-available/portfolio

# OR manually create it
sudo nano /etc/nginx/sites-available/portfolio
# Then paste the contents of nginx-reverse-proxy.conf

# Enable the site
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/

# Disable default config (optional)
sudo rm -f /etc/nginx/sites-enabled/default
```

---

## Step 3: Test Nginx Configuration

```bash
sudo nginx -t
```

Expected output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

## Step 4: Start Nginx

```bash
sudo systemctl start nginx
sudo systemctl enable nginx  # Auto-start on reboot
```

---

## Step 5: Obtain SSL Certificate with Let's Encrypt

```bash
# Get SSL certificate (certbot will auto-update nginx config)
sudo certbot certonly --standalone -d kishankumarportfolio.epic-morse.online

# OR let certbot update nginx automatically
sudo certbot --nginx -d kishankumarportfolio.epic-morse.online
```

**During the process:**
- Enter your email
- Accept the terms
- Choose whether to redirect HTTP to HTTPS (recommended: Yes)

---

## Step 6: Set Up Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Enable auto-renewal timer
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check renewal status
sudo systemctl status certbot.timer
```

---

## Step 7: Verify Everything is Working

### Check Nginx Status:
```bash
sudo systemctl status nginx
```

### Test HTTPS:
```bash
# From your server
curl -I https://kishankumarportfolio.epic-morse.online

# Should return 200 OK
```

### View SSL Certificate Details:
```bash
sudo certbot certificates
```

### Check Nginx Logs:
```bash
# Live logs
sudo tail -f /var/log/nginx/portfolio_access.log
sudo tail -f /var/log/nginx/portfolio_error.log
```

---

## Step 8: Verify Docker Container is Running

```bash
# SSH into your server and check
docker ps

# Output should show portfolio-app running on port 80
```

---

## Key Features of This Configuration

✅ **SSL/TLS Encryption** - Full HTTPS support
✅ **HTTP to HTTPS Redirect** - Automatic upgrade
✅ **Security Headers** - HSTS, X-Frame-Options, CSP
✅ **Gzip Compression** - Faster page loads
✅ **Static Asset Caching** - 365-day cache for images/CSS/JS
✅ **Reverse Proxy** - Routes to Docker container
✅ **WebSocket Support** - If needed for real-time features
✅ **SSL Stapling** - Improved certificate validation
✅ **Auto-Renewal** - Certificate renews automatically

---

## Troubleshooting

### Certificate Not Found
```bash
# Check certificate exists
ls -la /etc/letsencrypt/live/kishankumarportfolio.epic-morse.online/
```

### Nginx Won't Start
```bash
# Check syntax errors
sudo nginx -t

# View error logs
sudo journalctl -u nginx -xe
```

### Port 80/443 Already in Use
```bash
# Find what's using the port
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Kill the process if needed
sudo kill -9 <PID>
```

### DNS Not Resolving
```bash
# Test DNS resolution
nslookup kishankumarportfolio.epic-morse.online
```

---

## Quick Commands

```bash
# Restart Nginx
sudo systemctl restart nginx

# Check if config is valid
sudo nginx -t

# View active connections
sudo netstat -an | grep ESTABLISHED | wc -l

# Monitor real-time traffic
sudo tail -f /var/log/nginx/portfolio_access.log

# Renew certificate manually
sudo certbot renew

# View certificate expiration
curl -vI https://kishankumarportfolio.epic-morse.online 2>&1 | grep -i "expire"
```

---

## Security Best Practices

✅ Keep Nginx and Certbot updated
✅ Use strong SSL protocols (TLSv1.2+)
✅ Enable HSTS for security
✅ Regularly check logs for attacks
✅ Keep Docker container updated
✅ Use firewall rules to limit access

---

## Visit Your Site

Once everything is set up:
- **HTTPS (Recommended):** https://kishankumarportfolio.epic-morse.online
- **HTTP (Auto-redirects):** http://kishankumarportfolio.epic-morse.online

Your portfolio is now secure and production-ready! 🎉
