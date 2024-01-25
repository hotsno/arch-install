#part1
wifi_name=""
wifi_pw=""

echo "Welcome to hotsno arch-install!"
echo "Installing some packages..."
pacman -Sy pacman-contrib --noconfirm

echo "Connecting to Wi-Fi..."
iwctl --passphrase $wifi_pw station wlan0 connect $wifi_name

lsblk
echo "Choose a drive: "
read drive
cfdisk $drive

lsblk
echo "Choose the swap partition: "
read swap_part
mkswap $swap_part
swapon $swap_part

echo "Choose the Linux partition: "
read linux_part
mkfs.ext4 $linux_part
mount $linux_part /mnt

echo "Ranking pacman mirrors..."
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' `basename $0` > /mnt/install-2.sh
chmod +x /mnt/install-2.sh

arch-chroot /mnt ./install-2.sh

exit

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
echo "127.0.0.1       $hostname.localdomain hotsno" >> /etc/hosts

echo "Installing some packages..."
pacman -Sy grub efibootmgr os-prober sudo --noconfirm

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
mkdir /boot/efi
lsblk
echo "Choose the EFI partition: "
read efi_part
mount $efi_part /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

useradd -m -G wheel $username
passwd $username

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

install_3_path=/home/$username/install-3.sh
sed '1,/^#part3$/d' install-2.sh > $install_3_path
chown $username:$username $install_3_path
chmod +x $install_3_path

exit

#part3
nmtui

sudo pacman -Syu --noconfirm

sudo pacman -S xorg-server xorg-xinit libx11 libxft libxinerama freetype2
git clone https://git.suckless.org/dwm
cd dwm
make
sudo make clean install
cd ..

git clone https://git.suckless.org/st
cd st
make 
sudo make clean install
cd ..

echo "exec dwm" > ~/.xinitrc

startx