#!/bin/bash

DCS=$'\eP'
ST=$'\e\\'
# 20 league boots (M20px per stride of Vector). Intensity 0 draws black (0000).
echo "${DCS}1p; S(E) W(M20,I0) ${ST}"

tput cup 10 25
tput sgr0			# Normal text pixels are set to 0111
echo -n "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"
tput cup 12 25
tput bold			# Bold text pixels are set to 1111
echo -n "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

start=$(date +%s.%N)

echo "${DCS}0p;"
echo "P[250,200]"
# Enable only certain fields (bitplanes) for writing.
for ((i=0; i<16; i++)); do
    echo "F(V(W(F${i})) 0642) v0 "
done
echo "${ST}"

echo "${DCS}0p;"
echo "P[250,240]"
# Enable only certain fields (bitplanes) for writing.
for ((i=0; i<16; i++)); do
    echo "F(V(W(F${i})) 0642) v0 "
done
echo "${ST}"


# Send Device Status Request 5 (howyadoin?) and wait for ReGIS to finish.
read -s -d "n" -p $'\e[5n'
end=$(date +%s.%N)
duration=$(echo "scale=5; ($end-$start)" |bc -q)

echo
echo "Total colorization time: $duration seconds."



# Some basic tests of what happens when the colorized text is moved.
echo
echo "Testing delete and insert."
tput cup 10 0			# CUrsor Position
tput dch 5			# Delete CHaracter (five)

tput cup 12 0
tput smir			# Start Mode InseRt
echo -n "     "			# Five spaces
tput rmir			# Remove Mode InseRt

echo
echo "Hit ENTER to test if colors last after scrolling"

# Put cursor on last line for scroll test
tput cup 1000 0
