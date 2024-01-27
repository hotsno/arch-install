#part1
wifi_name=""
wifi_pw=""

echo -e "\n\nWelcome to hotsno arch-install!\n\n\n"
sleep 1

echo -e "\n\nConnecting to Wi-Fi...\n\n\n"
iwctl --passphrase $wifi_pw station wlan0 connect $wifi_name

pacman -Sy pacman-contrib --noconfirm

lsblk
echo -e "\nChoose a drive (ex. nvme0n1): "
read drive
cfdisk /dev/$drive

echo -e "\n"
sleep 1
lsblk
echo -e "\nChoose the swap partition (ex. nvme0n1p5): "
read swap_part
mkswap /dev/$swap_part
swapon /dev/$swap_part

echo -e "\n"
lsblk
echo -e "\nChoose the Linux partition (ex. nvme0n1p6): "
read linux_part
mkfs.ext4 /dev/$linux_part
mount /dev/$linux_part /mnt

echo -e "\n\nRanking pacman mirrors...\n\n\n"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

echo -e "\n\nRunning pacstrap...\n\n\n"
pacstrap /mnt base base-devel linux linux-firmware \
    grub efibootmgr os-prober \
    xorg-server xorg-xinit libx11 libxft libxinerama freetype2 fontconfig noto-fonts noto-fonts-cjk \
    mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver mesa-vdpau \
    pipewire pipewire-alsa wireplumber pipewire-pulse pipewire-jack \
    networkmanager sudo vim git pacman-contrib firefox man-db man-pages xorg-xrandr \
    zsh python obs-studio eza scrot zip stow picom feh

genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' `basename $0` > /mnt/install-2.sh
chmod +x /mnt/install-2.sh

arch-chroot /mnt ./install-2.sh

systemctl reboot

#part2
hostname=""
username=""

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
lsblk
echo "Choose the EFI partition (ex. nvme0n1p1): "
read efi_part
mount /dev/$efi_part /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

useradd -m -G wheel -s /usr/bin/zsh $username
echo -e "\n\nEnter password for $username: "
passwd $username

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

install_3_path=/home/$username/install-3.sh
sed '1,/^#part3$/d' install-2.sh > $install_3_path
chown $username:$username $install_3_path
chmod +x $install_3_path

rm /install-2.sh

exit

#part3
rm -rf .bash*
nmtui

sudo pacman -Syu --noconfirm

mkdir dev dox pix dl media

git clone https://github.com/hotsno/wallpapers $HOME/pix/wall

git clone https://github.com/hotsno/dotfiles $HOME/.dotfiles
cd .dotfiles
stow --no-folding .
cd ..

pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
yes | makepkg -si
cd ..
rm -rf yay

yes | yay -S ttf-twemoji ttf-meslo-nerd-font-powerlevel10k
sudo ln -sf /usr/share/fonctconfig/conf.avail/75-twemoji.conf /etc/fonts/conf.d/75-twemoji.conf

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

xdg-settings set default-web-browser firefox.desktop

systemctl --user --now enable pipewire pipewire-pulse wireplumber

mkdir .config
cd .config

git clone https://github.com/hotsno/dwm
cd dwm
sudo make clean install
cd ..

git clone https://github.com/hotsno/st
cd st
sudo make clean install
cd ..

git clone https://github.com/hotsno/dmenu
cd dmenu
sudo make clean install
cd ~

rm ~/install-3.sh

exit