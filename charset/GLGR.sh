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
    #
    # Actually, it looks like it is possible with DECRQPSR (CSI 0 $ w).
    printf "${LS0}"		# Set Graphic Left to G0 (typically ASCII)
}
trap cleanup EXIT

main() {
    setpsr
    local gl=${PSR[GL]} gr=${PSR[GR]}
    if [[ $gl == G? ]]; then 
	printf "     GL->%2s "  	"$gl"
    else
	printf "     GL     "
    fi
    printf "%24s"  			"${PSR[$gl]}"
    if [[ $gr == G? ]]; then 
	printf "     GR->%2s "		"$gr" 
    else
	printf "     GR     "
    fi
    printf "%24s\n"	 		"${PSR[$gr]}"

    printtable
    printf "\n"
    printf "     G0 %28s     G1 %28s\n"  "${PSR[G0]}" "${PSR[G1]}"
    printtable "${LS0}" "${LS1}"
    printf "\n"
    printf "     G2 %28s     G3 %28s\n"  "${PSR[G2]}" "${PSR[G3]}"
    printtable "${LS2}" "${LS3}"
}

declare -gA PSR=( [GL]="? "		[GR]=" ?"
		  [G0]=""		[G1]=""
		  [G2]=""		[G3]=""
		  [? ]="Graphic Left"	[ ?]="Graphic Right")

# 94-Character Sets
declare -gA Dscs94=( 
      [B]="ASCII"
     [%5]="DEC Supplemental"
    [\"?]="DEC Greek"
    [\"4]="DEC Hebrew"
     [%0]="DEC Turkish"
     [&4]="DEC Cyrillic"
      [A]="U.K. NRCS"
      [R]="French NRCS"
      [9]="French Canadian NRCS"
      [Q]="French Canadian NRCS"
     [\`]="Norwegian/Danish NRCS"
      [E]="Norwegian/Danish NRCS"
      [6]="Norwegian/Danish NRCS"
      [5]="Finnish NRCS"
      [C]="Finnish NRCS"
      [K]="German NRCS"
      [Y]="Italian NRCS"
      [=]="Swiss NRCS"
      [7]="Swedish NRCS"
      [H]="Swedish NRCS"
      [Z]="Spanish NRCS"
     [%6]="Portuguese NRCS"
    [\">]="Greek NRCS"
     [%=]="Hebrew NRCS"
     [%2]="Turkish NRCS"
     [%3]="SCS NRCS"
     [&5]="Russian NRCS"
      [0]="DEC Special Graphic"
      [>]="DEC Technical Character Set"
      [<]="User-preferred Supplemental")

# Dscs 	Default 96-Character Set
declare -gA Dscs96=( 
    [A]="ISO Latin-1 Supplemental"
    [B]="ISO Latin-2 Supplemental"
    [F]="ISO Greek Supplemental"
    [H]="ISO Hebrew Supplemental"
    [M]="ISO Latin-5 Supplemental"
    [L]="ISO Latin-Cyrillic"
    [<]="User-preferred Supplemental")

setpsr() {
    # Set PSR[] to the names for G0 G1 G2 G3 using DECRQPSR
    IFS=$';\e' read -sr -d'\\' -t 0.25 -p $'\e[1$w'  \
       dummy Pr Pc Pp Srend Satt Sflag Pgl Pgr Scss Sdesig dummy
    
    [[ $Sdesig ]] || return 1		# Terminal doesn't support DECRQPSR

    # Decode bits in Scss to get size of G0..G3 ("0"=94, "1"=96)
    local v=$(ord $Scss)
    local -A size=([G0]=$(( 0x01 & v ))
		   [G1]=$(( 0x02 & v ))
		   [G2]=$(( 0x04 & v ))
		   [G3]=$(( 0x08 & v )))

    # $Sdesig is now "BB%5%5" or similar.
    local -i i; local g; local x;
    for g in G0 G1 G2 G3; do
	x=${Sdesig: i : 1}
	while isintermediate "$x"; do
	    i=i+1
	    if (( i >= ${#Sdesig} )); then
		echo "Error: Ran out of chars when reading Sdesig: $Sdesig">&2
		exit 1
	    fi
	    x+=${Sdesig: i : 1}
	done
	if (( ${size[$g]} )); then
	    PSR[$g]="${Dscs96[$x]}"
	else
	    PSR[$g]="${Dscs94[$x]}"
	fi
	i=i+1
    done
    PSR[GL]="G$Pgl"		# GL can point to G0, G1, G2, or G3
    PSR[GR]="G$Pgr"
}

isparameter() {
    # ECMA-48 defines parameter bytes as 0x30..0x3F
    # That's 0 1 2 3 4 5 6 7 8 9 : ; < = > ?
    local x=$(ord "$1")
    if (( x < 0x30 || x > 0x3F )); then return 1; fi
    return 0
}

isintermediate() {
    # ECMA-48 defines intermediate characters as 0x20..0x2F
    # That's SPACE ! " # $ % & ' ( ) * + , - . /
    if [[ $1 < " " || $1 > "/" ]]; then return 1; fi
    return 0
}

isfinal() {
    # ECMA-48 defines final characters as 0x40..0x7E
    local x=$(ord "$1")
    if (( x < 0x40 || x > 0x7E )); then return 1; fi
    return 0
}

ord() {
    # Return hexadecimal value of character in the form "0x00" to "0x7F"
    printf "0x%02X" "'$1"
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
