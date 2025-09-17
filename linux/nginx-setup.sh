#!/usr/bin/env bash
set -e

DOMAIN="${1:?Error: You must provide a domain (e.g. ./setup-nginx.sh mateus.digital)}"

## ---------------------------------------------------------
## Nginx + UFW setup script for Ubuntu
## Author: mateus.digital
## Date: 2025-08-26
## ---------------------------------------------------------
WEBROOT="/var/www/$DOMAIN/html";
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN";

## -----------------------------------------------------------------------------
echo "Installing Nginx...";
sudo apt update -y;
sudo apt install -y nginx ufw curl;

## -----------------------------------------------------------------------------
echo "Configuring UFW firewall...";
sudo ufw allow OpenSSH;
sudo ufw allow 'Nginx HTTP';
sudo ufw --force enable;

## -----------------------------------------------------------------------------
echo "Creating web root at ($WEBROOT)...";
sudo mkdir -p "$WEBROOT";
sudo chown -R $USER:$USER "$WEBROOT";
sudo chmod -R 755 "/var/www/$DOMAIN";

## -----------------------------------------------------------------------------
echo "Creating sample index.html..."
cat <<EOF | sudo tee "$WEBROOT/index.html" > /dev/null
<html>
  <head>
    <title>Welcome to $DOMAIN!</title>
  </head>
  <body>
    <h1>Success! The $DOMAIN server block is working!</h1>
  </body>
</html>
EOF

## -----------------------------------------------------------------------------
echo "Creating Nginx config at $NGINX_CONF..."
cat <<EOF | sudo tee "$NGINX_CONF" > /dev/null
server {
    listen 80;
    listen [::]:80;

    root $WEBROOT;
    index index.html index.htm;

    server_name $DOMAIN www.$DOMAIN;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

## -----------------------------------------------------------------------------
echo "Enabling site..."
if [ -L "/etc/nginx/sites-enabled/$DOMAIN" ]; then
    sudo rm "/etc/nginx/sites-enabled/$DOMAIN"
fi
sudo ln -s "$NGINX_CONF" "/etc/nginx/sites-enabled/"

if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "Disabling default site..."
    sudo rm "/etc/nginx/sites-enabled/default"
fi

## -----------------------------------------------------------------------------
echo "Testing Nginx config..."
sudo nginx -t;

echo "Restarting Nginx...";
sudo systemctl reload nginx;

## -----------------------------------------------------------------------------
IP=$(curl -s icanhazip.com || echo "your-server-ip");

echo "Setup complete!"

## ---------------------------------------------------------------------------##
##                                                                            ##
##   Certbot (Let's Encrypt) setup                                            ##
##                                                                            ##
## ---------------------------------------------------------------------------##

echo "Installing Certbot (Let's Encrypt)...";
sudo apt install -y certbot python3-certbot-nginx;

echo "Requesting SSL certificate for $DOMAIN...";
sudo certbot --nginx             \
  -d "$DOMAIN" -d "www.$DOMAIN"  \
  --non-interactive --agree-tos  \
  -m "hello@mateus.digital"      \
;

## -----------------------------------------------------------------------------
echo "Enabling auto-renewal..."
sudo systemctl enable certbot.timer;
sudo systemctl start certbot.timer;

## -----------------------------------------------------------------------------
echo "SSL setup complete!"
