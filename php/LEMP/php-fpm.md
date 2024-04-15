# PHP-FPM LEMP STACK
- Set Time and TimeZone
    ```bash
    timedatectl set-timezone Asia/Karachi &&
    timedatectl set-local-rtc false &&
    timedatectl set-ntp false &&
    timedatectl set-ntp true
    ```
- variables
    ```bash
    PHP_VERSION=7.2
    ```
- update the OS
    ```bash
    apt update && apt full-upgrade -y
    ```

- Installing an Apache and mysql server

    ```bash
    apt install build-essential {libssl,libffi}-dev nginx mysql-server unzip whois zip -y && ufw allow in "Nginx HTTP" && ufw enable && ufw allow in "OpenSSH"  && echo "Check it in your browser: $(curl -s curl http://icanhazip.com)"
    ```

- MySQL setup
    - Changing root user password for localhost

        ```bash
        PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c 25) && echo -e "Root User Password: \e[38;2;0;255;0m${PASSWORD}\e[0m" && echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${PASSWORD}';" | mysql && mysql -u root -p$PASSWORD;
        ```

        ```bash
        echo -e "Root User Password: \e[38;2;0;255;0m${PASSWORD}\e[0m" && echo "CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${PASSWORD}'; GRANT ALL PRIVILEGES ON * TO 'root'@'%'; FLUSH PRIVILEGES;" | mysql -u root -p$PASSWORD;
        ```

- Give access to all ipv4

    ```bash
    echo -e "[mysqld]\nbind-address = 0.0.0.0" | tee /etc/mysql/conf.d/custom.cnf > /dev/null && service mysql restart
    ```

## Adding some Repo for installing the php-fpm
- Ondrej PPA repository

    ```bash
    apt install software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update
    ```

- Installation of php-fpm along some PHP Extensions

    ```bash
    apt install php${PHP_VERSION} php${PHP_VERSION}-{bcmath,cli,common,curl,imagick,imap,intl,fpm,gd,json,ldap,mbstring,mysql,opcache,pdo,tidy,xml,xmlrpc,zip}
    ```

- To enable PHP FPM mod-conf enable

    ```bash
    a2enmod proxy_fcgi setenvif && systemctl restart nginx
    ```

- Ensure version
`php${PHP_VERSION} -v`

- Custom logs
    ```bash
    mkdir -p /var/log/custom_logs && chown -R www-data:www-data /var/log/custom_logs
    ```

## Conf File Setup
- Adding Configuration to /etc/logrotate.d/

    ```bash
    echo '/var/log/custom_logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    copytruncate
    }
    ' | tee /etc/logrotate.d/lr_custom >/dev/null && logrotate /etc/logrotate.d/lr_custom
    ```

- Cloudflare IPs
    ```bash
    echo -e "RemoteIPHeader CF-Connecting-IP

    # https://www.cloudflare.com/ips-v4
    $(for ip in $(curl -sL https://www.cloudflare.com/ips-v4); do echo "RemoteIPTrustedProxy ${ip}"; done;)

    # https://www.cloudflare.com/ips-v6
    $(for ip in $(curl -sL https://www.cloudflare.com/ips-v6); do echo "RemoteIPTrustedProxy ${ip}"; done;)
    " | tee /etc/apache2/conf-available/10-remoteip.conf >/dev/null && a2enconf 10-remoteip && a2enmod remoteip
    ```

- Directory Conf
  ```bash
  echo -e "DirectoryIndex index.php index.html index.htm" | tee /etc/apache2/conf-available/dir.conf >/dev/null && a2enconf dir
  ```

-   Change **Nginx**'s default virtual host configuration.

    ```bash
    rm /etc/nginx/sites-enabled/default && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/000-default.conf.bkp &&
    echo '# Default server configuration
    #
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        access_log '${CUS_LOGS}'/000-access.log compression;
        error_log '${CUS_LOGS}'/000-error.log;

        root /var/www/html;

        allow 127.0.0.;
        allow 137.59.225.112/32;
        allow 103.178.216.48/29;
        allow 103.178.217.96/28;
        allow 68.232.175.56/32;
        allow 2001:19f0:5:4a8:5400:2ff:fec0:6bed/128;
        deny all;

        location / {
            try_files $uri $uri/ =404;
        }

        location = /health_check.html {
            allow all;
        }
    }
    ' | tee /etc/nginx/sites-available/000-default.conf >/dev/null
    ```

    -   Confirm changes.

        ```bash
        nano /etc/nginx/sites-available/000-default.conf
        ```

    -   Enable default site.

        ```bash
        ln -s /etc/nginx/sites-available/000-default.conf /etc/nginx/sites-enabled/
        ```

-   Add file for **Nginx** default _virtual host_ and _health_check_..

    ```bash
    echo 'Farhan Scratch' | tee /var/www/html/index.html >/dev/null;\
    echo 'Server OK' | tee /var/www/html/health_check.html >/dev/null
    ```

-   Change ownership of newly created files.

    ```bash
    chown -R www-data:www-data /var/www/
    ```

- For enable /ping and /status /realtime-status

    ```bash
    sed -i 's/;ping.path/ping.path/; s/;pm.status_path/pm.status_path/; s/^pm\.start_servers = .*/pm.start_servers = 10/; s/^pm\.min_spare_servers = .*/pm.min_spare_servers = 7/; s/^pm\.max_spare_servers = .*/pm.max_spare_servers = 10/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
    ```

## Services Setup
- Add scripts to Reload and Restart Apache2 PHP-FPM

    ```bash
    echo '#!/bin/bash
    systemctl reload '${APP_NAME}'.service; systemctl status '${APP_NAME}'.service --no-pager;
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    systemctl reload nginx.service; systemctl status nginx.service --no-pager;
    ' | tee /usr/local/bin/reload-php-server.sh >/dev/null &&
    chmod +x /usr/local/bin/reload-php-server.sh;\
    echo '#!/bin/bash
    systemctl restart '${APP_NAME}'.service; systemctl status '${APP_NAME}'.service --no-pager;
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    systemctl restart nginx.service; systemctl status nginx.service --no-pager;
    ' | tee /usr/local/bin/restart-php-server.sh >/dev/null &&
    chmod +x /usr/local/bin/restart-php-server.sh
    ```
    - Confirm changes.

        ```bash
        nano /usr/local/bin/re{load,start}-php-server.sh
        ```




## Install phpmyadmin
```bash
add-apt-repository ppa:phpmyadmin/ppa && apt update && apt install phpmyadmin
```

# Set Virtual Host For Another Site
## Setup files
  - Variable
    ```bash
    SITE_NAME=first.com
    ```
  - Make Dir for the Web and set permission
    ```bash
    mkdir -p /var/www/${SITE_NAME}/public_html && chown -R www-data:www-data /var/www/${SITE_NAME}/public_html && echo '<html>
    <head>
        <title>Welcome to '${SITE_NAME}'</title>
    </head>
    <body>
        <h1>Success! The '${SITE_NAME}' virtual host is working!</h1>
    </body>
    </html>
    ' | tee /var/www/${SITE_NAME}/public_html/index.html >/dev/null
    ```

  - Make Conf file

    ```bash
    echo 'server {
        listen 80;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name '${SITE_NAME}';

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
    }
    ' | tee /etc/nginx/sites-available/${SITE_NAME} >/dev/null
    ```

  - Restart services

    ```bash
    restart-php-server.sh
    ```


