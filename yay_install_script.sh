#!/bin/bash
username=$1
su $username -c 'mkdir ~/Downloads'
su $username -c 'cd ~/downloads'
echo 'Установка AUR (yay)'
su $username -c 'sudo pacman -Syu'
su $username -c 'sudo pacman -S wget --noconfirm'
su $username -c 'wget git.io/yay-install.sh && sh yay-install.sh --noconfirm' 
