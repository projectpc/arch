#!/bin/bash

hostname="Arch"
username="anton"
localname1="ru_RU.UTF-8 UTF-8"
localname2="en_US.UTF-8 UTF-8"
languageSistem='LANG="ru_RU.UTF-8"'
rootPass=200583
userPass=200583

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true

echo 'Форматирование дисков'
mkfs.ext4 -F /dev/sda1 -L root
mkswap /dev/sda2 -L swap
#mkfs.ext4 -F /dev/sda2 -L home
#mkfs.ext4 -F /dev/sda3 -L data
echo 'Монтирование дисков'
mount /dev/sda1 /mnt
swapon /dev/sda2
#mkdir /mnt/home
#mount /dev/sda2 /mnt/home
echo 'Выбор зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
 
echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl
 
echo 'Создаем fstab'
genfstab -pU /mnt >> /mnt/etc/fstab
 
arch-chroot /mnt sh -c "
echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
 
echo 'Добавляем локали системы'
echo $localname1 > /etc/locale.gen
echo $localname2 >> /etc/locale.gen
 
echo 'Обновим текущую локаль системы'
locale-gen
 
echo 'Указываем язык системы'
echo $languageSistem > /etc/locale.conf
 
echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
 
echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux
 
echo 'Устанавливаем загрузчик'
pacman -Syy
pacman -S grub --noconfirm
grub-install /dev/sda
 
echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg
 
 
echo 'Ставим программу для Wi-fi'
pacman -S dialog wpa_supplicant --noconfirm
 
echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username
echo $username:$userPass | chpasswd
 
echo 'Создаем root пароль'
echo root:$rootPass | chpasswd
 
echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
 
echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
 
echo 'Ставим иксы и драйвера'
pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm
#echo 'KDE ставим'
#pacman -Sy plasma-meta kdebase sddm sddm-kcm --noconfirm
#systemctl enable sddm
echo 'Ставим XFCE'
pacman -S xfce4 lxdm --noconfirm
#xfce4-goodies
systemctl enable lxdm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm
 
echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm
 
echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager
 
echo 'Установка завершена '
read -p 'нажми Enter для перезагрузки'
reboot
"
