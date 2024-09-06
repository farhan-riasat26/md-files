# Python Installation

- For Windows
    - [ ] [Download Python](https://www.python.org/downloads/)
    - Install python version manager
        ```bash
        pip install pyenv-win
        ```
    - In PowerShell <span style="color: red;">**as administrator**</span>
        ```powershell
        Invoke-WebRequest -UseBasicParsing https://pyenv-win.github.io/pyenv-win/install.ps1 | Invoke-Expression
        ```
    - Install version `pyenv install version`

    - set `global` python version
        ```bash
        pyenv global version
        ```
        - for local use `local`
    - you can use `py -version -m venv env` for version specific environment

- For Linux
    `pre Installed`
    - Version Control install `pyenv`

        ```bash
        curl https://pyenv.run | bash
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
        ```
    - restart terminal `source ~/.bashrc`


