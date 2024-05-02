#!/usr/bin/bash

set -o xtrace

ln -s /usr/bin/fakeroot /usr/local/bin/sudo

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
sed -i 's/SigLevel    = Required DatabaseOptional/SigLevel = Never/g' /etc/pacman.conf
sed -i 's/#IgnorePkg   =/IgnorePkg = filesystem/g' /etc/pacman.conf
sudo pacman --noconfirm -Suy
sudo pacman -S --noconfirm --overwrite '/*' fakeroot
sudo pacman -S --noconfirm base-devel sssd bash-completion man nano htop git

sed -i 's/passwd: files systemd/passwd: files systemd sss/g' /etc/nsswitch.conf
sed -i 's/group: files \[SUCCESS=merge\] systemd/group: files \[SUCCESS=merge\] systemd sss/g' /etc/nsswitch.conf
sed -i 's/shadow: files systemd/shadow: files systemd sss/g' /etc/nsswitch.conf

rm -rf /var/cache

touch /var/preconfigured
