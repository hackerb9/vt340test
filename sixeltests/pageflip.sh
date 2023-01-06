#!/bin/bash

# VT340 has enough graphics RAM for two 800x480 sixel screens.
# They are addressable on first and second page. 

# The protocol allows drawing sixels on the non-visible page, which
# could theoretically be used for double-buffering. However, the
# 19,200 bps serial port makes double-buffering impractical.

# Basic outline: Set page cursor coupling mode (PCCM) off so that the
# visible page won't change, move cursor to next page, draw some
# sixels, set PCCM on so that the page flips, loop.

# Note that when Set-Up -> Global Session -> Dual Terminal is enabled,
# the VT340 uses its RAM to provide a framebuffer for the second session.
# That means, this page flipping trick will not work. 

# When "max" pages is set to 6, this script will attempt to draw
# sixels on six different pages, which I believe is the VT340's
# default. However, since only pages 1 and 2 have graphics RAM
# installed, the results for the other pages will be blank.

# Maximum number of pages to draw on.
max=6


cleanup() {
    # Show page 1 again
    echo -n ${CSI}"1 P"		# Page Position Absolute goto page 1
    echo -n ${CSI}'?64h'		# Page Cursor Coupling Mode on
}
trap cleanup exit    


waitforterminal() {
    # Send an escape sequence and wait for a response from the terminal.
    # This routine will let us know when an image transfer has finished
    # and it's okay to send escape sequences that request results.
    # WARNING. This *should* work with any terminal, but if it fails
    # it'll end up waiting for approximately forever (i.e., 60 seconds).
    read -s -t ${1:-60} -d "c" -p $'\e[c'
}


CSI=$'\e['

labels=(Zero One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Thirteen Fourteen Fifteen Sixteen)

for i in $(seq $max); do

    # PCCM Off: Displayed page won't flip when cursor goes to page
    echo -n ${CSI}'?64l'		# Page Cursor Coupling Mode off
    echo -n ${CSI}"$i P"		# Page Position Absolute goto page #i

    # Draw an image on page #i
    clear
    tput cup 1 $(( (i-1)*10 ))	# Indent page labels

    # Create a sixel image banner with the page number.
    convert -fill white -background black -geometry x80 \
	    label:${labels[$i]} -colorspace gray -colors 4 sixel:-


    echo "This is page $i"

    # Flip displayed page to where cursor is (page #i)
    echo -n ${CSI}'?64h'		# Page Cursor Coupling Mode: on

done


while :; do
    i=$((i+1))
    if [[ i -gt $max ]]; then i=1; fi
    echo -n ${CSI}"$i P"		# Page Position Absolute goto page #i

    waitforterminal		# Slow down filing stdio so that ^C will work.
    sleep 0.1
done

