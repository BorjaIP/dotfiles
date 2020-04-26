#!/bin/sh

#                 ___    ___ ___  _________  ___  __________
#                |\  \  /  /|\  \|\   ___  \|\  \|\___   ___\
#                \ \  \/  / | \  \ \  \\ \  \ \  \|___ \  \_|
#                 \ \    / / \ \  \ \  \\ \  \ \  \   \ \  \
#                  /     \/   \ \  \ \  \\ \  \ \  \   \ \  \
#                 /  /\   \    \ \__\ \__\\ \__\ \__\   \ \__\
#                /__/ /\ __\    \|__|\|__| \|__|\|__|    \|__|
#                |__|/ \|__|


# Executed by startx (run your window manager from here)

# I use LightDm as a Display Manager all the commands
# when start graphical environment are in xprofile.
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# If use a xinit uncomment this line
# exec awesome

