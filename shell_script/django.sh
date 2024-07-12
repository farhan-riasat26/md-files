#!/bin/bash

# Function to display a bordered prompt for APP_NAME input
get_app_name() {
  while true; do
    echo "..........................................."
    echo ".                                         ."
    echo ".       Enter the APP_NAME:               ."
    echo ".                                         ."
    echo "..........................................."
    read -p ". " APP_NAME
    echo "..........................................."

    # Check if APP_NAME is non-empty and contains no spaces
    if [[ -n "$APP_NAME" && "$APP_NAME" != *" "* ]]; then
      break
    else
      echo "APP_NAME cannot be empty and cannot contain spaces. Please try again."
    fi
  done
}


# Get the APP_NAME from the user
get_app_name

APP_DIR=/var/python/django/${APP_NAME}
CUS_LOGS=/var/log/custom_logs
PROJECT_NAME=${APP_NAME}

# Check if APP_NAME contains '.' and replace it with '_' if true
if [[ "$PROJECT_NAME" == *"."* ]]; then
  PROJECT_NAME="${PROJECT_NAME//./_}"
fi
echo ${PROJECT_NAME}
# Create reload and restart scripts
echo "Creating reload and restart scripts for ${APP_NAME}..."
echo '#!/bin/bash
systemctl reload '${APP_NAME}'.service; systemctl status '${APP_NAME}'.service --no-pager;
printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
systemctl reload nginx.service; systemctl status nginx.service --no-pager;
' | tee /usr/local/bin/reload-${APP_NAME}.sh >/dev/null &&
chmod +x /usr/local/bin/reload-${APP_NAME}.sh

echo '#!/bin/bash
systemctl restart '${APP_NAME}'.service; systemctl status '${APP_NAME}'.service --no-pager;
printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
systemctl restart nginx.service; systemctl status nginx.service --no-pager;
' | tee /usr/local/bin/restart-${APP_NAME}.sh >/dev/null &&
chmod +x /usr/local/bin/restart-${APP_NAME}.sh

# Create application directory and set up virtual environment
echo "Setting up application directory and virtual environment for ${APP_NAME}..."
mkdir -p ${APP_DIR} && mkdir -p ${APP_DIR}/log && cd ${APP_DIR} && python3 -m venv env

source env/bin/activate

echo "Install necessary packages..."
pip install django gunicorn


echo "Make a project for django..."
django-admin startproject ${PROJECT_NAME} .


echo "To make a socket file..."
echo '
[Unit]
Description=Project Description

[Socket]
ListenStream='${APP_DIR}'/'${APP_NAME}'.sock

[Install]
WantedBy=sockets.target
' | tee /etc/systemd/system/${APP_NAME}.socket >/dev/null

# Make a service file
echo "Make a service file..."

echo '
[Unit]
Description=gunicorn daemon
Requires='${APP_NAME}'.socket
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory='${APP_DIR}'
ExecStart='${APP_DIR}'/env/bin/gunicorn --workers 3 --bind unix:'${APP_DIR}'/'${APP_NAME}'.sock '${PROJECT_NAME}'.wsgi:application

[Install]
WantedBy=multi-user.target
' | tee /etc/systemd/system/${APP_NAME}.service >/dev/null

echo "Now start and enable gunicorn socket..."
systemctl start ${APP_NAME}.socket
systemctl enable ${APP_NAME}.socket

echo "Now start and enable gunicorn socket..."
echo "
server {
    listen 80;
    listen [::]:80;
    server_name "${APP_NAME}";
    access_log "${CUS_LOGS}"/"${APP_NAME}"-access.log compression;
    error_log "${CUS_LOGS}"/"${APP_NAME}"-error.log;

    client_max_body_size 10M;

    location / {
        include proxy_params;
        proxy_read_timeout 180;
        proxy_pass http://unix:"${APP_DIR}"/"${APP_NAME}".sock;
    }
}
" | tee /etc/nginx/sites-available/${APP_NAME}.conf >>/dev/null

echo 'Enable virtual host.'

ln -s /etc/nginx/sites-available/${APP_NAME}.conf /etc/nginx/sites-enabled/

nginx -t


# Restart NGINX
echo "Restarting NGINX..."
restart-${APP_NAME}.sh

echo "Setup completed successfully for ${APP_NAME}!"
