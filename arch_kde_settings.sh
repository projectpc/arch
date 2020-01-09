#!/bin/bash

username=$1
echo  "username : "
echo  $username
echo  "0 " $0
echo  "1" $1
echo  "--------------------- "
####################################################
#            Настройка системы                     #
####################################################
#Добавляю русский язык и смену раскладки alt->shift
su $username -c "echo '[Layout]
DisplayNames=,
LayoutList=us,ru
LayoutLoopCount=-1
Model=pc101
Options=grp:alt_shift_toggle
ResetOldOptions=true
ShowFlag=true
ShowLabel=false
ShowLayoutIndicator=true
ShowSingle=true
SwitchMode=Global
Use=true' > /home/$username/.config/kxkbrc"

#Авто логин
su $username -c "sudo  mkdir -p /etc/sddm.conf.d/"
su $username -c "sudo printf '[Autologin]
User=%s
Session=plasma.desktop' $username >/etc/sddm.conf.d/autologin.conf"
