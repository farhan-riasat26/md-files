# SSL Certification Using Certbot
- Install snapd First

    ```bash
    apt update
    apt install snapd
    snap install core; snap refresh core
    ```

- Install certbot

    ```bash
    snap install --classic certbot
    ```
- Make a Symbolic link

    ```bash
    ln -s /snap/bin/certbot /usr/bin/certbot
    ```

- Check It's version

    ```bash
    certbot --version
    ```

- Make Dir for custom Hooks

    ```bash
    mkdir -p /etc/letsencrypt/custom-hook
    ```
- Download Python file

    ```bash
    wget https://raw.githubusercontent.com/joohoi/acme-dns-certbot-joohoi/master/acme-dns-auth.py && sed -i 's/python/python3/g' acme-dns-auth.py && mv acme-dns-auth.py /etc/letsencrypt/custom-hook
    ```

- Create Certificate

    ```bash
    certbot certonly --agree-tos --email faree.one5@gmail.com --no-eff-email --renew-by-default --manual --manual-auth-hook /etc/letsencrypt/custom-hooks/acme-dns-auth.py --preferred-challenges dns --debug-challenges -d dogs-collar.com -d *.domain-name
    ```

## Reference
- https://github.com/joohoi/acme-dns-certbot-joohoi
- https://roadmap.sh/guides/setup-and-auto-renew-ssl-certificates