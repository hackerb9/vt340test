#!/bin/bash
#
# Use ReGIS "Multiple Graphics Input Mode" to receive events from a
# locator to pick a point on the screen. Shows previous point, current
# point, and button clicked.

# Use VSXXX-AA (mouse) or VSXXX-AB (tablet) to select a point.
# Arrow keys do NOT work to move the cursor in multimode!
# Hit 'q' to quit.

# Inspired by the Etch-a-Sketch from the GIGI/ReGIS Handbook, chapter 15.


# Notes:

# * R(I1) sets the terminal to "multimode" where mouse button events
#   are sent continuously. Events will continue to be sent until it is
#   turned off with R(I0).
# * R(P(I)) immediately returns a position report. This can be used
#   for tracking mouse movements.
#   The output is an escape sequence: `Esc [ 241 ~ [799,479]`.
# * Pressing any locator button immediately sends coordinates to the
#   host applications. Output is a position report. 
# * The number between the CSI and tilde indicates which device and
#   button was pressed. On hackerb9's VSXXX-AA mouse, the buttons are
#   Left: 241, Middle: 243, Right: 245.
# * Button "240" means the report was a result of polling the mouse.

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

button[240]="Report"
button[241]="Left down"
button[243]="Middle down"
button[245]="Right down"


main() {
    echo -n "${DCS}1p;" 		# ReGIS
    echo -n "W(M10,P1,I7,V)S(E)"
    echo -n "P[0,0]T(S1,W(I2))'Move the mouse'"
    echo -n "P[0,20]T(W(I1))'Click the buttons'"
    echo -n "P[0,40]T'Press ''q'' to quit'"
    echo -n "P[400,240]"
    echo -n "R(I1)"		# multiple input mode

    p1="[400,240]"
    oldpos=$p1
    while true; do
	read -s -n1 -t .5 key	# Get first character of esc seq or timeout
	status=$?
	if [[ $key == q ]]; then exit; fi
	if (( $status > 128 )); then
	    # Read timed out, so just poll mouse's current position
	    IFS="~" read -sp ";R(P(I))" bt pos
	    bt="${bt#*[}"
	    if [[ ${button[bt]} ]]; then bt="$bt (${button[bt]})"; fi
	    if [[ $pos && ( "$pos" != "$oldpos" ) ]]; then
		    echo -n ";W(I0)F(V[0,0][799,0][799,20][0,20]);"
		    echo -n ";P[0,0];T(S1,W(I2))"
		    echo -n "'current: ${pos}, button ${bt}'"
		    echo -n ";P$p1;W(I7)" # Diamond mark on last spot
		    oldpos=$pos
	    fi
	    continue
	fi		

	# "Captain! We get signal!"
	# Report format: Esc [245~[799,479] Linefeed
	IFS="~" read -s -t .5 bt p2	# Read button event or timeout
	if [[ -z $p2 ]]; then continue;	fi
	bt="${bt#*[}"
	if [[ ${button[bt]} ]]; then bt="$bt (${button[bt]})"; fi

	# Sanity check. This should only happen if user hits keys.
	if [[ ! $p2 =~ ^[]0-9,\n[]*$ ]]; then
	    echo $ST;
	    echo "Huh? Got non-coordinates: $p2"
	    echo "Exiting."
	    exit
	fi

	if [[ $p1 && $p2 ]]; then
	    echo -n ";P${p1}V${p2}"	# Draw a vector from p1 to p2.
	fi

	if [[ $p2 ]]; then
#	    # We could exit ReGIS briefly to send VT escape & print info text.
#	    # However, it loses rapid mouse movements and clicks.
#	    echo -n ${ST}		
#	    echo -n $'\e[H\n\n\e[K'"start: $p1, end: $p2, button: $bt" 
#	    # Note that when entering ReGIS we need to reenable multimode,
#	    # but the VT340 remembers the last graphics cursor location.
#	    echo -n "${DCS}1p;R(I1)"

	    # Instead, stay inside ReGIS to draw the information.
	    # A bit slower to render, but the mouse is more responsive.
	    # The VT340 queues up rapid clicks for later delivery.
	    echo -n ";W(I0)F(V[0,20][799,20][799,40][0,40]);"
	    echo -n "W(I1);P[0,20];T'start: $p1, end: $p2, button: $bt';"
	    echo -n "P${p2};W(I7)" 

	    p1=$p2
	fi

    done
}

cleanup() {
    echo -n ${DCS}p 		# ReGIS
    echo -n "R(I0)"		# Disable multimode
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


# Notes:
# * Need to enter in ReGIS modes 1p or 3p. 0 and 2 don't do multimode?
# * Graphics input disappears when ReGIS mode is exited with ST or ^L.
# * Despite documentation, exiting ReGIS mode turns off multimode.


