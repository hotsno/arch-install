# arch-install
Arch installer script

> [!IMPORTANT]  
> While I tried to keep this free of hard-coded strings and the like, this is mainly meant for personal use

## Requirements
- Windows is already installed
- Windows and Linux will live on the same drive
- You have unallocated space on that drive
    - If not, first shrink your C:\ drive in Windows using Disk Management
- Intended for systems w/ AMD GPUs


## Post-install

<details>
<summary>GitHub SSH keys</summary>
<br>

### Generate and add SSH key
```sh
mkdir "$XDG_CONFIG_HOME/ssh"
ssh-keygen -t ed25519 -C "71658949+hotsno@users.noreply.github.com" -N "" -f "$XDG_CONFIG_HOME/ssh/github-hotsno"
eval "$(ssh-agent -s)"
ssh-add "$XDG_CONFIG_HOME/ssh/github-hotsno"
cat "$XDG_CONFIG_HOME/ssh/github-hotsno.pub" | wl-copy
xdg-open "https://github.com/settings/keys"
# Click "New SSH key" and paste
```

### Create SSH alias (so you don't have to use `git@github.com`)

You can do this so you can type `gh` instead of `git@github.com`

Add the following to `$XDG_CONFIG_HOME/ssh/config`:
```
Host *
    UserKnownHostsFile=~/.config/ssh/known_hosts
Host gh
    HostName github.com
    User git
    IdentityFile ~/.config/ssh/github-hotsno
```

</details>
