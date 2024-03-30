#!/bin/bash

DCS=$'\eP'
ST=$'\e\\'
# 20 league boots (M20px per stride of Vector). I0 draws black (0000).
echo "${DCS}1p; S(E) W(M20,I0) ${ST}"

tput cup 10 25
tput bold			# Bold text pixels are set to 1111
echo -n "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"


echo "${DCS}0p;"
echo "P[250,200]"

# Enable only certain fields (bitplanes) for writing.
for ((i=0; i<16; i++)); do
    echo "F(V(W(F${i})) 0642) v0 "
done

echo "${ST}"
