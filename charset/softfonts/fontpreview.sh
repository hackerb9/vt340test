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
declare -i numfiles=${#files[@]}
while :; do
    f=${files[fn]}
    if [[ -e "$f" ]]; then
	# Read DRCS header parameters into variables
	IFS=';' read dummy Pfn Pcn Pe Pcmw Pw Pt Pcmh PcssDscsSxbp1 Sxbp2 < "$f"

	# Final parameter needs some demangling.
	# PcssDscsSxbp1 looks like "0{&0?A???A"
	Pcss=${PcssDscsSxbp1%%\{*} # Everything before the first '{'
	DscsSxbp1=${PcssDscsSxbp1#*\{} # Everything after the first '{'
	Dscs=${DscsSxbp1: 0:2}	       # First two characters
	Sxbp1=${DscsSxbp1: 2}       # Everything remaining = first character.

	# Read the sixel data into the array ${Sxbp[@]}
	# Sxbp2 looks like "GO_?_OG/???@;?_OGO_/@?????@;gggwgki/A@;"... 93 chars
	Sxbp=(${Sxbp1} ${Sxbp2//;/ })
	numchars=${#Sxbp[@]}

	# All good, let's show the data.
	clear
	declare -i i=$((16#20 + Pcn))
	for c in "${Sxbp[@]}"; do
	    position $((i++))
	    
	    echo "${DCS}q"	# Start sixel image
	    echo "${c//\//-/}"	# Replace / with - (graphic newline)
	    echo "${ST}"	# End sixel image
	done
	[[ $numfiles -gt 1 ]] && echo -n "$((fn+1))/${numfiles} "
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
	    if (( fn >= numfiles )); then
		if (( numfiles > 1 )); then fn=0 ; else exit; fi
	    fi
	    echo "fn is $fn and num files is ${#files}"
	    ;;
	b|B|p|$'\x7F'|$'\x08')
	    fn=fn-1
	    if (( fn < 0 )); then fn=$((numfiles-1)); fi
	    ;;
	*) echo "Unknown key '$REPLY'"
	   ;;
    esac
done
    


# Notes The DECDLD control string that defines a Soft Character Set
# has the following format.
#
# DCS Pfn ; Pcn ; Pe ; Pcmw; Pw; Pt ; Pcmh; Pcss {
# Dscs Sxbp1; Sxbp2 ;...; Sxbpn ST

#	DCS	Device Control String Introducer
#		ESC P  or  0x90

#	Pfn	Font number of DRCS buffer to load font into on terminal.
#		0  or  1
#
#		Note: VT340 has only one DRCS buffer, so 0 and 1 work the same.

#	Pcn	Starting character
#		0 to 95    or    1 to 94
#
#		First character is loaded into the ASCII table at
#		location =
#
#			0x20 + Pcn
#
#		Range depends on character set size (Pcss below).
#		When Pcss is 0, Pcn is limited to 1 to 94.

# 	Pe	Erase Control
#		0, 1, or 2
#
# 		Selects which characters the DRCS to erase from the DRCS
#		buffer before loading the new font.
#
# 		0 = erase all characters in the DRCS buffer with
#		    this number, width and rendition.
#		1 = erase only characters in locations being reloaded.
#
#		2 = erase all renditions of the soft character set
#		    (80-column and 132-column).

#	Pcmw	Character Matrix Width
#		0..10
#
#		Selects the maximum character cell width.
#		0 = 10 pixels wide for 80 columns,
#		     6 pixels wide for 132 columns. (default)
#		1 = illegal.
#		2 = 5 x 10 pixel cell (VT200 compatible = vt340 doubles height).
#		3 = 6 x 10 pixel cell (VT200 compatible).
#		4 = 7 x 10 pixel cell (VT200 compatible).
#		5 = 5 pixels wide.
#		6 = 6 pixels wide.
#		...
#		10 = 10 pixels wide.

#	Pw	Font Width
#		1 = 80 columns;  2 = 132 columns. (Default: 0, same as 1).

#	Pt	Text or full-cell
#		1 = text;  2 = full cell. (Default: 0, same as 1).
#
#		Text-cells cannot address all pixels in a cell.
#		Terminal automatically spaces and centers text-cells.

#	Pcmh	Character matrix height
#		1..20 pixels high. (Default: 0, 20 pixels).
#
#		On the VT340, Pcmh values over 20 are illegal. Also,
#		if the value of Pcmw is 2, 3, or 4, Pcmh is ignored.

#	Pcss	Character set size
#		0 = 94-character set. (default)
#		1 = 96-character set.
#
#		The value of Pcss changes the meaning of the Pcn
#		(starting character) parameter above.

# 	Dscs	Name for the soft character set which is used
# 		in the select character set (SCS) escape sequence. 
#		Dscs is defined as 
#
# 		I F
#
#	 	where
#
#		I 	is 0, 1 or 2 intermediate characters from the
#			range 2/0 to 2/15 in the ASCII character set.
#			[ !"#$%&'()*+,-./]{0,2}
#
#		F	is a final character in the range 3/0 to 7/14.
#			[]0-9:;<=>?@A-Z[\^_`a-z{|}~]
#		
#			Unregistered character sets use finals from 3/0 to 3/F.
#			[0123456789:;<=>?]
#
#		The recommended default Dscs for user-defined sets is " @".

# 	Sxbp1 ; Sxbp2 ;...; Sxbpn
#
#		are the sixel bit patterns for individual characters,
# 		separated by semicolons (3/11). A "sixel" is a single
# 		column of six pixels.
#
# 		Your character set can have 1 to 94 patterns or 1 to
# 		96 patterns, depending on the setting of the character
# 		set size parameter (Pcss).
#
# 		Each sixel bit pattern is in the following format.
#
# 		S...S/S...S
#
# 		where / separates rows of sixels.

# 	ST	String Terminator
#		Esc \  or  0x9C
