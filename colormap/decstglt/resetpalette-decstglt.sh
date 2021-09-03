#!/bin/bash
# DECSTGLT - Set Text/Graphics Look-Up Table
# Changing to colormap #0 then colormap #1 resets the color table to default.
echo -n $'\e[0){\e[1){'

# However, there are strange text glitches, so clear the screen.
# [Commented out while investigating cause of glitches.]
#echo -n $'\e[2J'
