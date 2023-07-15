#!/bin/bash

# Quickly dump the sixels from a DRCS (Dynamically Redefinable
# Character Set) "soft font" file onto the screen.

ESC=$'\e'
DCS=${ESC}P
ST=${ESC}\\

declare -a files=("$@")

position() {
    # Move cursor to position number i (from 20 to 126)
    local -i i="$1"
    tput cup $(( 2* (i/16) )) $(( 2* (i - 16*(i/16)) ))
}    


declare -A longname=([Pfn]="Font num of DRCS buffer"
		     [Pcn]="Start charnum in table"
		     [Pe]="Erase control"
		     [Pcmw]="Character matrix width"
		     [Pw]="Font width"
		     [Pt]="Text or full-cell"
		     [Pcmh]="Character matrix height"
		     [Pcss]="Character set size"
		     [Dscs]="SCS font name")


meaningPcn=( $(printf "0x%02X " {32..128}) )
meaningPe=("Erase all chars in DRCS buffer with same rendition"
	   "Erase only chars in locations being reloaded"
	   "Erase all renditions (80- and 132-column)")
meaningPcmw=("10 pixels wide for 80 columns, 6 for 132 cols."
	     "Illegal value"
	     "5x10 pixel cell (height is doubled by VT340)"
	     "6x10 pixel cell (height is doubled by VT340)"
	     "7x10 pixel cell (height is doubled by VT340)"
	     $(printf "%d pixels wide " {5..20}))
meaningPw=("80 columns (default)" "80 columns" "132 columns")
meaningPt=("Text-cell (default)" "Text-cell" "Full-cell")
meaningPcmh=("20 pixels high (default)"
	     "1 pixel high"
	     $(printf "%d pixels high " {2..40}))
meaningPcss=("94-character set size" "96-character set size")



info() {
    # Show info from global variables read from font's parameters.
    echo "Filename: $filename"
    for var in  Dscs Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss; do
	local -n ref=$var		# Bash nameref (pointeresque).
	local -n m=meaning$var
	if [[ -z "${m}" ]]; then
	    echo "${longname[$var]}: ${ref@Q}"
	else
	    echo "${longname[$var]}: ${m[${ref}]:-$ref}"
	fi
    done
    echo "Chars defined: $numchars"
}

declare -i fn=0
declare -i numfiles=${#files[@]}
while :; do
    filename=${files[fn]}
    if [[ -e "$filename" ]]; then
	# Slurp up the font file into a variable
	data=$(cat "$filename" | tr -d '\r\n')
	# Remove DCS (and any leading junk).
	data=${data##*$'\eP'}	# 7-bit DCS
	data=${data##*$'\x90'}	# 8-bit DCS
	# Remove ST (and any trailing junk).
	data=${data%$'\e\\'*}	# 7-bit ST
	data=${data%$'\x9C'*}	# 8-bit ST

	# Read DRCS header parameters into variables
	IFS=$';' read Pfn Pcn Pe Pcmw Pw Pt Pcmh PcssDscsSxbp1 Sxbp2 <<<"$data"

	# Final parameter needs some demangling.
	# PcssDscsSxbp1 looks like "0{&0?A???A"
	Pcss=${PcssDscsSxbp1%%{*}     # Everything before the first '{'
	DscsSxbp1=${PcssDscsSxbp1#*{} # Everything after the first '{'
	Dscs=${DscsSxbp1: 0:2}	      # First two characters
	Sxbp1=${DscsSxbp1: 2}	      # Everything remaining.

	# Defaults
	for var in Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss; do
	    declare -n ref=$var		# Bash nameref (pointeresque).
	    ref=${ref:-0}		# Default to zero if not already set.
	done

	# Read the sixel data into the array ${Sxbp[@]}
	# Sxbp2 looks like "GO_?_OG/???@;?_OGO_/@?????@;gggwgki/A@;"... 95 chars
	Sxbp=(${Sxbp1} ${Sxbp2//;/ })
	numchars=${#Sxbp[@]}

	# All good, let's show the data.
	clear
	[[ $numfiles -gt 1 ]] && echo -n "$((fn+1))/${numfiles} "
	echo "$filename ($numchars characters, DSCS name '$Dscs')"

	declare -i i=$((16#20 + Pcn))
	for c in "${Sxbp[@]}"; do
	    position $((i++))
	    
	    echo "${DCS}q"	# Start sixel image
	    echo "${c//\//-/}"	# Replace / with - (graphic newline)
	    echo "${ST}"	# End sixel image
	done
    else
	echo "Error: '$filename' does not exist" >&2
    fi

    echo
    echo "      [Q] Quit"
    echo "  [Space] Next" 
    echo "      [B] Back"
    echo "      [I] Info"
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
	i|I)
	    info | column -t -s ":"
	    read -n1 -s -p "Hit any key to continue"
	    ;;
	*) echo "Unknown key ${REPLY@Q}"
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
