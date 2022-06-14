# Start X if running on VT1
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    # Ideally, X would be started after both the /etc/profile and ~/.profile
    # invocations so the PATH would be correct for everything running in X.
    # However, since we're starting X from /etc/profile it's necessary to first
    source ~/.profile
    exec startx
fi
