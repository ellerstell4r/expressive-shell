#!/bin/sh
picom --config ~/.config/picom/picom.conf &
xrdb -merge ~/.Xresources
exec awesome
