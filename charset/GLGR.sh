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
    printf "${LS0}${LS1R}"	# Set Graphic Left to G0, Graphic Right to G1
}
trap cleanup EXIT

main() {
    printf "${LS0}${LS1R}"	# Set Graphic Left to G0, Graphic Right to G1
    printf "      %30s      %30s\n"  "Graphic Left (G0)" "Graphic Right (G1)"
    printtable
    printf "\n"
    printf "      %30s      %30s\n"  "(G2)" "(G3)"
    printf "${LS2}${LS3R}"	# Set Graphic Left to G2, Graphic Right to G3
    printtable
}

printtable() {
    # Show all "graphic" (non-control) characters. Left is 7-bit, Right 8-bit.
    # Before calling this, use a locking shift to set GL and GR.

    # Plus 8
    p8=([2]=A [3]=B [4]=C [5]=D [6]=E [7]=F)

    for a in {2..7}; do
	printf "    "
	for b in {0..9} {A..F}; do
	    printf " \x$a$b"
	done
	printf "\t"
	for b in {0..9} {A..F}; do
	    printf " \x${p8[$a]}$b" 
	done
	printf "\n"
    done
}




main "$@"
