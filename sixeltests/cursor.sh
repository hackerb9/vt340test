#!/bin/bash

# Test cursor placement after sixel image is sent.

# After a sixel image is displayed, the text cursor is moved to the
# row of the last sixel cursor position, but the column stays the same
# as it was before the sixel image was sent.

# This can be thought of as sixel images always ending with an
# implicit Graphics Carriage Return (`$`). 

# Sixel images often do *not* end with a `-` (Graphics New Line == GNL)
# which sends the sixel cursor down 6 pixels and to the left edge of
# the graphic. Anything printed next will potentially overlap the last
# row of sixels!

# In general, applications should send sixel images without a GNL but then
# send `^J`, a text newline (NL), before displaying more text or graphics.

# However, it is important to note that sometimes neither a graphics
# nor a text newline is wanted. For example, if an image is full
# screen, a either newline would cause the top line to scroll off the screen.

#           Text cursor column | Text cursor row
# !GNL !NL: Unchanged	       | Same as last graphics cursor
# !GNL  NL: Column=1	       | Row = first line immediately after graphic
#  GNL !NL: Unchanged	       | Row = usually overlapping graphics
#  GNL  NL: Column=1	       | Row = first or second line after graphic



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
    if [[ row -ne 0 && column -ne 0 ]]; then
	set_cursor_pos $row $column
    fi
	
    echo -n ${DCS}'0;0;0q"1;1;100;100#'${color}'!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N'${ST}

}

squaregnl() {
    # Same as square(), but sends a graphics newline at the end of the sixels.

    local -i color=$1 row=$2 column=$3
    if [[ row -ne 0 && column -ne 0 ]]; then
	set_cursor_pos $row $column
    fi

    echo -n ${DCS}'0;0;0q"1;1;100;100#'${color}'!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N-'${ST}

}


clear

# TYPICAL sixel images do not end with a Graphics New Line (GNL)

# Blue square covers columns 26 to 35 (10 char wide) and rows 5 to 9
square 1 5 26

# Red square should cover the same columns, spanning rows 9 to 13
# OVERLAPPING last row of blue!
square 2

# Green square, overlaps red, rows 13 to 17
square 3
   
# Draw words overlapping the bottom of the green square
echo -n "Overlap"


# USING A TEXT NEWLINE (NL) after an sixel image that does NOT have GNL 
# is the only guaranteed way to be on the text line immediately below
# the image. Text newline always sends to the cursor to column 1, however.

# Pastel blue square covers columns 1 to 9 and rows 5 to 9
square 9 5 1 
echo				# Text newline

# Pastel red is below blue, rows 10 to 14, no overlap.
square 10
echo

# Pastel green is below red, rows 15 to 19, no overlap.
square 11
echo

echo -n "No overlap (text newline)"



# However, some sixel images end with a `-`, a Graphics New Line.
# This can be useful for writing another image starting at the same
# column without having to reposition the cursor.

# Magenta square covers columns 51 to 60 and rows 5 to 9
squaregnl 4 5 51
# Cyan square is below magenta, rows 10 to 14, no overlap.
squaregnl 5
# Yellow square is below magenta, rows 15 to 19, no overlap.
squaregnl 6

echo -n "No overlap (graphics newline)"

echo

