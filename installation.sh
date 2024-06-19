#!/bin/sh

doas wipefs -a /dev/nvme0n1
doas sfdisk /dev/nvme0n1 <<EOF
label: gpt
name=esp, size=120M, type="EFI System"
name=root
name=root
EOF
doas mkfs.vfat /dev/nvme0n1p1
doas mkfs.xfs /dev/nvme0n1p2
doas mkfs.xfs /dev/nvme0n1p3
doas mkdir /media/root
doas mkdir /media/home
doas mount /dev/nvme0n1p2 /media/root
doas mount /dev/nvme0n1p3 /media/home
doas mkdir -p /media/root/boot/efi
doas mount /dev/nvme0n1p1 /media/root/boot/efi
doas chmod 755 /media/root
chimera-bootstrap -l /media/root
chimera-chroot /media/root
apk update
apk upgrade --available
apk fix
apk add linux-lts grub-x86_64-efi
genfstab -t PARTLABEL / > /etc/fstab
passwd root
useradd hoxton
passwd hoxton
usermod -a -G wheel hoxton
echo hoxton > /etc/hostname
ln -sf ../usr/share/zoneinfo/Europe/Moscow /etc/localtime
dinitctl -o enable gdm
dinitctl -o enable chrony
dinitctl -o enable networkmanager
update-initramfs -c -k all
grub-install --efi-directory=/boot/efi
update-grub
exit
reboot
