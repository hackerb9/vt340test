#!/bin/bash

# Quickly dump the sixels from a DRCS (Dynamically Redefinable
# Character Set) "soft font" file onto the screen.

export LANG=C			# Use ASCII sort order for regexp brackets.

ESC=$'\e'
DCS=${ESC}P
ST=${ESC}\\

# Globals
declare -ag files=("$@")	# Soft font files specifed on command line
declare -ig numfiles=${#files[@]} # Number of font files 
declare -ig fn=0		  # Current file number

declare -ig Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss # Parameters of current font
declare -ig Psgr			    # "Secret" ninth parameter.
declare -g Dscs				    # Font's "name" for SCS selection
declare -ag Sxbp			    # Array of characters as sixels
declare -g  numchars			    # Number of characters in Sxbp

# Verbose parameter description
declare -Ag longname=([Pfn]="Font num of DRCS buffer"
		      [Pcn]="Start charnum in table"
		      [Pe]="Erase control"
		      [Pcmw]="Character matrix width"
		      [Pw]="Font width"
		      [Pt]="Text or full-cell"
		      [Pcmh]="Character matrix height"
		      [Pcss]="Character set size"
		      [Psgr]="Graphic Rendition"
		      [Dscs]="SCS font name")

meaningPcn=( $(printf "0x%02X " {32..128}) )
meaningPe=("Erase all chars in DRCS buffer with same rendition"
	   "Erase only chars in locations being reloaded"
	   "Erase all renditions (80- and 132-column)")
IFS=$'\n'
meaningPcmw=("10 pixels wide for 80 columns, 6 for 132 cols."
	     "Illegal value"
	     "5x10 pixel cell (VT340 displays as 5x20)"
	     "6x10 pixel cell (VT340 displays as 6x20)"
	     "7x10 pixel cell (VT340 displays as 7x20)"
	     $(printf "%d pixels wide\n" {5..20}))
meaningPcmh=("20 pixels high (VT340 default)"
	     "1 pixel high"
	     $(printf "%d pixels high\n" {2..40}))
unset IFS
meaningPw=("80 columns (default)" "80 columns" "132 columns")
meaningPt=("Text-cell (default)" "Text-cell" "Full-cell")
meaningPcss=("94-character set size" "96-character set size")
meaningPsgr=("Normal text" Bold Dim Italic Underline Blinking Reverse Invisible
	     [9]=Strikethrough [21]="Double underline" [53]=Overline)

main() {
    while :; do
	filename="${files[fn]}"
	if [[ -e "$filename" ]]; then
	    if ! parsefile "$filename" 	# Writes to Sxbp and other global vars.
	    then
		exit 1
	    fi

	    # All good, let's show the data.
	    clear
	    [[ $numfiles -gt 1 ]] && echo -n "$((fn+1))/${numfiles} "
	    echo "$filename ($numchars characters, DSCS name '$Dscs')"
	    if (( Pcmw >= 2 && Pcmw <= 4 )); then
		echo "(Height doubled for VT200 fonts)"	
	    fi

	    declare -i i=$((16#20 + Pcn))
	    for c in "${Sxbp[@]}"; do
		position $((i++))

		if ! (( Pcmw >= 2 && Pcmw <= 4 )); then
		    echo "${DCS}9;1;q"	# Start sixel image (1:1 pixels)
		else
		    echo "${DCS}q"	# Start with 2:1 pixels for VT220 fonts
		fi
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
		;;
	    b|B|p|$'\x7F'|$'\x08')
		fn=fn-1
		if (( fn < 0 )); then fn=$((numfiles-1)); fi
		;;
	    i|I)
		info | column -t -s ":"
		read -n1 -s -p "Hit any key to continue"
		if [[ "$REPLY" == "q" ]]; then echo; exit; fi
		;;
	    '!')
		debug | column -t -s ":"
		read -n1 -s -p "Hit any key to continue"
		;;
	    *) echo "Unknown key ${REPLY@Q}"
	       ;;
	esac
    done
}

parsefile() {
    # Read soft font form file $1, write to global variables:
    # Sxbp: Array of sixel characters
    # Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss Dscs:  Parameters of current font
    #
    # Returns False if file fails basic sanity checks.
    local filename="$1"

    echo "Reading '$filename'"

    function parseerror {
	echo "Error in $BASH_COMMAND at line $BASH_LINENO. Invalid file: $filename" >&2; return 1; }
    trap parseerror ERR

    # Slurp up the entire font file into 'data' variable
    local data=$(cat "$filename" | tr -d '\r\n')
    local DCSdataST="$data"
    # Remove DCS (and any leading junk).
    data=${data##*$'\eP'}	# 7-bit DCS
    data=${data##*$'\x90'}	# 8-bit DCS
    local dataST="$data"
    # Remove ST (and any trailing junk).
    data=${data%$'\e\\'*}	# 7-bit ST
    data=${data%$'\x9C'*}	# 8-bit ST

    if [[ ${DCSdataST} == ${dataST} ]]; then
	echo "Could not find DCS escape sequence" >&2
	return 1
    fi

    if [[ ${dataST} == ${data} ]]; then
	echo "Could not find ST escape sequence" >&2
	return 1
    fi

    if ! sanitycheck "$data"; then
	return 1
    fi

    # Semicolons with only digits interleaving, followed by left curly.
    local semi=';'
    [[ "$data" =~ ^([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?([0-9]*)${semi}?\{ ]]
    read dummy Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss Psgr <<<$"${BASH_REMATCH[*]}"

    # Sidenote: the ninth parameter, graphic rendition, is not used by
    # the VT340, but exists in the four APL fonts from DEC (always 0).

    # Read DRCS header parameters into variables
    data="${data#*\{}"
    local interre='[ -/]'
    local finalre='[0-~]'	# Note: We set LANG=C above for ASCII order.
    [[ "$data" =~ ^($interre{0,2}$finalre) ]]
    Dscs="${BASH_REMATCH[1]}"

    # Defaults
    local var
    for var in Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss Psgr; do
	local -n ref=$var	# Bash nameref (pointeresque).
	ref=${ref:-0}		# Default to zero if empty string.
    done

    data="${data#${Dscs}}"

    # data looks like "ouUOOUU/?~~GGG/?FFCCCCCC;????o?o/??{}B}BEC/??@B]B]B@;"
    Sxbp1=${DscsSxbp1: 2}	      # Everything remaining.

    # Read the sixel data into the array ${Sxbp[@]}
    Sxbp=(${data//;/ })
    numchars=${#Sxbp[@]}
}

sanitycheck() {
    # Given the contents of a soft font file,
    # with DCS, ST and CR/NL stripped off,
    # return TRUE if the file matches what we expect.
    local data="$1"

    # Regex sanity check: Is it in the proper form?
    # 8 semicolons; left curly; 1 to 4 chars; semicolon separated sixels+slash.

    # Semicolons with only digits interleaving, followed by left curly.
    local parmsre='([0-9]*;)*[0-9]*\{'
    [[ ${data} =~ ^($parmsre) ]]
    case $? in
	0) echo -n "Sanity check: Parameter header looks good: " >&2
	   echo ${BASH_REMATCH[0]} >&2
	   ;;
	1) echo "Sanity check: Parameter header doesn't seem right." >&2
	   return 1
	   ;;
	2) echo "Orthorexic programming error A" >&2
	   ;;
    esac

    local interre='[ -/]'
    local finalre='[0-~]'	# Note: We set LANG=C above for ASCII order.
    [[ ${data} =~ ^($parmsre)($interre{0,2})($finalre) ]]
    case $? in
	0) echo -n "Sanity check: DSCS sequence looks good: " >&2
	   echo "'${BASH_REMATCH[-2]}${BASH_REMATCH[-1]}'" >&2
	   ;;
	1) echo "Sanity check: DSCS sequence doesn't seem right." >&2
	   return 1
	   ;;
	2) echo "Regex Programming Error: If LANG is not C, the range [0-~] causes this." >&2
	   echo "LANG is ${LANG}." >&2
	   ;;
    esac

    local sxlre='[]0-9:<=>?@A-Z[\^_`a-z{|}~/]' semi=';'
    [[ ${data} =~ ^($parmsre)($interre{0,2})($finalre)$semi?($sxlre*$semi?)+$ ]]
    case $? in 
	0) echo "Oh, good. Data is not insane.">&2
	   # showargs "${BASH_REMATCH[@]}" | cat -v;  exit
	   ;;
	1) echo "Error file $filename is not in correct format" >&2
	   echo "Rematch: ${BASH_REMATCH[@]}" | cat -v
	   return 1
	   ;;
	2) echo "Programming error in regex sanity check">&2
	   echo "Line number $BASH_LINENO"
	   return 1
	   ;;
	*) echo "This should never happen">&2 ;;
    esac

    return 0
}

position() {
    # Move cursor to position number i (from 20 to 126)
    local -i i="$1"
    tput cup $(( 2* (i/16) )) $(( 2* (i - 16*(i/16)) ))
}    


info() {
    # Show info from global variables read from font's parameters.
    echo "Filename: $filename"
    for var in  Dscs Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss Psgr; do
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

    
main "$@"


# Notes The DECDLD control string that defines a Soft Character Set
# has the following format.
#
# DCS Pfn ; Pcn ; Pe ; Pcmw; Pw; Pt ; Pcmh; Pcss; Psgr {
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
#		2 = 5 x 10 pixel cell (VT200 compatible = vt340 doubles height)
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

#       Psgr	Select Graphics Rendition
#		0 = normal text (default)	3 = italic   
#		1 = bold			4 = underline
#		2 = dim				5 = blink    
#				...etc...
#
#		If specified, Psgr is an integer which specifies in
#		which Graphic Rendition this font is active. Most
#		terminals ignore this and do not document it. For more
#		information see DEC's ANSI-compatible PPL document.

#	{	A literal left curly brace.

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
