#!/bin/bash

# Set timezone and configure time settings
echo "Setting timezone to Asia/Karachi and configuring time settings..."
timedatectl set-timezone Asia/Karachi
timedatectl set-local-rtc false
timedatectl set-ntp false
timedatectl set-ntp true

# Define custom logs directory
CUS_LOGS=/var/log/custom_logs

# Update and upgrade packages
echo "Updating package list and upgrading packages..."
apt update && apt full-upgrade -y

# Create custom logs directory and configure log rotation
echo "Creating custom logs directory and configuring log rotation..."
mkdir -p ${CUS_LOGS}
echo "${CUS_LOGS}/*.log
{
daily
missingok
rotate 14
compress
delaycompress
notifempty
create 640 root adm
sharedscripts
copytruncate
}
" | tee /etc/logrotate.d/lr_custom >/dev/null && logrotate /etc/logrotate.d/lr_custom

# Install necessary packages for NGINX and other tools
echo "Installing necessary packages..."
apt install build-essential libssl-dev libffi-dev nginx python3 python3-pip python3-dev python3-venv default-libmysqlclient-dev zip unzip whois -y

# Configure NGINX
echo "Configuring NGINX..."
sed -i'.bkp' -e 's/# server_tokens off;/server_tokens off;/;' /etc/nginx/nginx.conf
mv /etc/nginx/conf.d /etc/nginx/conf-available && mkdir /etc/nginx/conf-enabled && ln -s /etc/nginx/conf-enabled /etc/nginx/conf.d && cp -s /etc/nginx/conf-available/* /etc/nginx/conf-enabled/

# Configure Cloudflare real IPs
echo "Configuring Cloudflare real IPs..."
echo -e "real_ip_header CF-Connecting-IP;

# https://www.cloudflare.com/ips-v4
$(for ip in $(curl -sL https://www.cloudflare.com/ips-v4); do echo "set_real_ip_from ${ip};"; done)

# https://www.cloudflare.com/ips-v6
$(for ip in $(curl -sL https://www.cloudflare.com/ips-v6); do echo "set_real_ip_from ${ip};"; done)

# Add IP of Load Balancer
#set_real_ip_from 0.0.0.0/32;
" | tee /etc/nginx/conf-available/10-remoteip.conf >/dev/null && ln -s /etc/nginx/conf-available/10-remoteip.conf /etc/nginx/conf-enabled/

# Configure log formats
echo "Configuring log formats..."
echo "log_format compression '\$remote_addr - \$remote_user [\$time_local] \"\$request\" \$status \$body_bytes_sent \"\$http_referer\" \"\$http_user_agent\" \"\$gzip_ratio\"';" | tee /etc/nginx/conf-available/20-log_formats.conf >/dev/null && ln -s /etc/nginx/conf-available/20-log_formats.conf /etc/nginx/conf-enabled/

# Configure default server
echo "Configuring default server..."
rm /etc/nginx/sites-enabled/default && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/000-default.conf.bkp &&
echo "# Default server configuration
#
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    access_log ${CUS_LOGS}/000-access.log compression;
    error_log ${CUS_LOGS}/000-error.log;

    root /var/www/html;

    allow 127.0.0.1;
    allow 137.59.225.112/32;
    allow 103.178.216.48/29;
    allow 103.178.217.96/28;
    allow 68.232.175.56/32;
    allow 2001:19f0:5:4a8:5400:2ff:fec0:6bed/128;
    # deny all;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /health_check.html {
        allow all;
    }
}" | tee /etc/nginx/sites-available/000-default.conf >/dev/null

ln -s /etc/nginx/sites-available/000-default.conf /etc/nginx/sites-enabled/

# Create test pages
echo "Creating test pages..."
echo 'Farhan Scratch' | tee /var/www/html/index.html >/dev/null
echo 'Server OK' | tee /var/www/html/health_check.html >/dev/null

# Set ownership of web root
echo "Setting ownership of web root..."
chown -R www-data:www-data /var/www/

# Test NGINX configuration and restart service
echo "Testing NGINX configuration..."
nginx -t

echo "Restarting NGINX service..."
systemctl restart nginx

echo "Checking NGINX status..."
systemctl status nginx
