#!/bin/bash

# sixel endless mode
# Should print an endless sine curve, abort with Ctrl-C.
# A genuine VT340 terminal updates this continuously. 

# Always send ST to end sixel mode when script exits
ST=$'\e\\'
trap 'echo -en "$ST"'  EXIT	

period=200
amplitude=50

sixels=(@$ A$ C$ G$ O$ _\$-)
pi=3.141592653589793238

# Number of samples (m*period) must be divisble by both $period and 6. 
declare -i m=1
if ! factor $period 2>&- | cut -d: -f2- | grep -q -w 2; then
    m=m*2
fi
if ! factor $period 2>&- | cut -d: -f2- | grep -q -w 3; then
    m=m*3
fi

# Start sixels graphics string
echo -ne "\x1bP0;0;0q\"1;1#1;2;100;0;0#1"

# Cache the calculations in an array for speed
for (( y=0; y < m*period; y++ ))
do
  x=$(echo "x=s(2*${pi}*${y}/${period})*${amplitude}+2*${amplitude}+0.5; scale=0; x/1" | bc -l)
  echo -ne "!${x}?${sixels[$((y%6))]}"		   	# 1.8 KBps (uncached)
  f[y]=$(echo -ne "!${x}?${sixels[$((y%6))]}")		# 1.8 MBps (cached elts)
  g+=$(echo -ne "!${x}?${sixels[$((y%6))]}")		# 88 MBps (string)
done

while :
do
#    for y in ${!f[@]}; do echo -n "${f[y]}"; done 	# 1.8 MBps (cached elts)
#    echo -n "${f[*]}"					# 48 MBps (all elts)
    echo -n "$g"					# 88 MBps (string)
done
