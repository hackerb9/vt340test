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


######################################################################

# Some basic tests of what happens when the colorized text is moved.
echo; echo
tput sc				# Save cursor (Esc 7 on VT340)

i=0
echo -n "$((++i)). "
read -s -n1 -p "Hit a key to test shifting text down (reverse index)"
tput cup 0 0
tput ri				# Reverse Index (Esc M)

tput rc				# Restore cursor
tput cud1			# Down +1
tput el				# Clear to end of line
echo -n "$((++i)). "

read -s -n1 -p "Hit a key to test shifting text up. (newline)"
tput cup 1000 0			# CUrsor Position to last row, column 0
echo

tput rc; tput el
echo -n "$((++i)). "

read -s -n1 -p "Hit a key to test shifting text down (insert line)"
tput cup 11 0
tput il1			# Insert Line 

tput rc; tput cud1; tput el
echo -n "$((++i)). "

read -s -n1 -p "Hit a key to test shifting text up. (delete line)"
tput cup 11 0
tput dl1			# Delete line

tput rc; tput el
echo -n "$((++i)). "

### The VT340 does not retain color after the following tests.

read -s -n1 -p "Hit a key to test shifting text left. (delete char)"
tput cup 10 0			# CUrsor Position to row 10, column 0
tput dch 5			# Delete CHaracter (five)

tput rc
tput el
echo -n "$((++i)). "

read -s -n1 -p "Hit a key to test shifting text right. (insert char)"
tput cup 12 0
tput smir			# Start Mode InseRt
echo -n "     "			# Five spaces
tput rmir			# Remove Mode InseRt

# Put cursor on last line
tput cup 1000 0
