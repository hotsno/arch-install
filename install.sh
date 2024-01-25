#part1
wifi_name=""
wifi_pw=""

echo -e "\n\nWelcome to hotsno arch-install!\n\n\n"
sleep 1

echo -e "\n\nConnecting to Wi-Fi...\n\n\n"
iwctl --passphrase $wifi_pw station wlan0 connect $wifi_name

echo -e "Installing some packages...\n\n\n"
pacman -S pacman-contrib --noconfirm
pacman -S grub efibootmgr os-prober --noconfirm
pacman -S xorg-server xorg-xinit libx11 libxft libxinerama freetype2 fontconfig ttf-dejavu --noconfirm
pacman -S sudo vim git --noconfirm

lsblk
echo -e "\nChoose a drive: "
read drive
cfdisk /dev/$drive

echo -e "\n"
sleep 1
lsblk
echo -e "\nChoose the swap partition: "
read swap_part
mkswap /dev/$swap_part
swapon /dev/$swap_part

echo -e "\n"
lsblk
echo -e "\nChoose the Linux partition: "
read linux_part
mkfs.ext4 /dev/$linux_part
mount /dev/$linux_part /mnt

echo -e "\n\nRanking pacman mirrors...\n\n\n"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

echo -e "\n\nRunning pacstrap commands...\n\n\n"
pacstrap /mnt base base-devel linux linux-firmware networkmanager
pacstrap /mnt grub efibootmgr os-prober
pacstrap /mnt xorg-server xorg-xinit libx11 libxft libxinerama freetype2 fontconfig ttf-dejavu
pacstrap /mnt sudo vim git

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

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
mkdir /boot/efi
lsblk
echo "Choose the EFI partition: "
read efi_part
mount /dev/$efi_part /boot/efi
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

git clone https://git.suckless.org/dwm
cd dwm
sudo make clean install
cd ..

git clone https://git.suckless.org/st
cd st
sudo make clean install
cd ..

echo "exec dwm" > ~/.xinitrc

startx