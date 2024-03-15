#!/bin/bash

# What effect does setting P2 of the Sixel DCS to 0 (opaque) instead
# of 1 (bg color is transparent) have on graphics already on the screen?
# How can it choose how much to overlay if there are no transparent pixels?

# Answer: it doesn't. On the VT340 using P2=0 clears the screen from
# the cursor to the bottom right corner, so there is no overlaying such images.
blue100=$'\eP9;1;0q#2!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N\e\\'
opaqueredstripe20=$'\eP9;0;0q#1!20i-!20i-!20i-!20A\e\\'
transredstripe20=$'\eP9;1;0q#1!20i-!20i-!20i-!20A\e\\'

clear
yes E | tr -d '\n' | dd status=none bs=$((24*80)) count=1

tput cup 0 0
echo $blue100
tput cup 1 2
echo $opaqueredstripe20
tput cup 5 6
echo -n P2=0

tput cup 0 40
echo $blue100
tput cup 1 42
echo $transredstripe20
tput cup 5 46
echo -n P2=1

tput cup 12 40
