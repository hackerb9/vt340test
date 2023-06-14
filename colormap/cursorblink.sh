#!/bin/bash

# Test VT340 cursor color flashing.
# When it "inverts" the colors, what color does it use?
# It turns out that it does an exclusive-or of the index with 0111.

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

get_screen_width() {
    # By default, return 800px if terminal does not reply.
    local width=800

    # Send control sequence to query the sixel graphics geometry to
    # find out how large of a sixel image can be shown.
    IFS=";"  read -a REPLY -s -t 0.25 -d "S" -p $'\e[?2;1;0S' >&2
    if [[ ${REPLY[2]} -gt 0 ]]; then
        width=${REPLY[2]}
    else
        # Nope. Fall back to dtterm WindowOps to approximate sixel geometry.
        IFS=";" read -a REPLY -s -t 0.25 -d "t" -p $'\e[14t' >&2
        if [[ $? == 0  &&  ${REPLY[2]} -gt 0 ]]; then
            width=${REPLY[2]}
	else
	    if [[ "$DEBUG" ]]; then
		echo "Unable to detect screen width in pixels. Using $width.">&2
	    fi
        fi
    fi

    echo ${width}
}

get_cols() {
    # Return number of text columns the screen is displaying
    local -i c
    c=$(tput cols 2>/dev/null)

    if [[ $c -eq 0 ]]; then
	if [[ $DEBUG ]]; then
	    echo "Trying stty to detect number of columns." >&2
	fi
	local s=$(stty -a | egrep -o 'columns [0-9]+' 2>/dev/null)
	s=${s#* }		# chop of the word "columns ".
	c=${s:-0}		# set c if it worked.
    fi

    if [[ $c -eq 0 ]]; then
	# Stty no good. Try detecting 132/80 column mode.
	if [[ $DEBUG ]]; then
	    echo "Checking for 132 column mode." >&2
	fi
	case $(get_mode 3) in
	    1)  # 132 column mode is enabled
		c=132
		;;
	    2)  # 132 column mode disabled, so it has 80 columns.
		c=80
		;;
	    *)  # Huh. Terminal doesn't know if it is in 132-column mode.
		c=80
		;;
	esac
    fi

    if [[ $c -eq 0 ]]; then
	c=80
	if [[ "$DEBUG" ]]; then
	    echo "Unable to detect number of text columns. Using $c.">&2
	fi
    fi
    if [[ $DEBUG ]]; then echo "Number of columns is $c" >&2; fi
    echo $c
}
# Array for printing results from getmode()
status=("not recognized" "set" "reset" "permanently set" "permanently reset")

get_mode() {
    # Inquires if mode in $1 is set or reset in the terminal.
    # Prints an integer as result:
    #   0: "not recognized"
    #   1: "set"
    #   2: "reset"
    #   3: "permanently set"
    #   4: "permanently reset"
    #
    mode=${1:-3}
    if ! IFS=";$" read -a REPLY -t 0.25 -s -p ${CSI}'?'$mode'$p' -d y; then
	echo "Terminal did not respond to inquiry for mode $mode." >&2
	echo 0			# Pretend terminal responded, "not recognized"
    else
	echo "${REPLY[1]}"
    fi
}

get_char_cell_width() {
    # Detect, if we can, the width in pixels of each character cell.

    # On a VT340/330/240, the resolution is always 800x480, but the
    # terminal can show 80 or 132 character lines. On terminal
    # emulators, the screen resolution can change as well.

    # 800/80 columns == 10px and 800/132 columns =~ 6px.

    local char_width=0
    local screen_width
    local cols

    # First try $'\e[16t' which may return the char cell size directly
    while read -t 0; do true; done
    IFS=";" read -a REPLY -s -t 0.25 -d "t" -p $'\e[16t' >&2
    if [[ $? == 0  &&  ${REPLY[2]} -gt 0 ]]; then
        char_width=${REPLY[2]}
    else
	# That didn't work, let's derive it from the screen width
	screen_width=$(get_screen_width) 	# Defaults to 800
	cols=$(get_cols)			# Default to 80
	char_width=$((screen_width/cols))
    fi

    if [[ $DEBUG ]]; then echo "Character width is $char_width" >&2; fi
    echo $char_width
}

sixchar() {
    # Given a binary representation of six pixels (from bottom to top),
    # output the ASCII character that represents that sixel.

    if [[ -z $1 ]]; then
	echo "Usage: sixchar 000010" >&2
    else
	for b; do
	    printf "\x$(bc -q <<<'obase=16; ibase=2; x='$b'; x+111111')"
	done
    fi
}

start_sixel() {
    echo -n ${DCS}'9;1;q'	# Sixel header
}

stop_sixel() {
    echo -n ${ST}
}

show_sixel_swatch() {
    # Draw each color in the palette in a row.
    # Presumes sixel header has already been sent.

    # Input arg is width of each color swatch in pixels.
    local width=${1:-40}

    for ((j=0; j<3; j++)); do
	for ((i=0; i<16; i++)); do
	    echo -n "#${i}!${width}~" 	# ~ == all six pixels
	done
	echo "-"			# Graphics newline
    done
}

show_sixel_swatch_inverted() {
    # Draw each color in the palette in a row, but using the inverse colors.

    # Width of each color swatch. Typically 4 character cells = 40px.
    local width=$1

    for ((j=0; j<3; j++)); do
	for ((i=0; i<16; i++)); do
	    c=$(invert i)
	    echo -n "#${c}!${width}~" 	# ~ == all six pixels
	done
	echo "-"			# Graphics newline
    done
}

show_top_brace() {
    # Just for fun, draw an indicator above the swatches to point to the index.

    # h is how long each arm of the brace is in pixels. 
    h=$1

    # Pointer at center of each brace
    echo -n "#7!$((half))?~"
    for ((i=0; i<15; i++)); do
	echo -n "!$((width-1))?~"
    done
    echo "-"

    local brace=""
    brace+=$(sixchar 100000)
    brace+=$(sixchar 010000)
    brace+="!${h}"		# Repeat center arm $h times
    brace+=$(sixchar 001000)
    brace+=$(sixchar 000100)
    brace+=$(sixchar 000011) # 111111
    brace+=$(sixchar 000100)
    brace+="!${h}"		# Repeat center arm $h times
    brace+=$(sixchar 001000)
    brace+=$(sixchar 010000)
    brace+=$(sixchar 100000)
    brace+=$(sixchar 000000)

    for i in {0..15}; do
	echo -n "${brace}" 
    done
    echo "-"

}

show_bottom_brace() {
    # Draw an indicator beneath the swatches pointing to the index.
    # h is how long each arm of the brace is in pixels. 
    h=$1

    brace+="#7"        # Color index 7 is fg text, so hopefully visible.
    brace+="@"	       # @ == just top pixel.		000001
    brace+="A"	       # A == just second pixel.	000010
		       # 				000100
    brace+="!${h}C"    # C == row of just third pixel.	000100
		       # 				000100
    brace+="G"	       # G == just fourth pixel		001000
    brace+="o"	       # all but top four        111111 110000
    brace+="G"	       # 				001000
		       # 				000100
    brace+="!${h}C"    # C == row of just third pixel.	000100
		       # 				000100
    brace+="A"	       # A == just second pixel.	000010
    brace+="@"	       # @ == just top pixel.		000001
    brace+="?"	       # ? == Graphics space (none)	000000
    for ((i=0; i<16; i++)); do
	echo -n ${brace}
    done
    echo "-"

    echo -n "#7!${half}?~"
    for ((i=0; i<15; i++)); do
	echo -n "#7!$((width-1))?~"
    done
}


invert() {
    # Given a decimal index number of a sixel palette.
    # Return the index number of what the VT340 considers the inverse color.
    # The indices are 4-bit numbers. The low 3 are negated to get the inverse.
    for d; do
	echo $(( d ^ 7 ))
    done
}

show_binary_index() {
    # XXX Presumes each swatch is 4 characters wide.
    local -i indent=$1
    tput cuf $indent
    for i in {0..15..2}; do
	printf "%04d    " $(binary $i)
    done
    echo
    tput cuf $indent
    for i in {1..15..2}; do
	printf "    %04d" $(binary $i)
    done
    echo
}

show_binary_index_inverted() {
    # XXX Presumes each swatch is 4 characters wide.
    local -i indent=$1
    tput cuf $indent
    for i in {0..15..2}; do
	printf "%04d    " $(binary $(invert $i))
    done
    echo
    tput cuf $indent
    for i in {1..15..2}; do
	printf "    %04d" $(binary $(invert $i))
    done
    echo
}



binary() {
    # Given a decimal number, print the binary equivalent.
    declare -i i="10#$1"

    if (( i < 0 )); then
	echo -n "-"
	binary $(( -i ))
	return 0
    fi
    if (( i <= 1 )); then
	echo -n $i
	return 0
    fi
    binary $(( i/2 ))
    echo -n $(( i/2*2 != $i ))
}

########################################################################
# Main

# Print index row
tput rev
echo -n "      Index: "
printf "%3s " {0..15}
echo -n "   "
tput sgr0
echo

# Width of each color swatch = 4 character cells. (Usually 40px)
width=$(( 4 * $(get_char_cell_width) ))
half=$((width/2-1))	# Almost half the character width.
h=$((half-3))		# Length of one arm of brace

show_binary_index 13
tput cuf 13			# Cursor forward 13 spaces
start_sixel
  show_top_brace $h		       # 12 pixels high  \
  show_sixel_swatch $width	       # 18 pixels high   \ 60 pixels = 3 lines
  show_sixel_swatch_inverted $width    # 18 pixels high   /
  show_bottom_brace $h		       # 12 pixels high  /
stop_sixel
if [[ ! $XTERM_VERSION ]]; then echo; fi # Work around xterm sixel newline bug
show_binary_index_inverted 13

# Print inverse index row
tput rev
echo -n "    Inverse: "
printf "%3s " $(invert {0..15})
echo -n "   "
tput sgr0
echo

tput cuu 5
tput cuf 13

