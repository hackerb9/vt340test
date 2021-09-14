#!/bin/bash

# After a sixel image is sent, the text cursor is moved down
# to the row which contained the last sixels drawn. The column
# does not change.


CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator



set_cursor_pos() {
    # Home, top left is row 1, col 1.
    local row=$1 col=$2
    echo -n ${CSI}${row}';'${col}'H'
}


square() {
    # Given a color index number and (optionally) a row and column, draw a
    # square with top left corner at (row, column) and of size 100px by 100px.
    # (10cols, 5 rows)


    local -i color=$1 row=$2 column=$3
    if [[ row != 0 && column != 0 ]]; then
	set_cursor_pos $row $column
    fi
    echo -n ${DCS}'0;0;0q"1;1;100;100#'${color}'!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N-'${ST}

}


# Blue square covers columns 36 to 45 (10 char wide) and rows 10 to 14 
square 1 10 36

# Red square spans column 76 to 85   --- vt340 cuts of at column 80
square 2

# Green square spans rows 23 to 27   --- vt340 scrolls rows 1 to 24 up
square 23 35 3
   
read -t 5
