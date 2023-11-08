#!/bin/bash
# Show table of Graphic Left / Right characters and G0, G1, G2, G3.

# GL, GR, G0, G1, G2, and G3 are variables (pointers) stored in the terminal.

# Graphic Left determines how the terminal interprets chars 0x20 to 0x7F.
# Graphic Right is for 0xA0 to 0xFF. They are the active character set.
# GL and GR each select an indirect character set G0, G1, G2, or G3.
# G0, G1, G2, G3 are variables in the terminal referring to four fonts.

# At VT340 reset:
#   GL => G0 and GR => G2
#   G0 => ASCII
#   G1, G2, and G3 => MCS (or Latin-1 if chosen in SetUp)

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

# A locking shift (LS0, LS1, LS2, LS3, LS1R, LS2R, or LS3R) persists
# until another locking shift is invoked.

cleanup() {
    # Ugh. There appears to be no way to query/restore the state of GL and GR.
    # To workaround that, this program never sets GR and presumes GL==G0.
    printf "${LS0}"		# Set Graphic Left to G0 (typically ASCII)
}
trap cleanup EXIT

main() {
    printf "      %30s      %30s\n"  "Graphic Left" "Graphic Right"
    printtable
    printf "\n"
    printf "      %30s      %30s\n"  "(G0)" "(G1)"
    printtable "${LS0}" "${LS1}"
    printf "\n"
    printf "      %30s      %30s\n"  "(G2)" "(G3)"
    printtable "${LS2}" "${LS3}"
}

printtable() {
    # Show all "graphic" (non-control) characters.
    # If two arguments are given,
    #   $1 is a locking shift for west side of the screen
    #   $2 is a locking shift for east side of the screen
    # Otherwise, shows the active GL (7-bit) and GR (8-bit) characters.
    local LSW LSE

    if [[ "$1" && "$2" ]]; then
	LSW="$1"
	LSE="$2"
	# Do not add 80 to ASCII chars for GR
	p8=([2]=2 [3]=3 [4]=4 [5]=5 [6]=6 [7]=7)
    else
	# No args, so just print out GL and GR
	LSW="" LSE=""
	# Plus 8
	p8=([2]=A [3]=B [4]=C [5]=D [6]=E [7]=F)
    fi

    for a in {2..7}; do
	printf "    "
	printf "${LSW}"		# Locking shift GL to west charset 
	for b in {0..9} {A..F}; do
	    printf " \x$a$b"
	done
	printf "${LS0}"		# Reset GL to ASCII
	printf "\t"
	printf "${LSE}"		# Locking shift GL to east charset 
	for b in {0..9} {A..F}; do
	    printf " ${SSR}\x${p8[$a]}$b" 
	done
	printf "${LS0}"		# Reset GL to ASCII
	printf "\n"
    done
}




main "$@"
