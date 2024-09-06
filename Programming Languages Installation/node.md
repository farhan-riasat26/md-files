# Node Installation

- Windows
    - [ ] [download exe file](https://coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe)
    - Confirm Installation by using `nvm` in CMD.
    - `nvm list` to list down installed versions of node
    - For stable use `nvm install lts`
    - if you want to use newest version `nvm use newest`
    - for any version use `nvm install version-name` and for its selection nvm use `version-name`
    -  Remember after <span style="color: red;">**changing the version**</span> install global packages again like yarn and pnpm

- Linux OR WSL
    ```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    ```
    -
    ```bash
    export NVM_DIR="$HOMEPath/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    ```
    - For stable use `nvm install --lts`
## Resources

### For windows
- https://hostsfileeditor.com/
- https://github.com/coreybutler/nvm-windows?tab=readme-ov-file

### For linux
- https://github.com/nvm-sh/nvm