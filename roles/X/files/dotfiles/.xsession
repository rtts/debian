nm-applet &
oclock -transparent -bd white -fg white -geometry 30x30-2+0 &
stalonetray --geometry 1x1+0+0 --icon-gravity NW --grow-gravity W --transparent true &
x-terminal-emulator &
exec xmonad
