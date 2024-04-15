# Installing Docker
## Step -1
- Update Packages

    ```bash
    apt update
    ```

- Packages that will use over HTTPS
    ```bash
    apt install apt-transport-https ca-certificates curl software-properties-common
    ```

- GPG key
    ```bash
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    ```

- Docker Repository
    ```bash
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    ```

- Make sure you are about to install from the Docker repo instead of the default Ubuntu repo
    ```bash
    apt-cache policy docker-ce
    ```

- Install Docker
    ```bash
    apt install docker-ce
    ```

- Check Status
    ```bash
    systemctl status docker
    ```