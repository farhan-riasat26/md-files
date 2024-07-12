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

APP_DIR=/var/python/fastapi/${APP_NAME}
CUS_LOGS=/var/log/custom_logs

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

# Install FastAPI and Gunicorn
echo "Installing FastAPI and Gunicorn..."
pip install fastapi[all] gunicorn

# Create FastAPI application
echo "Creating FastAPI application..."
echo "
import env_file_reader
import os
import socket
from fastapi import FastAPI

PORT = os.environ.get('PORT', '8000')

app = FastAPI()

@app.get('/')
async def hello_world():
    return 'Hello World!'

# Get the current machine's hostname
hostname = socket.gethostname()

# Get the current machine's IP address
ip_address = socket.gethostbyname(hostname)

if __name__ == '__main__':
    print(f'Server is running on: http://{ip_address}:{PORT}/docs')
    import uvicorn
    uvicorn.run('main:app', host='0.0.0.0', port=int(PORT), reload=True)
" | tee ${APP_DIR}/main.py >/dev/null

# Create .env file
echo "Creating .env file..."
echo "
# comment DEV_MODE during production
DEV_MODE=True

DISCORD_WEBHOOK=''
PORT=8001
APP_DOMAIN='${APP_NAME}'
" | tee ${APP_DIR}/.env >/dev/null

# Create Env File Reader
echo "Creating .env file..."
echo "
from dotenv import main
import os


updateEnv = main.dotenv_values()
os.environ.update(updateEnv)
main.load_dotenv()
" | tee ${APP_DIR}/env_file_reader.py >/dev/null

# Create systemd service file
echo "Creating systemd service file for ${APP_NAME}..."
echo '
[Unit]
Description=Gunicorn to run '${APP_NAME}'
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory='${APP_DIR}'
ExecStart='${APP_DIR}'/env/bin/gunicorn -c gunicorn_conf.py main:app

[Install]
WantedBy=multi-user.target
' | tee /etc/systemd/system/${APP_NAME}.service >/dev/null

# Create Gunicorn configuration file
echo "Creating Gunicorn configuration file..."
echo "
from multiprocessing import cpu_count
import os
from dotenv import load_dotenv

load_dotenv()

APP_DOMAIN = os.environ.get('APP_DOMAIN')
wdir = os.getcwd()
accesslog = f'/var/log/custom_logs/{APP_DOMAIN}-gunicorn-access.log'
errorlog = f'/var/log/custom_logs/{APP_DOMAIN}-gunicorn-error.log'
# Socket Path
bind = f'unix:/var/python/fastapi/{APP_DOMAIN}/{APP_DOMAIN}.sock'

# Worker Options
workers = 2*cpu_count() + 1
worker_class = 'uvicorn.workers.UvicornWorker'
# Logging Options
loglevel = 'debug'
accesslog = os.path.join(accesslog)
errorlog =  os.path.join(errorlog)

timeout = 1800
keepalive = 1000
threads = 3
access_log_format = '%(h)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\"'
raw_env = ['TOKENIZERS_PARALLELISM=False']
capture_output = True
worker_tmp_dir = os.path.join(wdir,'log')
reload = True
" | tee ${APP_DIR}/gunicorn_conf.py >/dev/null

# Create log files and set permissions
echo "Creating log files and setting permissions..."
touch ${CUS_LOGS}/${APP_NAME}-gunicorn-access.log ${CUS_LOGS}/${APP_NAME}-gunicorn-error.log && chown www-data:www-data ${CUS_LOGS}/${APP_NAME}-gunicorn-*

chown -R www-data:www-data ${APP_DIR}

# Start and enable the service
echo "Starting and enabling ${APP_NAME} service..."
systemctl start ${APP_NAME}.service && systemctl enable ${APP_NAME}.service && systemctl status ${APP_NAME}.service

# Configure NGINX
echo "Configuring NGINX for ${APP_NAME}..."
echo "
server {
    listen 80;
    listen [::]:80;
    server_name ${APP_NAME};
    access_log ${CUS_LOGS}/${APP_NAME}-access.log compression;
    error_log ${CUS_LOGS}/${APP_NAME}-error.log;

    client_max_body_size 10M;

    location / {
        include proxy_params;
        proxy_read_timeout 180;
        proxy_pass http://unix:${APP_DIR}/${APP_NAME}.sock;
    }
}
" | tee /etc/nginx/sites-available/${APP_NAME}.conf >/dev/null

ln -s /etc/nginx/sites-available/${APP_NAME}.conf /etc/nginx/sites-enabled/

# Restart NGINX
echo "Restarting NGINX..."
restart-${APP_NAME}.sh

echo "Setup completed successfully for ${APP_NAME}!"

