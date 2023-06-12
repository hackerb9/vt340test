#/!/bin/bash

# Save current screen from a VT340 as a sixel screenshot in print.six. 

# THIS WORKS ON A GENUINE VT340, BUT COULD USE SOME POLISHING.

# For this to work, the VT340 probably has to have the following
# setting changed in the Setup menu:
#
# 1. Printer Set-Up -> Sixel Graphics Level = level 2

# Questions:
#
# * How do I inquire the geometry of the graphics screen? 

# TODO:

# * Figure out why sometimes the VT340 will erroneously send a byte
#   with the eighth bit set high, send a few more characters, and then
#   pause for a long time before transmitting again. Test image
#   tty.jpg triggers this glitch.
#
#   Note: flakey cable is not the issue as I have the same trouble
#   using the DECconnect port as with RS232.
#
#   Next step: Glitched character isn't always the same, but is it
#   always at the same spot(s) for a given image? It appears to be.
#   What about at a different baudrate? 

# * When image has finished saving, make sure it is a level 2 image.
#   If not, show the commands needed to rescale to 1:1 aspect ratio.
#   (Also, give a message suggesting that the user change the printing
#   mode to level2 in the VT340 Set-Up screen).
#
# * After saving to print.six convert to PNG if ImageMagick is installed.
#
# * Command line args should allow percentage or even row & column,
#   not require pixel coords for geometry.
#
# * Negative geometry offsets should not presume the screen is 800x480 pixels.
#
# * Investigate if there is some secret, undocumented way to enable
#   level 2 printing from the application side.
#
# 

########################################

main() {

    ### Defaults
    decgpbm_flag=low		# low: Do not print background by default
    hostcomm=2			# 2: Send sixels to the terminal's host (not printer) comm port.
    outputfile="print.six"	# Default output filename is print.six.
    errorfile=/dev/null		# No debugging file by default. (try --debug --small)
    trimheader=""		# Set this to remove the VT340 sixel header.

    # Print full screen (vt340 crops this to 800x480+0+0.)
    X1=0; Y1=0; X2=4095; Y2=4095

    # Change defaults based on command line arguments.
    parseargs "$@"

    # Send the escape sequence to tell terminal to send the screen as sixels
    sendmediacopy

    # Receive data from terminal
    if [[ $hostcomm == 2 ]]; then
	receivesixeldata
    fi

    # TODO: Check if image got saved to print.six correctly as Level 2.
    # If it didn't, then use ImageMagick to convert the image to the
    # proper aspect ratio. (E.g., convert -sample 50%x100%).

    # Note: trimheader shouldn't be necessary, but some programs can't
    # handle the header that a VT340 sends for sixel media copies.
    # They ought to be "ANSI" compatible and ignore unknown escape
    # sequences.
}

parseargs() {
    # Handle command line arguments

    while [[ "$1" ]]; do
	case "$1" in
	    --transparent|--46l) decgpbm_flag=low; shift ;;
	    --background|--46h) decgpbm_flag=high; shift ;;
 	    --printer|-p) hostcomm=0; shift ;;
 	    --no-printer) hostcomm=2; shift ;;
	    --output-file) outputfile="${2:-print.six}"; shift 2 ;;
 	    --debug|-debug) DEBUG=yup; shift ;;
	    --small) # For debugging, we can send just a small cropped part.
	    	# (100x100, ~30 seconds)
	    	X1=350; Y1=190; X2=449; Y2=289; shift ;;
	    --geometry|-g) shift ;;
	    *x*|*+*|*-*) # Handle geometry, e.g., 300x200+50+75
		read X1 Y1 X2 Y2 < <(parsegeometry "$1")
		shift
		;;
	    --trim-header|-t) trimheader="Yup"; shift ;;    # For ImageMagick
	    --no-trim-header|-T) trimheader=""; shift ;;    # compatible sixel,

	    *) shift ;;		# Ignore unknown fnords.
	esac    
    done

    if [[ "$DEBUG" ]]; then
	errorfile="print.debug"
    fi

    portname=([0]="Printer"  [2]="Host comm")
    declare -A bgname
    bgname=([high]="Print background"  [low]="Transparent background")

    if [[ "$DEBUG" ]]; then
	cat <<-EOF >&2
	DEBUG is on.
	DECGPBM is $decgpbm_flag (${bgname[$decgpbm_flag]})
	MediaCopy to ${portname[hostcomm]} port.
	Region to copy is ($X1, $Y1) to ($X2, $Y2).
	EOF
    fi
}

parsegeometry() {
    # Given input of the form  256x192+50+75, (WIDTHxHEIGHT+X+Y)
    # print four numbers X1 Y1 X2 Y2.

    # X1 Y1: upper left coordinate, X2 Y2: lower right coordinate.
    # Coordinates are zero-based, so 800x480+0+0 -> 0 0 799 479

    # X, Y is taken as the coordinate of upper left corner normally.
    # However, if X or Y is negative, it specifies the location of the
    # right/lower corner offset from the rightmost/bottom edge,
    # respectively. For example: 100x100-0-0 would copy the region
    # from (700, 380) to (799, 479). 

    # TODO: This routine should detect the size of the screen instead
    # of presuming the vt340's resolution (800x480) is correct.
    # However, it is not a major bug as it only comes into play when
    # negative offsets are specified.

    local g="$1"
    local -i w=0 h=0 x=0 y=0
    if [[ ${g:0:1} =~ [0-9] ]]; then
	# First number is width. Truncate anything after x, + or -
	g2=${g%%x*}
	g2=${g2%%+*}
	w=${g2%%-*}
	g=${g#$w}		# Remove width from input
    fi
    
    if [[ ${g:0:1} == "x" ]]; then
	# Next number is height
	g=${g:1}		# Skip the x
	g2=${g%%+*}
	h=${g2%%-*}
	g=${g#$h}		# Remove height from input
    fi
    local xsign=${g:0:1}
    if [[ $xsign == "+" || $xsign == "-" ]]; then
	# Next number is x offset
	g=${g:1}		# Skip the sign
	g2=${g%%+*}		# Remove y offset
	x=${g2%%-*}
	g=${g#$x}		# Remove x value from input
    fi
    local ysign=${g:0:1}
    if [[ $ysign == "+" || $ysign == "-" ]]; then
	# Final number is y offset
	g=${g:1}		# Skip the sign
	y=${g}
	g=${g#$y}		# Remove y from input
    fi
    
    if [[ $w == 0 ]]; then w=800; fi
    if [[ $h == 0 ]]; then h=480; fi

    local -i x2=x+w-1
    local -i y2=y+h-1

    if [[ "$xsign" == "-" ]]; then
	x2=800-x-1
	x=800-w-x
    fi

    if [[ "$ysign" == "-" ]]; then
	y2=480-y-1
	y=480-h-y
    fi

    echo "$x $y $x2 $y2"
}

sendmediacopy() {
    # Enable host flow-control in case the VT340 overwhelms it with data. :)
    stty ixoff

    # REGIS Screen Hard Copy with no parameters sends the whole screen, 
    # offset 50 pixels to the right. We use P[0,0] to disable the offset.
    # Full screen on VT340 is equivalent to X1=0; Y1=0; X2=799; Y2=479
    REGIS_H="S(H(P[0,0]))"
    #REGIS_H="S(H)"

    if (( X1>0 || Y1>0 || X2>0 || Y2>0 )); then
	REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"
    fi

    CSI=$'\e['			# Control Sequence Introducer
    DCS=$'\eP'			# Device Control String
    ST=$'\e\\'			# String Terminator
    FF=$'\f'			# Form Feed

    echo -n ${CSI}'?'$hostcomm'i'	# (MC) 2: Send graphics to host comm
    					#      0: Send graphics to printer port

    # DECGEPM: Graphics Expanded Print Mode (only for Level 1 Graphics)
    #echo -n ${CSI}'?43l'	# Compressed:  6" x 3" printout, 800x240
    echo -n ${CSI}'?43h'	# Expanded:   12" x 8" printout, 1600x480

    # DECGPCM: Print Graphics Color Mode
    #echo -n ${CSI}'?44l'	# Print in black and white
    echo -n ${CSI}'?44h'	# Print in color

    # DECGPCS: Print Graphics Color Syntax
    #echo -n ${CSI}'?45l'	# Print using HLS colors
    echo -n ${CSI}'?45h'	# Print using RGB colors (ImageMagick reqs)

    # DECGPBM: Print Graphics Background Mode  (always on for level 1 graphics)
    if [[ $decgpbm_flag == "low" ]]; then
	echo -n ${CSI}'?46l'	# Do not send background (transparent bg)
    else
	echo -n ${CSI}'?46h'	# Include background when printing
    fi

    # DECGRPM: Graphics Rotated Print Mode (90 degrees counterclockwise)
    echo -n ${CSI}'?47l'	# Use compress or expand to fit on printer.
    #echo -n ${CSI}'?47h'	# Rotate image CCW. 8" x 12" printout

    # Send a hard copy using REGIS
    echo -n ${DCS}'p'		# Enter REGIS mode
    echo -n ${REGIS_H}		# Send hard copy sequence
    echo -n ${ST}		# Exit REGIS mode
}


receivesixeldata() {
    # Receive sixel data until Esc \ is seen on stdin.

    # Redirect printing to the outputfile, debugging to errorfile.
    exec >"$outputfile"   2>"$errorfile"

    while read -r -s -d $'\e'; do
	if [[ -z "$trimheader" ]]; then echo -n "$REPLY"$'\e'; fi
	read -r -s -N1 next_char
	cat -v >&2 <<<"Found in header $REPLY Esc $next_char"
	if [[ "$next_char" == "P" ]]; then break; fi
	if [[ -z "$trimheader" ]]; then echo -n "$next_char"; fi
    done
    echo "Found Esc P (DCS String Start)" >&2
    echo -n P
    
    # Read until the escape-backslash that ends sixel data
    while read -r -s -d $'\e' until_esc; do
	echo "Reading data" >&2
	echo -n "$until_esc"
	# Allow multiple Esc chars in a row
	second_char=$'\e'
	while [[ "$second_char" == $'\e' ]]; do
	    echo -n $'\e'
	    read -r -s -N1 second_char
	done
		
	# Okay, at this point, we have just read an Esc followed by a
	# second character that is not an escape.

	# Is it the end of the sixel graphics?
	if [[ "$second_char" == '\' ]]; then
	    echo -n '\'
	    break;
	fi

	# Nope, so write the data and keep going
	echo -n "$second_char"

	if LANG=C egrep -q "[^[:print:][:cntrl:]]" <<<"$REPLY"; then
	    # Debugging: check for non ASCII characters
	    echo >&2
	    echo 'WARNING: 8-bit Glitch. Received data with the eighth bit set high.'>&2
	fi

	# Debugging: log data to print.debug
	date +"%s: " | tr -d '\n' >&2
	echo -n "$REPLY" | sed $'s/\e/Esc /g' |  cat -v >&2

    done
    echo "Finished reading data" >&2
}

main "$@"
