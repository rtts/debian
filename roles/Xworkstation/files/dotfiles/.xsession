# xss-lock locks the screen on suspend (it should also lock when the
# screensaver is triggered, but that doesn't work, unfortunately)
xss-lock xtrlock &

# xautolock locks the screen after inactivity (as a workaround for the
# failing xss-lock)
xautolock -locker xtrlock -time 5 &

nm-applet &
oclock -transparent -bd white -fg white -geometry 30x30-2+0 &
trayer --edge top --widthtype request --align left --transparent true --alpha 255 &
x-terminal-emulator &
exec xmonad
