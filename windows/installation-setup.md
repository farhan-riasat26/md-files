# Prerequisites of windows installation
- Windows 10 or later
- 64-bit processor
- Partition scheme: GPT `diskpart` `list disk`
- Secure Boot: Enabled
- Disk size: 250 GB or more
- RAM: 8 GB or more

## During windows installation
- You have to create 2 disks: one for windows `150`GB and one other `100`GB

## After windows installation
- Make Some dirs in your `D://` Drive <span style="color: red;">**Case Sensitive**.</span>
  ```
  D:\Extras\Instructions
  D:\Extras\Keys
  D:\Work
  D:\VM
  ```
- Software list:
    - [ ] [Google Chrome](https://www.google.com/chrome/)
    - [ ] [Putty](https://www.putty.org/)
    - [ ] [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/)
    - [ ] [VS Code System Installer](https://code.visualstudio.com/download)
    - [ ] [Notepad++](https://notepad-plus-plus.org/downloads/)
    - [ ] [Git bash](https://git-scm.com/downloads)
    - [ ] [Filezilla Client](https://filezilla-project.org/)
    - [ ] [Host File Editor](https://hostsfileeditor.com/)
    - [ ] [Postman](https://www.postman.com/)
    - [ ] [Winrar](https://www.win-rar.com/start.html?&L=0)

  ### Git Installation
    - During installation make sure to select `Use Notepad++ as default editor` and `Use Git from Git Bash only`

      ![git-installation-step-1.png](..%2Fimage%2Fgit%2Fgit-installation-step-1.png)
    - And then make sure to select base branch name as `main` instead of `master`

      ![git-installation-step-2.png](..%2Fimage%2Fgit%2Fgit-installation-step-2.png)
    - During installation make sure you select CRLF conversion into LF

      ![git-installation-step-3.png](..%2Fimage%2Fgit%2Fgit-installation-step-3.png)
    - Use Git only ever Fast-Forward

      ![git-installation-step-4.png](..%2Fimage%2Fgit%2Fgit-installation-step-4.png)
    - During Configuring extra options make sure enabled both checks

      ![git-installation-step-5.png](..%2Fimage%2Fgit%2Fgit-installation-step-5.png)
    - And all others as default

  ### Putty Setup
    - For pageant load on start up press `windows + R` and type `shell:startup`
    - Copy pageant shortcut from its file location and paste into startup folder
    - Now open puttygen and generate yours `ssh-rsa` key by clicking on generate button

      ![key-generation.png](../image/putty/key-generation.png)
    - It's a good practice to use key comment as your system names
    - Must added a key phrase cause it's your private key and save it as `Save as private key` for saving select path `D:\Extras\Keys`
    
