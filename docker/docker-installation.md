# Docker Installation
- <span style="color: red;">Some Important points are to be discussed. Docker have 2 setups one for old versions and another for new ones</span>
    - <span style="color: green;"><u>**Docker Toolbox**</u></span>:

        1- VirtualBox-Based:

        Docker Toolbox uses Oracle’s VirtualBox to create a Linux virtual machine (VM) where Docker runs. This is necessary because Docker relies on Linux containers, and Windows or macOS didn’t initially support them natively.

        2- Limited Support:

        Docker Toolbox is intended for older systems that don’t support Hyper-V (Windows) or HyperKit (macOS). These are older operating systems, such as Windows 7 and earlier macOS versions, which couldn’t run Docker natively.

        3- Manual Setup:

        Docker Toolbox requires more manual setup and configuration. You need to install Docker Machine, Docker CLI, and VirtualBox manually.

        4- No Native Docker Integration:

        Docker Toolbox doesn't integrate natively with Windows or macOS, meaning that it lacks some of the seamless user experience and optimization that Docker Desktop provides, such as shared file systems or native Docker volume management.

    - <span style="color: green;"><u>**Docker Desktop**</u></span>:

        1- Native Hypervisor Support:

        Docker Desktop uses Hyper-V on Windows or HyperKit on macOS, allowing Docker containers to run natively on the host operating system without requiring a virtual machine like VirtualBox.

        2- Better Performance:

        Because Docker Desktop integrates natively with the operating system, it offers much better performance compared to Docker Toolbox. There’s no need for an additional VM layer (like in Docker Toolbox), which reduces overhead.

        3- Seamless OS Integration:

        Docker Desktop integrates directly with Windows Subsystem for Linux 2 (WSL2) on Windows and with macOS, making the Docker experience smoother. This includes things like native volume management, filesystem access, and resource allocation.

    | Feature  | Docker Toolbox | Docker Desktop |
    | :------------ |:-----------------| :-----|
    | Virtualization | Uses VirtualBox (non-native) | Uses Hyper-V or HyperKit (native) |
    | Supported OS | Older OS (Windows 7/macOS Sierra) |   Modern OS (Windows 10+/macOS Mojave+) |
    | Performance | Lower, due to VM overhead |	Higher, with native hypervisor support |
    | Ease of Use | Manual setup and command-line based |    GUI with easier setup and management |
    | Kubernetes Support | 	No |    Yes |
    | Resource Management | Limited |    Advanced resource allocation options |
    | Updates | Deprecated, no updates |    Actively maintained and regularly updated |
    | Docker Integration | Not seamless (no native support) |    Native integration with the OS |
## [Windows Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)

- Make Sure Virtualization is ON
- Turn on WSL 2 feature on Windows

## [MAC Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)

- Drag setup to Applications

## [Docker for ubuntu server 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
- Server does not have docker desktop