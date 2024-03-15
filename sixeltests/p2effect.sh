#!/bin/bash

# What effect does setting P2 of the Sixel DCS to 0 (opaque) instead
# of 1 (bg color is transparent) have on graphics already on the screen?

# With RA (raster attributes) set, the answer is given in the manual:
# the width and height are used to clear a background rectangle.

# But what about sixel images which lack RA? How can it choose how
# much to overlay if there are no transparent pixels?

# Answer: it doesn't. On the VT340 using P2=0 clears the screen from
# the cursor to the bottom right corner, so there is no overlaying such images.


blue100=$'\eP9;1;0q#2!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N\e\\'

# No Raster Attributes
opaqueredstripe20=$'\eP9;0;0q#1!20i-!20i-!20i-!20A\e\\'
transredstripe20=$'\eP9;1;0q#1!20i-!20i-!20i-!20A\e\\'

# Set RA to 60x60 even though the image is 20x20 to make effect clear.
opaqueredstripe20ra=$'\eP9;0;0q"1;1;60;60#1!20i-!20i-!20i-!20A\e\\'
transredstripe20ra=$'\eP9;1;0q"1;1;60;60#1!20i-!20i-!20i-!20A\e\\'

echo -n $'\e+>' # DEC Technical charset
uparrow=$'\e[B\eO|' # up arrow
box=$'\eP9;1;0q"1;1;10;20 #7~!8@~- #7~!8?~- #7~!8?~- #7B!8AB \e\\'
cursor=$box$uparrow$'\e[1D\e[1Bcursor'

clear
echo "    A 20x20 blue, striped square overlayed on a 100x100 red square"

row=3
tput cup $row 0
yes E | tr -d '\n' | dd status=none bs=$((9*80)) count=1

tput cup $row 0
echo $blue100
tput cup $((row+1)) 2
echo -n $transredstripe20ra
echo -n "$cursor"
tput cup $((row-1)) 0
echo -n P2=1 RA=60x60

tput cup $row 40
echo $blue100
tput cup $((row+1)) 42
echo -n $opaqueredstripe20ra
echo -n "$cursor"
tput cup $((row-1)) 40
echo -n P2=0 RA=60x60

######################################################################

row=14
tput cup $row 0
yes E | tr -d '\n' | dd status=none bs=$((9*80)) count=1

tput cup $row 0
echo $blue100
tput cup $((row+1)) 2
echo -n $transredstripe20
echo -n "$cursor"
tput cup $((row-1)) 0
tput el
echo -n P2=1 no RA

tput cup $row 40
echo $blue100
tput cup $((row+1)) 42
echo -n $opaqueredstripe20
echo -n "$cursor"
tput cup $((row-1)) 40
echo -n P2=0 no RA

tput cup 24 0

