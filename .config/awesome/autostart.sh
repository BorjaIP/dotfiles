#!/usr/bin/env bash

## run (only once) processes which spawn with the same name
function run {
    if (command -v $1 && ! pgrep $1); then
        $@&
    fi
}

# Keystore
if (command -v gnome-keyring-daemon && ! pgrep gnome-keyring-d); then
    gnome-keyring-daemon --daemonize --login &
fi

# PulseAudio
if (command -v start-pulseaudio-x11 && ! pgrep pulseaudio); then
    start-pulseaudio-x11 &
fi

# Use Polkit for controlling system-wide privileges
if (command -v /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 && ! pgrep polkit-mate-aut) ; then
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &
fi

# Power manager
if (command -v  xfce4-power-manager && ! pgrep xfce4-power-man) ; then
    xfce4-power-manager &
fi

# Printer
if (command -v system-config-printer-applet && ! pgrep applet.py ); then
    system-config-printer-applet &
fi

# Mouse control
if (command -v ratbagd && ! pgrep ratbagd); then
    start-ratbagd
fi

run nm-applet           # Network monitor
run compton -b          # Blur and transparency
run light-locker        # Locker for DM
# run pa-applet         # PulseAudio control applet
# run blueman-applet    # Bluetooth control
# run msm_notifier      # Notifications
# run xfsettingsd

