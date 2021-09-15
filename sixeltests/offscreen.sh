#!/bin/bash
# Do sixel images rendered offscreen but on "page" stay in graphics memory?
cleanup() {
  echo ${ST}
  echo -n ${CSI}'?25h'		# cursor normal
  echo ${CSI}'132 A' 		# Shift screen right all the way
  echo ${CSI}'144T'     	# Shift screen down (aka "Pan Up") all the way
#  echo ${CSI}'80$|'		# DECSCPP, 80 cols per page
}

trap cleanup EXIT

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

reset_palette() {
    # Send DECRSTS for Color Table Report
    echo -n ${DCS}'2$p'

    echo -n "0;2;0;0;0/"      # VT color #0 is black and BG text color

    echo -n "1;2;20;20;79/"	# VT color #1 is blue
    echo -n "2;2;79;13;13/"	# VT color #2 is red
    echo -n "3;2;20;79;20/"	# VT color #3 is green

    echo -n "4;2;79;20;79/"	# VT color #4 is magenta
    echo -n "5;2;20;79;79/"	# VT color #5 is cyan
    echo -n "6;2;79;79;20/"	# VT color #6 is yellow

    echo -n "7;2;46;46;46/"	# VT color #7 is gray 50% and FG text color
    echo -n "8;2;26;26;26/"	# VT color #8 is gray 25%

    echo -n "9;2;33;33;59/"	# VT color #9 is pastel blue
    echo -n "10;2;59;26;26/"	# VT color #10 is pastel red
    echo -n "11;2;33;59;33/"	# VT color #11 is pastel green

    echo -n "12;2;59;33;59/"	# VT color #12 is pastel magenta
    echo -n "13;2;33;59;59/"	# VT color #13 is pastel cyan
    echo -n "14;2;59;59;33/"	# VT color #14 is pastel yellow

    echo -n "15;2;79;79;79"	# VT color #15 is gray 75% and BOLD text color

    echo -n ${ST}		# String Terminator
}

set_cursor_pos() {
    # Home, top left is row 1, col 1.
    local row=$1 col=$2
    echo -n ${CSI}${row}';'${col}'H'
}

square() {
    # Given row, column, and color index number, draw a square with top left
    # corner at r, c and of size 100px by 100px. (10cols, 5 rows)
    local row=$1 col=$2 color=$3
    set_cursor_pos $row $col
    echo -n ${DCS}'0;0;0q"1;1;100;100#'${color}'!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N-'${ST}

}

reset_palette

echo ${CSI}'132$|'   # DECSCPP, set 132 cols per page, but don't change font
echo ${CSI}'30 @'    # Shift screen 30 columns to the left
# Screen is now 80 columns wide, but showing columns 31 to 110

echo ${CSI}'72t'     # DECSLPP, set 72 lines per page
echo ${CSI}'15S'     # Shift screen 15 lines up (aka "Pan Down")
# Screen is now 72 rows long, but showing rows 16 to 40


# Blue square spans columns 26 to 35 (10 char wide)
square 12 26 1

# Red square spans column 76 to 85   --- vt340 cuts of at column 80
square 12 76 2

# Green square spans rows 23 to 27   --- vt340 scrolls rows 1 to 24 up
square 23 35 3
   
read -t 5

