# Part 1
clear; echo; echo "Welcome to hotsno's Arch Linux installer!"
echo; echo "NOTE: This script was created with the following assumptions:"
echo "- You are planning to dual-boot with Windows"
echo "- Your Windows and Linux install will live on the same drive"
echo "- You have unallocated space on that drive (if not, first shrink your C:\ drive in Windows)"
echo; echo "(Press ENTER to continue)"
read

echo; echo "Choose a username: "
read username

echo "Choose a password: "
read password

echo "Choose a hostname: "
read hostname

clear; lsblk
echo; echo "Choose the drive to partition (ex. nvme0n1): "
read drive
echo; echo "Create an ext4 (Linux file system) and a SWAP partition"
echo; echo "(Press ENTER to continue)"
read
cfdisk /dev/$drive

clear; sleep 1; sudo fdisk -l
echo; echo "NOTE: You should be able to reuse the Windows EFI parition"
echo; echo "Choose the EFI partition (ex. nvme0n1p1): "
read efi_part

clear; lsblk
echo; echo "Choose the SWAP partition (ex. nvme0n1p5): "
read swap_part

echo; echo "Choose the root Linux partition (ex. nvme0n1p6): "
read linux_part

curl -Is https://www.google.com | head -1 | grep 200 >/dev/null
if [[ $? -ne 0 ]]; then
    echo "Enter WiFi name: "
    read wifi_name
    echo "Enter WiFi password: "
    read wifi_pw
    echo; echo "Connecting to Wi-Fi..."
    iwctl station wlan0 connect $wifi_name --passphrase $wifi_pw
fi

clear

mkswap /dev/$swap_part
swapon /dev/$swap_part

mkfs.ext4 /dev/$linux_part
mount /dev/$linux_part /mnt

cat <<EOF > install_vars
username="$username"
password="$password"
hostname="$hostname"
drive="$drive"
efi_part="$efi_part"
swap_part="$swap_part"
linux_part="$linux_part"
wifi_name="$wifi_name"
wifi_pw="$wifi_pw"
EOF

cat install_vars <(sed '1,/^# Part 2$/d' `basename $0`) > /mnt/install-part-2.sh
chmod +x /mnt/install-part-2.sh
cat install_vars <(sed '1,/^# Part 3$/d' `basename $0`) > /mnt/install-part-3.sh

rm install_vars

pacman -Sy pacman-contrib --noconfirm

clear; echo "Ranking pacman mirrors..."
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware \
    grub efibootmgr os-prober \
    xorg-server xorg-xinit libx11 libxft libxinerama freetype2 fontconfig noto-fonts noto-fonts-cjk \
    mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver mesa-vdpau \
    pipewire pipewire-alsa wireplumber pipewire-pulse pipewire-jack \
    networkmanager sudo vim git pacman-contrib firefox man-db man-pages xorg-xrandr \
    zsh python obs-studio eza scrot zip stow picom feh wget

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ./install-part-2.sh

clear; echo; echo "Rebooting in 5 seconds..."
sleep 5
reboot

# Part 2
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $hostname > /etc/hostname

echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.0.1       $hostname.localdomain $username" >> /etc/hosts

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
mkdir /boot/efi
mount /dev/$efi_part /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

useradd -m -G wheel -s /usr/bin/zsh $username
echo $username:$password | chpasswd

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "sh /install-part-3.sh" > /home/$username/.zshrc

rm /install-part-2.sh

exit

# Part 3
clear

rm .bash*
sudo rm .zshrc

wget -q --spider https://google.com
if [ $? -ne 0 ]; then
    nmtui
    clear
fi

sudo pacman -Syu --noconfirm

mkdir dev dox pix dl media

git clone https://github.com/hotsno/wallpapers pix/wall

git clone https://github.com/hotsno/dotfiles .dotfiles
(cd .dotfiles && stow --no-folding .)

pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
(cd yay-bin && yes | makepkg -si)
rm -rf yay-bin

yes | yay -S ttf-twemoji ttf-meslo-nerd-font-powerlevel10k
sudo ln -sf /usr/share/fonctconfig/conf.avail/75-twemoji.conf /etc/fonts/conf.d/75-twemoji.conf

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

xdg-settings set default-web-browser firefox.desktop

systemctl --user --now enable pipewire pipewire-pulse wireplumber

git clone https://github.com/hotsno/dwm ~/.config/dwm
sudo make -C ~/.config/dwm install

git clone https://github.com/hotsno/st ~/.config/st
sudo make -C ~/.config/st install

git clone https://github.com/hotsno/dmenu ~/.config/dmenu
sudo make -C ~/.config/dmenu install

sudo rm /install-part-3.sh

clear; echo; echo "All done! After a few seconds, you will automatically be logged out..."
echo "After logging back in, just run the "startx" command to enter dwm!"
sleep 10

loginctl kill-user $(whoami)