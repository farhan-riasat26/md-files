# PHP-FPM Multi version LAMP STACK
- Set Time and TimeZone
    ```bash
    timedatectl set-timezone Asia/Karachi &&
    timedatectl set-local-rtc false &&
    timedatectl set-ntp false &&
    timedatectl set-ntp true
    ```
- variables

    ```bash
    PHP_VERSIONS=("7.2" "7.3" "7.4" "8.0" "8.1")
    ```
- update the OS

    ```bash
    apt update && apt full-upgrade -y
    ```

- Installing an Apache and mysql server

    ```bash
    apt install apache2 mysql-server unzip whois zip -y && ufw allow in "Apache" && ufw enable && ufw allow in "OpenSSH"  && echo "Check it in your browser: $(curl -s curl http://icanhazip.com)"
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
    apt install software-properties-common  && add-apt-repository -y ppa:ondrej/php && apt update
    ```

- Installation of php-fpm along some PHP Extensions

    ```bash
    apt install php{7.{2,4},8.{0,1,2,3}}{,-{bcmath,cli,common,curl,imagick,imap,intl,fpm,gd,ldap,mbstring,mysql,opcache,pdo,tidy,xml,xmlrpc,zip}} php7.{2,4}-json
    ```
- To enable PHP FPM mod-conf enable

    ```bash
    a2enmod proxy_fcgi setenvif && a2enconf php{7.{2,4},8.{0,1,2,3}}-fpm && systemctl restart apache2
    - For enable /ping and /status /realtime-status

    ```bash
    sed -i 's/;ping.path/ping.path/; s/;pm.status_path/pm.status_path/; s/^pm\.start_servers = .*/pm.start_servers = 10/; s/^pm\.min_spare_servers = .*/pm.min_spare_servers = 7/; s/^pm\.max_spare_servers = .*/pm.max_spare_servers = 10/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
    ```

## Services Setup
- Add scripts to Reload and Restart Apache2 PHP-FPM

    ```bash
    echo '#!/bin/bash

    # Restart Apache2
    systemctl reload apache2
    systemctl status apache2
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    # reload PHP'${PHP_VERSION}'-FPM
    systemctl reload php'${PHP_VERSION}'-fpm
    systemctl status php'${PHP_VERSION}'-fpm
    ' | tee "/usr/local/bin/reload-services.sh" >/dev/null && chmod +x "/usr/local/bin/reload-services.sh"

    echo '#!/bin/bash

    # Restart Apache2
    systemctl restart apache2
    systemctl status apache2
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    # Restart PHP'${PHP_VERSION}'-FPM
    systemctl restart php'${PHP_VERSION}'-fpm
    systemctl status php'${PHP_VERSION}'-fpm
    ' | tee "/usr/local/bin/restart-services.sh" >/dev/null && chmod +x "/usr/local/bin/restart-services.sh"
    ```
    - Confirm changes.

        ```bash
        nano /usr/local/bin/re{load,start}-services.sh
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
    echo '<VirtualHost *:80>
    ServerAdmin admin@'${SITE_NAME}'
    ServerName '${SITE_NAME}'
    ServerAlias www.'${SITE_NAME}'
    DocumentRoot /var/www/'${SITE_NAME}'/public_html

    ErrorLog /var/log/custom_logs/'${SITE_NAME}'-error.log
    CustomLog /var/log/custom_logs/'${SITE_NAME}'-access.log combined
    </VirtualHost>
    ' | tee /etc/apache2/sites-available/${SITE_NAME} >/dev/null
    ```

  - Restart services

    ```bash
    a2ensite ${SITE_NAME}.conf && restart-services.sh
    ```

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

- 000-default.conf

    ```bash
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup &&
    echo '<VirtualHost *:80>

            ServerAdmin webmaster@localhost
            DocumentRoot /var/www/html

            <FilesMatch ".php$">
            SetHandler "proxy:unix:/var/run/php/php'${PHP_VERSION}'-fpm.sock|fcgi://localhost/"
            </FilesMatch>
            <LocationMatch "/(ping|status)">
            SetHandler "proxy:unix:/run/php/php'${PHP_VERSION}'-fpm.sock|fcgi://localhost"
            </LocationMatch>

            <IfModule alias_module>
            Alias /realtime-status "/usr/share/php/'${PHP_VERSION}'/fpm/status.html"
            </IfModule>

            <Directory "/var/www/html">
                Options Indexes FollowSymLinks
                AllowOverride All
                # Allow access from a specific IP address
                Require ip 137.59.225.112
                Require ip 173.245.48.0/20
                Require ip 103.21.244.0/22
                Require ip 2400:cb00::/32
            </Directory>

            ErrorLog /var/log/custom_logs/000-default-error.log
            CustomLog /var/log/custom_logs/000-default-access.log combined

    </VirtualHost>
    ' | tee /etc/apache2/sites-available/000-default.conf >/dev/null
    ```

- For enable /ping and /status /realtime-status

    ```bash
    sed -i 's/;ping.path/ping.path/; s/;pm.status_path/pm.status_path/; s/^pm\.start_servers = .*/pm.start_servers = 10/; s/^pm\.min_spare_servers = .*/pm.min_spare_servers = 7/; s/^pm\.max_spare_servers = .*/pm.max_spare_servers = 10/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
    ```

## Services Setup
- Add scripts to Reload and Restart Apache2 PHP-FPM

    ```bash
    echo '#!/bin/bash

    # Restart Apache2
    systemctl reload apache2
    systemctl status apache2
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    # reload PHP'${PHP_VERSION}'-FPM
    systemctl reload php'${PHP_VERSION}'-fpm
    systemctl status php'${PHP_VERSION}'-fpm
    ' | tee "/usr/local/bin/reload-services.sh" >/dev/null && chmod +x "/usr/local/bin/reload-services.sh"

    echo '#!/bin/bash

    # Restart Apache2
    systemctl restart apache2
    systemctl status apache2
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" "" | tr " " -;
    # Restart PHP'${PHP_VERSION}'-FPM
    systemctl restart php'${PHP_VERSION}'-fpm
    systemctl status php'${PHP_VERSION}'-fpm
    ' | tee "/usr/local/bin/restart-services.sh" >/dev/null && chmod +x "/usr/local/bin/restart-services.sh"
    ```
    - Confirm changes.

        ```bash
        nano /usr/local/bin/re{load,start}-services.sh
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
    echo '<VirtualHost *:80>
    ServerAdmin admin@'${SITE_NAME}'
    ServerName '${SITE_NAME}'
    ServerAlias www.'${SITE_NAME}'
    DocumentRoot /var/www/'${SITE_NAME}'/public_html

    ErrorLog /var/log/custom_logs/'${SITE_NAME}'-error.log
    CustomLog /var/log/custom_logs/'${SITE_NAME}'-access.log combined
    </VirtualHost>
    ' | tee /etc/apache2/sites-available/${SITE_NAME} >/dev/null
    ```

  - Restart services

    ```bash
    a2ensite ${SITE_NAME}.conf && restart-services.sh
    ```

