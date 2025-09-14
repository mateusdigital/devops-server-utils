#!/usr/bin/env bash
set -e

## ---------------------------------------------------------
## Nginx + UFW setup script for Ubuntu
## Author: mateus.digital
## Date: 2025-08-26
## ---------------------------------------------------------

## --- CONFIG ---
DOMAIN="${1:?Error: You must provide a domain (e.g. ./setup-nginx.sh mateus.digital)}"
WEBROOT="/var/www/$DOMAIN/html"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

echo "-------------------------------------------------"
echo "--- Setting up Nginx for domain: ($DOMAIN) ---"
echo "-------------------------------------------------"

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
sudo nginx -t

echo "Restarting Nginx..."
sudo systemctl reload nginx

## -----------------------------------------------------------------------------
IP=$(curl -s icanhazip.com || echo "your-server-ip")

echo "-------------------------------------------------"
echo "Setup complete!"
echo "Visit your site at: http://$DOMAIN or http://$IP"
echo "-------------------------------------------------"
