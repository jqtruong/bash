#!/bin/bash

IN="LVDS1"
EXT="DP1"

if (xrandr | grep "$EXT disconnected"); then
    xrandr --output $IN --auto --output $EXT --off 
else
    xrandr --output $IN --auto --primary --output $EXT --auto \
    --rotate right --above $IN
fi
