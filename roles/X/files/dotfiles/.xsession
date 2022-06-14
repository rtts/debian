nm-applet &
oclock -transparent -bd white -fg white -geometry 30x30-2+0 &
trayer --edge top --widthtype request --align left --transparent true --alpha 255 &
x-terminal-emulator &
exec xmonad
