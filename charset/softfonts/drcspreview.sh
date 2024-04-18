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
declare -ig step=+1		  # +1 or -1, direction we're going if we skip

declare -ig Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss # Parameters of current font
declare -ig Psgr			    # "Secret" ninth parameter.
declare -g Dscs				    # Font's "name" for SCS selection
declare -ag Sxbp			    # Array of characters as sixels
declare -g  numchars			    # Number of characters in Sxbp

declare -ig current=0		# Current character in Sxbp array.
declare -ig previous=39		# Previously current character.
declare -ig zoom=16		# Magnification of current character.
declare -gA termkey		# Array to hold terminfo key input sequences.

declare -ga chr			# Array for showing characters 0x20 to 0x7F.
declare -ga hex;		# Convert to hex from decimal.
declare -gA dec			# Convert to decimal from hex.


# Debugging stuff
declare -g   DEBUG=${DEBUG}	# Set to anything to enable debugging
debug() { [[ "${DEBUG:-}" ]] && echo "$@" >&2; }

cleanup() {
    # If the user hits ^C, we don't want them stuck in SIXEL mode
    echo -n $'\e\\'		# Escape sequence to stop SIXEL
    stty -F/dev/tty echo	# Reset terminal to show input characters.
    stty -F/dev/tty icanon	# Allow backspace to work again.
    tput rmkx			# Disable terminal application key sequences
    tput cnorm			# Show the cursor.
    tput cup 1000 0		# Move to the bottom of the screen
    echo -en "\r"; tput el	# Clear line for prompt.
    exit 0
}
trap cleanup SIGINT SIGHUP SIGABRT EXIT

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
charwidthPw=("10" "10" "6")	# The VT340 has an 800 pixel width.
meaningPt=("Text-cell (default)" "Text-cell" "Full-cell")
meaningPcss=("94-character set size" "96-character set size")
meaningPsgr=("Normal text" Bold Dim Italic Underline Blinking Reverse Invisible
	     [9]=Strikethrough [21]="Double underline" [53]=Overline)



main() {
    while :; do
	clear
	filename="${files[fn]}"
	while ! parsefile "$filename" 	# Writes to Sxbp and other global vars.
	do
	    # Invalid file, so remove it from the list
	    files=("${files[@]:0:fn}" "${files[@]:fn+1}")
	    debug "${files[@]}"
	    numfiles=${#files[@]}
	    if (( numfiles <= 0 )); then exit; fi
	    if (( step == -1 )); then fn=fn-1; fi
	    fn=fn%numfiles
	    filename="${files[fn]}"
	done

	# All good, let's show the data.

	tput home
	[[ $numfiles -gt 1 ]] && echo -n "$((fn+1))/${numfiles} "
	echo -n "${filename##*/} ($numchars character$(s $numchars), "
	echo -n "DSCS name '$Dscs', "
	case ${Pcmw} in
	    0) echo -n "defaulting to ${charwidthPw[Pw]}x20" ;;
	    1) echo -n "Invalid Pcmw" ;;
	    2) echo -n "5x10, 2:1 aspect ratio" ;;
 	    3) echo -n "6x10, 2:1 aspect ratio" ;;
	    4) echo -n "7x10, 2:1 aspect ratio" ;;
	    *) echo -n "${Pcmw}x${Pcmh}"
	esac
	echo ")"

	local charnum
	for charnum in "${!Sxbp[@]}"; do
	    drawchar $charnum
	done

	cat <<-EOF

	    [Q] Quit		[H] Left
	[Space] Next 		[J] Down
	    [B] Back		[K] Up
	    [I] Info		[L] Right
	EOF
	tput sc

	# Highlight the current glyph and show it enbiggened
	updatecurrent

	# Wait for the user to hit a key
	while read -n1 -s; do
	    # Parse terminal escape sequence for F-keys, arrows.
	    if [[ "$REPLY" == $'\e' ]]; then parseescape; fi

	    case "$REPLY" in
		q|Q|'\E')
		    exit ;;
		" "|n)
		    fn=fn+1;  step=1
		    if (( fn >= numfiles )); then
			if (( numfiles > 1 )); then fn=0 ; else exit; fi
		    fi
		    break
		    ;;
		b|B|p|$'\x7F'|$'\x08')
		    fn=fn-1;  step=-1
		    if (( fn < 0 )); then fn=$((numfiles-1)); fi
		    break
		    ;;
		i|I)
		    info | column -t -s ":"
		    read -n1 -s -p "Hit any key to continue"
		    if [[ "$REPLY" == "q" ]]; then echo; exit; fi
		    break
		    ;;
		$'\cL')
		    clear
		    break
		    ;;
		*)
		    case "$REPLY" in
			   up|k) current=(current+96-16)%96	;;
			 down|j) current=(current+16)%96	;;
			right|l) current=(current+1)%96		;;
			 left|h) current=(current+96-1)%96	;;
			-) zoom=(zoom+20-1)%20	;;
			+) zoom=(zoom+1)%20	;;
			*) echo "Unknown key ${REPLY@Q}" >&2
			   sleep 0.5
			   ;;
		    esac
		    updatecurrent
		    ;;
	    esac
	    tput rc
	done
    done
}

s() {
    # Plural? Add an 's'.
    if (( $1 != 1 )); then echo -n "s"; fi
}


inittermkey() {
    # Build termkey array so we can recognize when the user hits keys
    # that send multiple characters. E.g., \eOB maps to "Down Arrow".
    local a x k

    # To be valid, we must enable terminal application mode key sequences.
    if tput smkx; then
	for k in $(infocmp -L1 | egrep 'key_|cursor_'); do
	    a=""; x=""
	    # Example "k:	key_down=\EOB,"
	    a=${k#*key_}
	    a=${a#*cursor_}
	    a=${a%=*}		# a: down
	    x=${k#*=}
	    x=${x%,*}		# x: \EOB
	    debug termkey["$x"]="$a" 
	    termkey["$x"]="$a"
	done
    fi
}

parseescape() {
    # Parse terminal escape sequence for F-keys, arrows.
    # Read all the characters following an escape key has been hit
    # and then look it up in the termkey array.
    while read -t 0; do
	read -n 1 -s temp
	REPLY+="$temp"
    done
    esc=$'\e'
    REPLY=${REPLY//$esc/\\E}	# Replace escape with backslash E
    REPLY=${termkey["$REPLY"]:-"$REPLY"}
}

updatecurrent() {
    # Highlight the current character & enbiggen it
    drawchar $((previous-Pcn))
    drawchar $((current-Pcn))
    previous=$current

    local row=2 col=$((COLUMNS/2))
    if [[ $TERM == xterm ]]; then
	# xterm-390 doesn't properly clear lower right region of opaque sixels
	for ((row=20; row>=3; row--)); do
	    tput cup $row $col
	    tput el
	done
    fi
    tput cup $row $col
    echo -n "Glyph number 0x${hex[32+current]} '${chr[32+current]}'"
    tput el
    tput cup 3 $col
    enbiggen $current

    # Flash cursor on current character -- Not compatible with xterm-390.
    [[ $TERM != xterm ]] && position $current
}

drawchar() {
    # Draw character number Sbxp[$1] at position $1+Pcn
    local -i i="$1"

    # Highlight current character by drawing a box underneath it
    if (( i+Pcn == current )); then
	position $((i+Pcn))
	echo -n $'\eP9;1;0q"1;1;10;20 #7~!8@~- #7~!8?~- #7~!8?~- #7B!8AB \e\\'
    elif (( i+Pcn == previous )); then
	position $((i+Pcn))
	echo -n " "		# Clear the box
    fi
    position $((i+Pcn))

    if (( $i < 0 || $i > 95 )); then return 1; fi
    local c="${Sxbp[i]}"

    if ! (( Pcmw >= 2 && Pcmw <= 4 )); then
	echo "${DCS}9;1;0q"		# Start sixel image (1:1 pixels)
	echo '"1;1;10;20'	# Clear 10x20 rectangle
    else
	echo "${DCS}0;1;0q"	# Use 2:1 pixel aspect ratio for VT220 fonts
	echo '"2;1;10;20'	# Clear 10x20 rectangle, 2:1 ratio
    fi

    if (( i+Pcn == current )); then
	echo "#15"	# Bright white for highlighted character
    else
 	echo "#7"	# Normal foreground color for all others.
    fi
    echo "${c//\//-/}"	# Replace / with - (graphic newline)
    echo "${ST}"	# End sixel image
}


position() {
    # Move cursor to position number i (from 0 to 95)
    local -i i="$1"
    tput cup $(( 2 + 2* (i/16) )) $(( 2 + 2* (i - 16*(i/16)) ))
}    


enbiggen() {
    # Show larger size of a sixel character given its index number

    # Uses globals 
    # Sxbp, character data array
    # Pcn, character number of Sxbp[0]
    # Pcmw, character matrix width
    # Pw font width
    # Pcmh, character matrix height

    if (( $1-Pcn < 0 || $1-Pcn > 95 )); then return; fi
    local c="${Sxbp[$1-Pcn]}"

    echo "${DCS}9;0;q"
    echo -n '"'			# Rescale vertical using aspect ratio
    if ! (( Pcmw >= 2 && Pcmw <= 4 )); then
	echo "$zoom;1;;"
    else
	echo "$((zoom*2));1;;"	#  "(Height doubled for VT200 fonts)"	
    fi

    # Rescale horizontal using ! repeats
    local i
    for ((i=0; i<${#c}; i++)); do
	local s=${c: $i : 1}
	if [[ "$s" == "/" ]]; then
	    echo "-"
	else
	    #	    printf "%s" '!' "$zoom$s"
	    echo -n "!$zoom$s"
	fi
    done
    echo "${ST}"	# End sixel image
}

parsefile() {
    # Read soft font form file $1, write to global variables:
    # Sxbp: Array of sixel characters
    # Pfn Pcn Pe Pcmw Pw Pt Pcmh Pcss Dscs:  Parameters of current font
    #
    # Returns False if file fails basic sanity checks.
    local filename="$1"

    if [[ ! -e "$filename" ]]; then
	echo "Error: '$filename' does not exist" >&2
	return 1
    fi

    debug "Reading '$filename'"

    function parseerror {
	#debug "Error in $BASH_COMMAND at line $BASH_LINENO."
	tput sc
	tput cup 1000 0; tput el
	echo -n "$filename: ${1:-invalid file}" >&2;
	tput bel
	sleep 1
	tput cr; tput el
	tput rc
	return 1;
    }
    #trap parseerror ERR

    # Slurp up the entire font file into 'data' variable
    local data=$(cat "$filename" | tr -d '\r\n\0')
    local DCSdataST="$data"
    # Remove DCS (and any leading junk).
    data=${data##*$'\eP'}	# 7-bit DCS
    data=${data##*$'\x90'}	# 8-bit DCS
    local dataST="$data"
    # Remove ST (and any trailing junk).
    data=${data%$'\e\\'*}	# 7-bit ST
    data=${data%$'\x9C'*}	# 8-bit ST

    if [[ ${DCSdataST} == ${dataST} ]]; then
	parseerror "Could not find DCS escape sequence" 
	return 1
    fi

    if [[ ${dataST} == ${data} ]]; then
	parseerror "Could not find ST escape sequence" 
	return 1
    fi

    if ! sanitycheck "$data"; then
	parseerror "Sanity check failed" 
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
    Sxbp=( ${data//;/ })
    numchars=${#Sxbp[@]}
    debug $numchars
    trap - ERR
    return 0
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
	0) debug "Sanity check: Parameter header looks good: "
	   debug ${BASH_REMATCH[0]} >&2
	   ;;
	1) debug "Sanity check: Parameter header doesn't seem right."
	   return 1
	   ;;
	2) echo "Orthorexic programming error A" >&2
	   ;;
    esac

    local interre='[ -/]'
    local finalre='[0-~]'	# Note: We set LANG=C above for ASCII order.
    [[ ${data} =~ ^($parmsre)($interre{0,2})($finalre) ]]
    case $? in
	0) debug "Sanity check: DSCS sequence looks good: "
	   debug "'${BASH_REMATCH[-2]}${BASH_REMATCH[-1]}'"
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
	0) debug "Oh, good. Data is not insane."
	   # showargs "${BASH_REMATCH[@]}" | cat -v;  exit
	   ;;
	1) debug "Error file $filename is not in correct format"
	   debug "Rematch: ${BASH_REMATCH[@]}" | cat -v
	   return 1
	   ;;
	2) debug "Programming error in regex sanity check"
	   debug "Line number $BASH_LINENO"
	   return 1
	   ;;
	*) echo "This should never happen">&2 ;;
    esac

    return 0
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


initchrhexdec() {
    for h1 in {{0..9},{A..F}}; do
	for h2 in {{0..9},{A..F}}; do
	    d=$(printf "%d" 0x$h1$h2);
	    dec[$h1$h2]=$d;
	    hex[$d]=$h1$h2;
	    case $h1$h2 in
		00) chr[$d]="\0" ;;
		20) chr[$d]="Spc" ;;
		7F) chr[$d]="^?" ;;
		 *) printf -v chr[$d] "%c" "$(printf "\\x$h1$h2")" ;;
	    esac
	done;
    done
}

# Make some convenience tables for printing numbers and characters
initchrhexdec

# Make terminfo keys valid so we can catch arrow keys.
inittermkey
    
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
