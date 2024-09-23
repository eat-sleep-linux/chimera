#!/bin/sh

doas wipefs -a /dev/nvme0n1
doas sfdisk /dev/nvme0n1 <<EOF
label: gpt
name=esp, size=1G, type="EFI System"
name=root, size=30G
name=home
EOF
doas mkfs.vfat /dev/nvme0n1p1
doas mkfs.xfs -f /dev/nvme0n1p2
doas mkfs.xfs -f /dev/nvme0n1p3
doas mkdir /media/root
doas mount /dev/nvme0n1p2 /media/root
doas mkdir -p /media/root/boot
doas mkdir -p /media/root/home
doas mount /dev/nvme0n1p1 /media/root/boot
doas mount /dev/nvme0n1p3 /media/root/home
doas chmod 755 /media/root
doas chimera-bootstrap -l /media/root
doas chimera-chroot /media/root
apk update
apk upgrade --available
apk fix
apk add linux-stable systemd-boot
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
bootctl install --esp-path=/boot
gen-systemd-boot
exit
reboot
