#!/bin/bash
# testdecsdm.sh: Test whether DECSDM is implemented the same as the VT340.

# This is important because the documentation for the VT340 has this reversed
# as do any terminals based on that flawed documentation.

# On a genuine VT340, when DECSDM is reset, sixels scroll the screen,
# and when DECSDM is set, sixels do not scroll. 
#
# We can detect this by checking the text cursor positioning. When
# sixels scroll, the terminal is supposed to put the text cursor on
# the last line of the sixel image. When sixels do not scroll, the
# text cursor is supposed to be unaffected by any images.


CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

DECSDM=80			# Mode number for get/set/reset mode

# Array for printing results from getmode()
status=("not recognized" "set" "reset" "permanently set" "permanently reset")

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
	echo Terminal did not respond to inquiry for mode $mode.
	exit 1
    fi
    echo "${REPLY[1]}"
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
	echo "Error: mode must be a number greater than 0, not '$mode'"
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

resetmode() {
    # Similar to setmode() but sets the value to "l" (low, RESET) by default.
    if [[ -z $2 ]]; then
	setmode "$1" low
    else
	setmode "$1" "$2"
    fi
}

set_cursor_pos() {
  # Move cursor to column $1, row $2
  echo -n ${CSI}${1}';'${2}'H'
}

get_cursor_pos() {
    # Cursor Position Report is of the form Esc [ row ; column R
    IFS=";[" read -a REPLY -s -t 1 -d "R" -p ${CSI}'6n' >&2
    echo ${REPLY[1]}  ${REPLY[2]}
}

get_row() {
    # Return just the row the cursor is on
    read row col < <(get_cursor_pos)
    echo $row
}
    

######################################################################

# Get current DECSDM value so we can restore it when program exits.
previous=$(getmode $DECSDM)
trap "setmode $DECSDM $previous" EXIT

# 10 sixel carriage returns == 60 pixels down.
sixels=${DCS}'0;2;9q"1;1;1;60~-~-~-~-~-~-~-~-~-~-'${ST} 

clear
set_cursor_pos 1 2		# First row, second column
before_set=$(get_row)
setmode $DECSDM 
# Cursor should not move when DECSDM is set
echo -n "$sixels"
after_set=$(get_row)
diff_set=$((after_set - before_set))
echo $diff_set ' <-- DECSDM set'

# Send sixel data with DECSDM reset. Cursor should move down a few lines.
#tput home; echo -n "  "
set_cursor_pos 1 24		# First row, twenty-fourth column
before_reset=$(get_row)
resetmode $DECSDM 
# 10 sixel carriage returns == 60 pixels down.
echo -n "$sixels"
after_reset=$(get_row)
diff_reset=$((after_reset - before_reset))
echo $diff_reset ' <-- DECSDM reset'


#### Print report

set_cursor_pos 10 1		# Start report on line 10
echo "The terminal reports the DECSDM mode as: ${status[$previous]}"

setmode $DECSDM 
if [[ $(getmode $DECSDM) != 1 ]]; then
    echo "The terminal was unable to set DECSDM"
fi

resetmode $DECSDM 
if [[ $(getmode $DECSDM) != 2 ]]; then
    echo "The terminal was unable to reset DECSDM"
fi

if [[ $diff_set == 0 && $diff_reset > 0 ]]; then
    echo "This terminal treats DECSDM the same as a genuine VT340 would"
elif [[ $diff_set > 0 && $diff_reset == 0 ]]; then
    echo "This terminal has DECSDM backwards, just like the VT340 specs"
elif [[ $diff_set > 0 && $diff_reset > 0 ]]; then
    echo "This terminal seems to have DECSDM permanently reset (sixel scrolling enabled)"
elif [[ $diff_set == 0 && $diff_reset == 0 ]]; then
    echo "This terminal seems to have DECSDM permanently set, no sixel scrolling."
    echo "This is like a VT125 or VT240. (Or is your font taller than 60 pixels?)"
else
    echo "This terminal is weird."
fi
echo "Cursor moved down $diff_set lines when DECSDM was set, $diff_reset when reset."

# echo DECSDM is now ${status[$(getmode $DECSDM)]}

# Note: Trap on exit restores DECSDM when this script ends.

