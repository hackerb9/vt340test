#!/bin/bash

# How fast do Scroll speeds of Smooth-1, Smooth-2, and Smooth-4 actually go?

# Results on a genuine VT340+:
# Smooth-1:  30 scanlines per second  (3 text lines per second)
# Smooth-2:  60 scanlines per second  (6 text lines per second)
# Smooth-4: 119 scanlines per second (12 text lines per second)
# Jump:     596 scanlines per second (60 text lines per second)

# If -s, then enable smooth scrolling
if [[ $1 == "-s" ]]; then
    echo -n $'\e[?4h'
    shift
fi

# Number of text lines to scroll. 100 if not otherwise specified.
# (At Smooth-4, I increased this to 360 to get accurate results.)
lines=${1:-100}

# Character height. On a VT340, each row of text is 10 scanlines high.
ch=10

# Move cursor to bottom of screen
tput cup 1000 0

start=$(date +%s%N)
# Scroll a large number of text lines.
for ((i=lines; i>0; i--)); do
    echo $i
done

# Wait for terminal to finish.
read -s -d "c" -p $'\e[c'
end=$(date +%s%N)
duration=$((end-start))

echo "$lines text lines in $duration nanoseconds"
if [[ duration -ge 10**9 ]]; then
    echo "If your terminal has $ch scanlines per text row, then"
    echo "that's $(( (ch*10**10*lines/duration+5)/10 )) scanlines per second"
else
    echo "Please increase the number of lines to get a valid test."
fi

# Is smooth scroll (DEC private mode 4) on?
IFS=";$" read -a REPLY -t${timeout:-1} -s -p $'\e[?4$p' -d y
status=("not recognized" "set" "reset" "permanently set" "permanently reset")
s=${status[${REPLY[1]}]}
echo "(Note: Smooth scroll is $s)."

if [[ $s == "reset" ]]; then
    echo "Consider using ./scrollspeed.sh -s to enable Smooth-2 scrolling"
fi
