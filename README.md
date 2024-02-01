# arch-install

> [!NOTE]  
> While I tried to keep this free of hard-coded strings and such, this is mainly meant for personal use

## (Intended) Requirements
- Windows is already installed
- Windows and Linux will live on the same drive
- AMD GPU

## Usage

1. Download an Arch `.iso` from [Arch Linux Downloads](https://archlinux.org/download/) (e.g. `archlinux-2024.01.01-x86_64.iso`)
2. Use [Rufus](https://rufus.ie/en/) to [burn](https://chat.openai.com/share/bc24dc4d-a928-4615-8123-86dad0c3085f) the `.iso` to a USB stick
3. Use Disk Management to [shrink](https://chat.openai.com/share/82ce0557-0003-41f1-89fd-6041f6239885) the Windows partition
4. [Boot](https://chat.openai.com/share/44683835-848e-4a75-9c36-89229807b2c7) from the USB stick
5. Run the installer with: `curl -sSL https://raw.githubusercontent.com/hotsno/arch-install/main/install.sh | sh`
6. If you mess up on any of the inputs, spam `Ctrl-C`!


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

### Create SSH alias

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
