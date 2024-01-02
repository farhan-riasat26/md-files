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
    apt install php${PHP_VERSION} php${PHP_VERSION}-{bcmath,cli,common,curl,imagick,imap,intl,fpm,gd,json,ldap,mbstring,mysql,opcache,pdo,tidy,xml,xmlrpc,zip}
    ```
    