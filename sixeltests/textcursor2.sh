#!/bin/bash

# Where is the text cursor placed after various heights of sixels when
# separated by various delimiters?

#     A TEXT NEWLINE - ^J after sixel image.
#         Text does not (usually) overwrite image. Column reset to 1.
#
#     INDEX - Esc D after sixel image.
#         Same as a TEXT NEWLINE but does not reset column.
#
#     CURSOR DOWN - Esc [ 1 B after sixel image.
#         Same as a TEXT NEWLINE but does not reset column nor scroll screen.
#
#     GRAPHIC NEWLINE - A dash ('-') inside the sixel data before ST (Esc \).
#         Text (usually) overwrites image. Text cursor column is not reset.
#
#         When the image height is a multiple of the character cell height,
#         the cursor is always moved to the blank line beneath the image.
#         Hackerb9 suggests not using it for that, though, since a
#         TEXT NEWLINE (above) works without regard for image height.
#
#     NOTHING -
#         Text always overwrites image. Column not reset.
#
#         When the image height is a multiple of the character cell
#         height, the text cursor is perfectly aligned to overwrite
#         the bottom line of the image.

# Note: this programs does not demonstrate the difference between text
# newline, index, and cursor down, hence they are all colored the same.
#
# * TEXT NEWLINE resets the text cursor position to the first column
#   (the left side of the screen), while the other two leave the
#   column unchanged, directly beneath the bottom left corner of the
#   sixel image.
#
# * When on the last text row, CURSOR DOWN, unlike text newline and
#   index, does not scroll the screen, which means the subsequent text
#   following DOWN would overwrite the image badly.


CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

main() {

    local color=1 w=150
    clear
    echo "n PIXEL HIGH SIXEL IMAGES FOLLOWED BY VARIOUS SEPARATORS THEN TEXT"

    color=3
    for h in {1..11}; do
	bar $color $((w-h)) $h
	echo
	echo "$h Newline"
    done

    tput home; echo
    for h in {12..22}; do
	tput cuf 16
	bar $color $((w-h)) $h
	tput ind
	echo "$h Index"
    done

    tput home; echo
    for h in {23..30}; do
	tput cuf 32
	bar $color $((w-h)) $h
	tput cud 1
	echo "$h Down"
    done


    tput home; echo
    color=4
    for h in {5..22}; do
	tput cuf 48
	bargnl $color $((w-h)) $h
	echo "$h GNL"
    done

    tput home; echo
    color=1
    for h in {5..25}; do
	tput cuf 64
	bar $color $((w-h)) $h
	echo "$h Nothing"
    done

    waitforkey
}

waitforkey() {
    read -p $'Hit a key\r' -n1 -s
    echo -n $'         \r'
}

# Generate bar of height w with final graphics new line removed
bar() {
    # Given a color index #, width, height, row, and column (all optional),
    # draw a bar with top left corner at (row, column) and of width×height px.
    # Default height 200×20px  (20cols, 1 row)

    local -i color=${1:-1}	# Default is color index 1 (blue)
    local -i width=${2:-200}	# Width in pixels (defaults to 200)
    local -i height=${3:-20}	# Height in pixels (defaults to 20)
    local -i row=$4 column=$5	# If set to 0, cursor is not moved

    if [[ row -ne 0 && column -ne 0 ]]; then
	set_cursor_pos $row $column
    fi

    # Draw a bar of the right color & height 
    barsize $color $width $height
}

barsize() {
    # Helper for bar() that uses convert to return a  sixel bar of
    # the right color ($1), width ($2), and height ($3).
    # No Graphic New Line or Text New Line are included.

    # Similar to this but with variable size bars:
    #    echo -n ${DCS}'0;0;0q"1;1;200;20#'${color}'!200~-!200~-!200~-!200N'${ST}


    local color=${1:-1}			# Default color index is 1 (blue)
    local width=${2:-200}		# Default width is 200
    local height=${3:-20}		# Default height is 20

    # Get a sixel string 
    local sixels=$(convert -size ${width}x${height} xc:black sixel:-)

    # Remove ImageMagick's extraneous Graphic New Line at end of image.
    sixels=${sixels%-??}$'\e\\'

    # VT340s always used the same color register for the first sixel
    # color defined no matter what number it was assigned. That means,
    # each time we send a new sixel image, the previous one's color
    # palette gets changed. We don't want bars of all the same
    # color, so remove the color definition and just use the defaults.
    sixels=${sixels/\#0;2;0;0;0/}

    # And finally, switch to the proper index for the color we want.
    echo -n ${sixels//\#0/#${color}}
}

bargnl() {
    # Same as bar(), but sends a graphics newline at the end of the sixels.
    # (Sticks a `-` before the String Terminator, "Esc \")
    local sixels=$(bar "${@}")
    echo -n ${sixels%??}$'-\e\\'
}

set_cursor_pos() {
    # Home, top left is row 1, col 1.
    local row=$1 col=$2
    echo -n ${CSI}${row}';'${col}'H'
}


main "$@"


# NB: The VT340's font is always 20 pixels high. The algorithm DEC
# used appears to be optimized for that height as it has nice
# properties when used with a single newline while requiring very
# little processing on an 8085 CPU. Unfortunately, due to the
# shortcuts DEC took, the algorithm is not directly applicable to
# terminals with different character cell heights. Instead, I
# (hackerb9) encourage terminal developers to consider what DEC was
# trying to do rather than copy the VT340's precise implementation.

