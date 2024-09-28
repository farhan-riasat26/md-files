# Images
- To list down all images
    ```bash
    docker images
    ```
- To inspection the image

    ```bash
    docker image inspect image_id
    ```
- To name the images (`-t`) there are 1 parameters seprated with `:` name which means repo and tag which identify the versioning

    ```bash
    docker build -t name:tag .
    ```
    - this command is used to create an image along with name and tag

- To rename the image use

    ```bash
    docker tag old_name:old:tag new_name:new_tag
    ```
    - This makes a clone of old image

- `rmi` flag is used to remove images
    ```bash
    docker rmi image_hash
    ```

- to delete all images

    ```bash
    docker image prune -a
    ```
# Containers
## Simple Definition:
- Container is snapshot of an image.

    -  Explanation:

        Snapshot means capturing something in that state in which it is. When we capturing something like multiple times in different state it creates an album every state has its unique identity (hash or name). we can start every container stop and access their shells
## Traditional Defination:

- A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.

1- Lightweight:

- Containers share the host system's operating system (typically Linux or Windows), so they don't require a full OS instance for each application. This makes them more efficient and lightweight compared to virtual machines.

2- Portable:
- Docker containers can run consistently across different environments (development, staging, production, etc.). Whether you're deploying on your local machine, a cloud provider, or a data center, the containerized application will behave the same way.

3- Isolated:

- Each container runs in its own isolated environment, meaning it has its own file system, processes, network interfaces, and resources. This isolation ensures that containers do not interfere with each other.

4- Immutable:

- Once a Docker container is created from an image, it doesn’t change unless explicitly modified. If you need to update the application, you typically create a new container with an updated image, rather than modifying the running container.

5- Ephemeral:

- Containers are designed to be stateless and temporary. If a container is stopped or destroyed, it can be easily replaced by starting a new one from the same image. Persistent data should be stored outside the container using volumes or external storage.

6- Resource Efficient:

- Containers use system resources like CPU and memory more efficiently compared to virtual machines because they don’t require a full OS. Docker containers share the host OS kernel, allowing them to run multiple containers on a single machine with minimal overhead.

- To check the running containers

    ```bash
    docker ps
    ```
  To check all containers use `-a` flag it shows you all containers weather it is in run or stop state

- To run the new container

    ```bash
    docker run image_name/image_id
    ```
- Run the stop one

    ```bash
    docker start container_name
    ```
    - By Default run is in attach mode and start is in detach mode
    - `-a` for attach mode and `-d` for detach

- <span style="color: red;">Remember</span> using this command you can't able to ping the project because you have to map the docker port with local port

    ```bash
    docker run -p local_port:docker_port image_name/image_id
    docker start -p local_port:docker_port container_name
    ```
    - **-d** used of detach mode.

- After detach mode you can't see the logs or prints by using

    ```bash
    docker attach container_name
    ```

- For checking previous logs using
    ```bash
    docker logs container_name
    ```

- Some Times we want to interact our docker container `-i` flag is used for that and If I want to interact with terminal `-t` flag is used we can combine them `-it`
- `rm` flag for removing container running container can not be removed. if we give rm flag with start command it deletes that container when It stopped (`--rm`)

- `cp` flag is to copy files into container or from container

    ```bash
    docker cp source_file/path/folder container_name:destination_path
    ```
    - This copy files into docker container

    ```bash
    docker cp container_name:source_file_path local_folder/destination
    ```

- Named the docker container

    ```bash
    docker run -p local_port:image_port -d --rm --name container_custom_name image_id
    ```
- Named the volume of docker container

    ```bash
    docker run -p local_port:image_port -d --rm --name container_custom_name -v name_volume:/path-to-be-mount image_id
    ```