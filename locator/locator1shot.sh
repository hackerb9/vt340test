#!/bin/bash
#
# Use ReGIS to poll the locator to pick a point on the screen.
# Shows previous point, current point, and button clicked.

# Use VSXXX-AA (mouse) or VSXXX-AB (tablet) to select a point.
# Arrow keys move by pixels; shift+arrows, by ten. Return when done.

# Based on the Etch-a-Sketch from the GIGI/ReGIS Handbook, chapter 15.
# Hit 'q' to quit.


# Notes:

# * R(P) immediately types the current graphics cursor position as a
#   plain text string of the form "[799,479]" followed by a linefeed.
# * R(P(I)) allows the user to interactively position the graphics
#   cursor using a locator (mouse or tablet) or the keyboard.
#   The output is an escape sequence: `Esc [ 241 ~ [799,479]`.
# * The number between the CSI and tilde indicates which device and
#   button was pressed. On hackerb9's VSXXX-AA mouse, the buttons are
#   Left: 241, Middle: 243, Right: 245.
# * Hitting any key other than arrowkeys will cause R(P(I)) to stop
#   and type out the location as a string, as if R(P) had been used.
# * The key used to stop the interactive selection will be typed first
#   and thus included in any `read` from stdin.
# * If that key was "Return" or "Enter", it may prematurely stop a
#   line-based input routine. The correct solution is to read the
#   characters one at a time. That extra step is not taken in this
#   script. Instead, it simply runs `read` again.

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

main() {
    echo -n ${DCS}p 		# ReGIS
    echo -n "W(M10,P1,I7,V)S(E)V[400,240]"
    echo -n ${ST}		# End ReGIS

    while true; do
	echo -n ${DCS}p
	read -sp ";R(P)${ST}" p1    	# Report_Position (current)
	echo -n ${DCS}p 		# ReGIS
	IFS="~" read -sp "R(P(I))${ST}" b2 p2	# ... (pick interactively)
	# If user hits Return, terminal sends coordinates after!
	if [[ -z "$b2" ]]; then
	    read -s p2
	    b2="Return"
	elif [[ -z "$p2" ]]; then       # User hit a key, so exit
	    exit
	fi
	b2="${b2#*[}"
	echo -n $'\e[H\e[K'"start: $p1, end: $p2, button: $b2" 
	echo -n ${DCS}p 		# ReGIS
	echo -n "P${p1}V${p2}${ST}"	# Draw a vector from p1 to p2.
    done
    echo -n ${ST}		# Exit REGIS mode
}

cleanup() {
    echo ${ST}

    # Bash 5.0.3 has a bug where 'read -n1 -t .01' sometimes says,
    # "read: error setting terminal attributes: Interrupted system call".
    # Sleeping briefly before running flushstdin works around it.
    sleep .1
    flushstdin

    exit
}
trap cleanup EXIT

flushstdin() {
    # flush stdin as otherwise the coordinate report may get run as commands.
    local REPLY
    while read -s -n1 -t .001; do :; done
}

main "$@"
