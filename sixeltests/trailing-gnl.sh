#!/bin/bash

# Where is the text cursor placed after various heights of sixels when
# separated by GNL.

#     GRAPHIC NEWLINE - A dash ('-') inside the sixel data before ST (Esc \).
#         Text (usually) overwrites image. Column not reset.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

w=150
color=1
nextcolor() {
    color=$((color+1))
    if [[ $color -gt 15 ]]; then color=1; fi
}

title() {
    clear
    echo "n PIXEL HIGH SIXEL IMAGES FOLLOWED BY GRAPHIC NEWLINE THEN 20px TEXT"
}

main() {
    title
    for h in {1..19}; do
 	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    tput home; echo
    for h in {20..29}; do
	tput cuf 20
	bargnl $color $((w-h)) $h
	nextcolor
	echo "$h GNL"
    done

    tput home; echo
    for h in {30..38}; do
	tput cuf 40
	bargnl $color $((w-h)) $h
	echo "$h GNL"		
	nextcolor
    done

    h=39
    tput cuf 40
    bargnl $color $((w-h)) $h
    echo -n "$h GNL"		# Don't scroll screen on final text
    nextcolor

    tput home; echo
    for h in {40..46}; do
	tput cuf 60
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    waitforkey

    title
    for h in {47..53}; do
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    tput home; echo
    for h in {54..58}; do
	tput cuf 20
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    h=59
    tput cuf 20
    bargnl $color $((w-h)) $h
    echo -n "$h GNL"		# Don't scroll screen on final
    nextcolor

    tput home; echo
    for h in {60..64}; do
	tput cuf 40
	bargnl $color $((w-h)) $h
	echo "$h GNL"		
	nextcolor
    done

    tput home; echo
    for h in {65..69}; do
	tput cuf 60
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    echo
    waitforkey

    title
    for h in {70..74}; do
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    tput home; echo
    for h in {75..79}; do
	tput cuf 20
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    tput home; echo
    for h in {80..83}; do
	tput cuf 40
	bargnl $color $((w-h)) $h
	echo "$h GNL"		
	nextcolor
    done

    tput home; echo
    for h in {84..87}; do
	tput cuf 60
	bargnl $color $((w-h)) $h
	echo "$h GNL"
	nextcolor
    done

    echo

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

