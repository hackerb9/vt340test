#!/bin/bash

# How fast do Scroll speeds of Smooth-1, Smooth-2, and Smooth-4 actually go?

# Results on a genuine VT340+:
# Smooth-1:  60 scanlines per second  (3 text lines per second)
# Smooth-2: 120 scanlines per second  (6 text lines per second)
# Smooth-4: 240 scanlines per second (12 text lines per second)
# Jump:    1192 scanlines per second (60 text lines per second)

# If -s, then enable smooth scrolling
if [[ $1 == "-s" ]]; then
    echo -n $'\e[?4h'
    shift
fi
# If -j, then enable jump scrolling
if [[ $1 == "-j" ]]; then
    echo -n $'\e[?4l'
    shift
fi

# Number of text lines to scroll. 100 if not otherwise specified.
lines=${1:-100}

# Character height. On a VT340, each row of text is 20 scanlines high.
ch=20

# Pre-generate a large number of text lines.
nums=$(eval printf '%d\\n' {$lines..1})

# Measure latency of Device Status Request (Esc [ 5 n)
echo -n "Calibrating latency..."
declare -i latency=0
for i in {1..10}; do
    start=$(date +%s%N)
    # Send Device Status Request and wait
    read -s -d "n" -p $'\e[5n'
    end=$(date +%s%N)
    latency+=$((end-start))
done
latency=latency/10
printf "Latency of Device Status 5 is %'d ns\n" $latency

# Move cursor to bottom of screen
tput cup 1000 0

start=$(date +%s%N)
printf "$nums\n"
# Wait for terminal to finish.
read -s -d "n" -p $'\e[5n'
end=$(date +%s%N)
duration=$((end-start-latency))

printf "%d text lines in %'d nanoseconds.\n" $lines $duration
printf "Presuming $ch scanlines per text row, then that's\n"
sps=$(( (ch*lines*10**10/duration + 5)/10 ))
lps=$(( (   lines*10**10/duration + 5)/10 ))
printf "%'d scanlines per second, %d lines per second\n" $sps $lps

accuracy_limit=$((300*latency))	# Allow latency to be about 0.333% error.
if [[ $duration -lt $accuracy_limit ]]; then
    echo
    echo "Please increase the number of lines to get a more accurate test."
    echo "Try running: $0 $(( ((lines*accuracy_limit/duration)+15)/10*10 ))"
    exit 1
fi

# Is smooth scroll (DEC private mode 4) on?
read -s -d "n" -p $'\e[5n'	# Wait for terminal to finish scrolling.
IFS=";$" read -a REPLY -t${timeout:-1} -s -p $'\e[?4$p' -d y
status=("not recognized" "set" "reset" "permanently set" "permanently reset")
s=${status[${REPLY[1]}]}
echo "(Note: Smooth scroll is $s)."

case $s in
    "reset")
	echo "Consider using ./scrollspeed.sh -s to enable Smooth-2 scrolling"
	;;
    "set")
	echo "Consider using ./scrollspeed.sh -j to enable Jump scrolling"
	;;
esac
