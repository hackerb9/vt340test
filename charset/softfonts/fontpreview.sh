#!/bin/bash

# Quickly dump the sixels from a DRCS (Dynamically Redefinable
# Character Set) "soft font" file onto the screen.

ESC=$'\e'
DCS=${ESC}P
ST=${ESC}\\


position() {
    local -i i="$1"
    tput cup $(( 2* (i/16) )) $(( 2* (i - 16*(i/16)) ))
}    

clear

for f; do
    i=20
    tr ';' '\n' < "$f"  | while read; do
	position ${i}
	i=$(( i+1 ))
	
	echo "${DCS}q"
	echo "${REPLY//\//-/}"
	echo "${ST}"
    done
    echo
done
    
