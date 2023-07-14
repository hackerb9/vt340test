#!/bin/bash

# Quickly dump the sixels from a DRCS (Dynamically Redefinable
# Character Set) "soft font" file onto the screen.

ESC=$'\e'
DCS=${ESC}P
ST=${ESC}\\

declare -a files=("$@")

position() {
    # Move cursor to position number i
    local -i i="$1"
    tput cup $(( 2* (i/16) )) $(( 2* (i - 16*(i/16)) ))
}    

declare -i fn=0
while :; do
    f=${files[fn]}
    if [[ -e "$f" ]]; then
	clear
	i=20			# XXX should read from file
	tr ';' '\n' < "$f"  | while read; do
	    position ${i}
	    i=$(( i+1 ))
	    
	    echo "${DCS}q"
	    echo "${REPLY//\//-/}"
	    echo "${ST}"
	done
	echo "$f"
    else
	echo "Error: '$f' does not exist" >&2
    fi
    echo
    echo "      [Q] Quit"
    echo "  [Space] Next" 
    echo "      [B] Back"
    read -n1 -s
    case "$REPLY" in
	q|Q|$'\e') exit ;;
	" "|n)
	    fn=fn+1
	    if (( fn >= ${#files[@]} )); then exit; fi
	    echo "fn is $fn and num files is ${#files}"
	    ;;
	b|B|p|$'\x7F'|$'\x08')
	    fn=fn-1
	    if (( fn < 0 )); then fn=0; fi
	    ;;
	*) echo "Unknown key '$REPLY'"
	   ;;
    esac
done
    
