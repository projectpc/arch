#!/bin/bash

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true
####################################################
#            установка переменных                  #
####################################################
hostname="Arch"                                    #
username="anton"                                   #
localname1="ru_RU.UTF-8 UTF-8"                     #
localname2="en_US.UTF-8 UTF-8"                     #
languageSistem='LANG="ru_RU.UTF-8"'                #
rootPass=200583                                    #
userPass=200583                                    #
####################################################

#################################################################################################
#            Разбиваю в ручную и  прописываю свою разметку                                       #
#################################################################################################
echo 'Форматирование дисков'                                                                    #
mkfs.ext4 -F /dev/sda1 -L root                                                                  #
mkfs.ext4 -F /dev/sda2 -L home                                                                  #
mkfs.ext4 -F /dev/sda3 -L data                                                                  #
echo 'Монтирование дисков'                                                                      #
mount /dev/sda1 /mnt                                                                            #
mkdir /mnt/home                                                                                 #
mount /dev/sda2 /mnt/home                                                                       #
mkdir /mnt/date                                                                                 #
mount /dev/sda3 /mnt/date                                                                       #
#################################################################################################
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
echo groupadd sudo
echo usermod -a -G sudo $username
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
echo '$username ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
 
echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
 
echo 'Ставим иксы и драйвера'
pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm
echo 'KDE ставим'
pacman -Sy plasma-meta kdebase kde-gtk-config breeze-gtk sddm sddm-kcm --noconfirm
echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm
 
echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable sddm
systemctl enable NetworkManager

pacman -S gimp  mousepad

read -p 'Переход на пользователя нажми Enter'
su $username
read -p 'Ну че перешол ?  нажми Enter
read -p 'Ну че перешол ?  нажми Enter
sudo pacman -Sy blueberry bluez bluez-libs bluez-utils pulseaudio-bluetooth --noconfirm
sudo systemctl enable bluetooth
sudo pacman -S gvfs gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mtpfs thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman udiskie udisks2 chromium

####################################################
#            Настройка системы                     #
####################################################
#Добавляю русский язык и смену раскладки alt->shift
echo '[Layout]
DisplayNames=,
LayoutList=us,ru
LayoutLoopCount=-1
Model=pc101
Options=grp:alt_shift_toggle
ResetOldOptions=true
ShowFlag=true
ShowLabel=true
ShowLayoutIndicator=true
ShowSingle=false
SwitchMode=Global
Use=true' > /home/$username/.config/kxkbrc

#Авто логин
sudo mkdir -p /etc/sddm.conf.d/
sudo printf "[Autologin]
User=%s
Session=plasma.desktop" $username >/etc/sddm.conf.d/autologin.conf












echo 'Установка завершена '
read -p 'нажми Enter для перезагрузки'
reboot
"
