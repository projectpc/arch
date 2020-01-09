#!/bin/bash

username=$1

su $username -c "echo '[Layout]
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
Use=true' > /home/$username/.config/kxkbrc"
