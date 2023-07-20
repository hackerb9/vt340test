#!/bin/bash
# Show table of Graphic Left / Right characters for G0, G1, G2, G3.

ESC=$'\e'
SS2="${ESC}N"		# Single Shift G2
SS3="${ESC}O"		# Single Shift G3
LS0=$'\x0F'		# Locking Shift G0 
LS1=$'\x0E'		# Locking Shift G1 
LS2="${ESC}n"		# Locking Shift G2 
LS3="${ESC}o"		# Locking Shift G3 
LS1R="${ESC}~"		# Locking Shift G1 Right 
LS2R="${ESC}}"		# Locking Shift G2 Right 
LS3R="${ESC}|"		# Locking Shift G3 Right

# ### Activate Character Sets: Single and Locking Shifts

# A single shift (SS2 or SS3), effects only the first printable
# character following the single shift sequence.

# A locking shift (LS2, LS3, LS1R, LS2R, or LS3R) persists until another
# locking shift is invoked.

cleanup() {
    # Ugh. There appears to be no way to restore the state of GL and GR.
    # (Single-shift only works for showing G2 and G3.)
    # We'll just presume GL=G0 and GR=G1.
    printf "${LS0}${LS1R}"	# Set Graphic Left to G0, Graphic Right to G1
}
trap cleanup EXIT

main() {
    printf "      %30s      %30s\n"  "Graphic Left" "Graphic Right"
    printtable
    printf "\n"
    printf "${LS0}${LS1R}"	# Set Graphic Left to G0, Graphic Right to G1
    printf "      %30s      %30s\n"  "(G0)" "(G1)"
    printtable
    printf "\n"
    printf "      %30s      %30s\n"  "(G2)" "(G3)"
    printf "${LS2}${LS3R}"	# Set Graphic Left to G2, Graphic Right to G3
    printtable
}

printtable() {
    # Show all "graphic" (non-control) characters.
    # Defaults to showing GL as 7-bit, GR as 8-bit.
    # If arguments are given,
    #   $1 is a single shift for GL
    #   $2 is a single shift for GR
    local SSL SSR

    if [[ "$1" && "$2" ]]; then
	SSL="$1"
	SSR="$2"
	# Do not add 80 to ASCII chars for GR
	p8=([2]=2 [3]=3 [4]=4 [5]=5 [6]=6 [7]=7)
    else
	SSL="" SSR=""
	# Plus 8
	p8=([2]=A [3]=B [4]=C [5]=D [6]=E [7]=F)
    fi

    for a in {2..7}; do
	printf "    "
	for b in {0..9} {A..F}; do
	    printf " ${SSL}\x$a$b"
	done
	printf "\t"
	for b in {0..9} {A..F}; do
	    printf " ${SSR}\x${p8[$a]}$b" 
	done
	printf "\n"
    done
}




main "$@"
