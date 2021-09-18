#!/bin/bash

# Test cursor row, column placement after sixel image is sent.

# After a sixel image is displayed, the text cursor is moved to the
# row of the last sixel cursor position, but the column stays the same
# as it was before the sixel image was sent.
#
# This can be thought of as sixel images always ending with an
# implicit Graphics Carriage Return (`$`). 

# ADDENDUM: It is not as simple as I thought. When a row of sixels
# straddles two rows of text, the text cursor can be left on the upper row.
# It seems up to three lines of pixels may be beneath any words printed.
#
# The rule for when this happens is not obvious to me, but can be seen
# with images of height: 21, 22, 23, 24, 41, 42, 81, 82, 83, 84...
#
# My guess:
# for a sixel image of height h, let a=(h-1)%6 and b=(h-1)%20,
# then, the text will overlap the image when a>b.
#
# If that is the case, then the entire list of heights for which this
# will happen on the VT340's 480 pixel high screen is:
#
# 21 22 23 24  41 42  81 82 83 84  101 102  141 142 143 144  161 162 
# 201 202 203 204  221 222  261 262 263 264  281 282 
# 321 322 323 324  341 342  381 382 383 384
# 401 402  441 442 443 444  461 462
#
# Note that there are 48 entries, so that means there's a 10% chance
# if heights are chosen randomly from 1 to 480. However, if one were
# to always pick heights which are a multiple of the character cell
# height (20px), then the chances are 0% as there are no problematic
# heights

# Sixel images often do *not* end with a `-` (Graphics New Line = GNL)
# which sends the sixel cursor down 6 pixels and to the left edge of
# the graphic. Any text printed next will potentially overlap the last
# row of sixels!

# In general, applications should send sixel images without a GNL but then
# send `^J`, a text newline (NL), before displaying more text or graphics.

# IMPORTANT: sometimes neither a graphics nor a text newline is wanted. 
# For example, if an image is full screen, either newline would cause
# the top line to scroll off the screen.

#         | Text cursor column | Text cursor row
# --------|--------------------|-------------------------------------
# !GNL !NL| Unchanged	       | Overlapping last line of graphics
# !GNL  NL| Column=1	       | First line immediately after graphic (usually)
#  GNL !NL| Unchanged	       | _Sometimes_ overlapping graphics
#  GNL  NL| Column=1	       | First *or* second line after graphic


CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

set_cursor_pos() {
    # Home, top left is row 1, col 1.
    local row=$1 col=$2
    echo -n ${CSI}${row}';'${col}'H'
}

reset_palette() {
    # Send DECRSTS to load colors from a Color Table Report
    echo -n ${DCS}'2$p'

    echo -n "0;2;0;0;0/"        # VT color #0 is black and BG text color

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

# Generate square of size w with final graphics new line removed
square() {
    # Given a color index number and (optionally) a row and column and size, 
    # draw a square with top left corner at (row, column) and of size×size px.
    # Default size 100×100px  (10cols, 5 rows)

    local -i color=${1:-1}	# Default is color index 1 (blue)
    local -i row=$2 column=$3	# If set to 0, cursor is not moved
    local -i size=${4:-100}	# Size in pixels (defaults to 100)

    if [[ row -ne 0 && column -ne 0 ]]; then
	set_cursor_pos $row $column
    fi

    # Draw a square of the right size 
    squaresize $size $color
}

squaresize() {
    # Helper for square() that uses convert to create a square of the
    # right size ($1) and color (2). 

    # Similar to this but with variable size squares:
    #    echo -n ${DCS}'0;0;0q"1;1;100;100#'${color}'!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100~-!100N'${ST}


    local size=${1:-100}		# Default size is 100x100
    local color=${2:-1}			# Default color index is 1 (blue)

    # Get a sixel string 
    local sq=$(convert -geometry ${size}x${size} xc:black sixel:-)

    # Remove ImageMagick's extraneous Graphic New Line at end of image.
    sq=${sq%-??}$'\e\\'

    # VT340s always used the same color register for the first sixel
    # color defined no matter what number it was assigned. That means,
    # each time we send a new sixel image, the previous one's color
    # palette gets changed. We don't want squares of all the same
    # color, so remove the color definition and just use the defaults.
    sq=${sq/\#0;2;0;0;0/}

    # And finally, switch to the proper index for the color we want.
    echo -n ${sq//\#0/#${color}}
}

squaregnl() {
    # Same as square(), but sends a graphics newline at the end of the sixels.
    # (Sticks a `-` before the String Terminator, "Esc \")
    sq=$(square "${@}")
    echo -n ${sq%??}$'-\e\\'
}


main() {
    clear
    reset_palette
    middle_stack
    left_stack
    right_stack_big
    right_stack_small
    show_labels
    set_cursor_pos 1000 1
}


middle_stack() {
    # Middle stack
    # Typically sixel images should not end with a Graphics New Line (GNL)
    # However, if a text newline isn't sent, there will be overlap.

    size=96
    set_cursor_pos 3 26
    echo -n "Neither NL nor GNL"
    set_cursor_pos 4 26
    echo -n "Height $size"

    # Blue square covers columns 26 to 35 (10 char wide) and rows 5 to 9
    square 1 5 26 $size
    # Red square should cover the same columns, spanning rows 9 to 13
    # OVERLAPPING last row of blue!
    square 2 0 0  $size
    # Green square, overlaps red, rows 13 to 17
    square 3 0 0  $size
    
    # Draw text overlapping the bottom of the green square
    echo -n "Overlap"
}


left_stack() {
    # Left stack, 100x100

    # USING A TEXT NEWLINE (NL) after an sixel image that does NOT
    # have GNL is the best way to be on the text line immediately
    # below the image. However, the text will still occasionally
    # overlap the last three rows of pixels.

    set_cursor_pos 3 1
    echo -n "Text newline only"

    # # Pastel blue square covers columns 1 to 9 and rows 5 to 9
    # square 9 5 1 
    # echo				# Text newline
    # # Pastel red is below blue, rows 10 to 14, no overlap.
    # square 10
    # echo
    # # Pastel green is below red, rows 15 to 19, no overlap.
    # square 11
    # echo

    # Left stack, smaller size
    set_cursor_pos 4 1
    size=96
    echo -n "Height $size"
    # # Pastel blue square covers columns 1 to 9 and rows 5 to 9
    square 9 5 1 $size
    echo
    # Pastel red is below blue with a gap, rows 10 to 14, no overlap.
    square 10 0 0 $size
    echo
    # Pastel green is below red with a gap, rows 15 to 19, no overlap.
    square 11 0 0 $size
    echo

    echo -n "No overlap"
}


right_stack_big() {
    # Right stack
    # However, some sixel images end with a `-`, a Graphics New Line.
    # This can be useful for writing another image starting at the same
    # column without having to reposition the cursor.
    #
    # However, this runs the risk of having occasional overlap .

    set_cursor_pos 3 51
    echo -n "Graphics New Line only"
    set_cursor_pos 4 51
    echo -n "Height 100"

    # Magenta square covers columns 51 to 60 and rows 5 to 9
    squaregnl 4 5 51
    # Cyan square is below magenta, rows 10 to 14, no overlap.
    squaregnl 5
    # Yellow square is below magenta, rows 15 to 19, no overlap.
    squaregnl 6

    echo -n "No overlap?"
}

right_stack_small() {
    set_cursor_pos 4 64
    size=96
    echo -n "Height $size"
    # Magenta square covers columns 66 to 75 and rows 5 to 9
    squaregnl 4 5 64 $size
    # Cyan square is below magenta, rows 9 to 13, OVERLAPPING.
    squaregnl 5 0 0 $size
    # Yellow square is below magenta, rows 13 to 17, OVERLAPPING.
    squaregnl 6 0 0 $size

    echo -n "Overlap"
}


show_labels() {
    set_cursor_pos 1 10
    echo -n "Should sixel images include a GNL ('-') at the end?"

    set_cursor_pos 22 1
    echo -n "Never overlaps"		# NL only
    set_cursor_pos 22 26
    echo -n "Always overlaps"		# Neither NL nor GNL
    set_cursor_pos 22 51
    echo -n "Sometimes overlaps!"	# GNL only
}


main

