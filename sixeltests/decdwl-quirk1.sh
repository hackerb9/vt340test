#!/bin/bash

# A test of the interaction of sixel graphics upon line attributes.
# (DECDWL - Double Width Line, DECDHL - Double Height Lines).

# Although only DECDWL is shown, the effect for DECDHL is the same.

#  DECDWL - Double Width Line - Esc # 6
#  DECDHL - Double Height Lines - Esc # 3 and Esc # 4
#  DECSWL - Single Width Line - Esc # 5

# When a sixel image is received by a VT340, the line attribute flags
# for all lines are set to single width and the entire backing text
# buffer is cleared. However, the bitmap of any existing text is not
# erased from the screen.

# This makes it problematic to integrate double-size text and sixel
# graphics. ReGIS is much more amenable (see regis-decdwl.sh).


# This tests all orderings of Line Attributes, Text, and Graphics.
#
# The most natural ordering is to set the attributes immediately
# before the text, with the graphics coming before or after:
# 1. ATG
# 2. GAT
# Less natural would be to set the attributes immediately after the text:
# 3. TAG
# 4. GTA
# Most peculiar would be to draw graphics between the attributes and text:
# 5. AGT
# 6. TGA


main() {
    init
    clear
    cat <<EOF
		   The effect of ordering upon sixel graphics
		     with line attributes (double-size text)
EOF

    tput cup 3 8
    echo ${DECDWL}"1. Attributes, Text, Graphics"

    tput cup 5 8
    echo "3. Text, Attributes, Graphics"${DECDWL}

    tput cup 7			# Line 5. AGT
    echo ${DECDWL}

    tput cup 8 8
    echo "6. Text, Graphics, Attributes"

    sleep .5

    # Draw the flag. (Hardcoded to column 6, row 6.)
    echo -n "$Y"

    sleep .5

    tput cup 4 8
    echo ${DECDWL}"2. Graphics, Attributes, Text"

    tput cup 6 8
    echo "4. Graphics, Text, Attributes"${DECDWL}

    tput cup 7 8
    echo "5. Attributes, Graphics, Text"

    tput cup 8			# Line 6. TGA
    echo ${DECDWL}

    tput cup 10 0
    cat <<EOF
The VT340 resets all line attributes to single-width and clears the
underlying text buffer when a sixel image is received. Existing text
is retained only in the bitmap buffer and cannot be edited.

Lines 2 and 4 of the graphic are erased when the attributes are set.
Line 6 clears text & graphics, since its order is Text, Graphics, Attributes.
Line 5 has text overwriting the image because the double-width attribute
that makes columns twice as wide was reset.

EOF
}



init() {

    DECDWL=$'\e#6'

    # Define a sixel image to draw a 120x120 flag at text column 6,
    # row 6. For compatibility with the VT240, this image uses DECSDM
    # (Sixel Display Mode) to position it absolutely on the screen
    # instead of relative to the text cursor.

    Y='P//~
TITLE=Yankee
\P//~
COMMENT=The letter Y represented using the International Code of Signals.
\P//~
CREATOR=James Holderness
\P//~
URL=https://github.com/j4james/vtinterco/
\P9;1q
"1;1----- -----
"20;1
!30?#2!120~$
"1;1
!30?#6!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}-
!30?!13?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!6~-
!30?!7?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!12~-
!30??_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!18~-
!30?!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}-
!30?!13?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!6~-
!30?!7?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!12~-
!30??_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!18~-
!30?!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-
!30?~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@\'

    # For VT240 compatibility, we need to be able to get and set DECSDM
    CSI=$'\e['			# Control Sequence Introducer
    DCS=$'\eP'			# Device Control String
    ST=$'\e\\'			# String Terminator
    DECSDM=80			# Mode number for get/set/reset mode
    oldmode=$(getmode $DECSDM)
    setmode $DECSDM
    trap cleanup EXIT
}

cleanup() {
    setmode $DECSDM $oldmode
}

getmode() {
    # Inquires if mode in $1 is set or reset in the terminal.
    # Prints an integer as result:
    #   0: "not recognized"
    #   1: "set"
    #   2: "reset"
    #   3: "permanently set"
    #   4: "permanently reset"
    #
    mode=${1:-80}
    if ! IFS=";$" read -a REPLY -t 0.25 -s -p ${CSI}'?'$mode'$p' -d y; then
	# Terminal did not respond to inquiry for mode.
	echo 0			# Pretend terminal responded, "not recognized"
    else
	echo "${REPLY[1]}"
    fi
}

setmode() {
    # Sets terminal mode in $1 to value in $2
    #
    # If $2 is not given, $2 defaults to "h" (high == SET).
    # ...   starts with the letter "h" (high) the mode is SET.
    # ...   starts with the letter "l" (low) the mode is RESET.
    # ...   is an integer from 0 to 4, then $2 is looked up in this table:
    #
    #	       0: "not recognized"	-> "l"
    #	       1: "set"			-> "h"
    #	       2: "reset"		-> "l"
    #	       3: "permanently set"	-> "h"
    #	       4: "permanently reset"	-> "l"
    #
    #       (This allows the result from getmode() to be used as input).

    mode=${1:-80}		# Default mode is 80 (DECSDM)
    if [[ $mode -le 0 ]]; then
	echo "Bug: mode must be a number greater than 0, not '$mode'" >&2
	exit 1
    fi

    case "$2" in
	"")    value=h		# $2 is empty
	       ;;
	l*|L*) value=l		# Letter "l"
	       ;;
	h*|H*) value=h
	       ;;
	0|2|4) value=l
	       ;;
	1|3)   value=h		# Number 1
	       ;;
	reset) value=l
	       ;;
	set)   value=h
	       ;;
	*) echo "Unknown value '$2' passed to setmode()" >&2
	   exit 1
	   ;;
    esac

    # Okay, now set or reset the mode.
    echo -n ${CSI}'?'$mode$value
}

main "$@"
