#!/bin/bash

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

hlsrgb2hex() {
    # Convert percent RGB (eventually HLS) to web RGB hexadecimal color format.
    local hex
    local r g b;

    case $1 in
	1)
 	    # XXXX  HLS not debugged yet
	    read r g b < <( awk -v h="$2" -v l="$3" -v s="$4" '
	    BEGIN { 
		h=h/360;	# Scale to [0,1]
		l=l/100;
		s=s/100;
		
		if (s == 0) {
		    print l  " "  l  " "  l;
		    exit;
		}

		q = (l<0.5) ? l*(1+s) : l+s - l*s;
		p = 2*l -q;
		r = hue2rgb(p, q, h+1/3);
		g = hue2rgb(p, q, h);
		b = hue2rgb(p, q, h-1/3);
		
		print int(255*r)  " "  int(255*g)  " "  int(255*b);
	    }
	    function hue2rgb(p, q, t) {
		if (t < 0) t += 1;
		if (t > 1) t -= 1;
		if (t < 1/6) return p + (q - p) * 6 * t;
		if (t < 1/2) return q;
		if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
		return p;
     	    }
	  ' < /dev/null)
	    
	   ;;
	2) 			# RGB
	    r="255*$2/100"	# Convert from 0--100% to 0--255 
	    g="255*$3/100"
	    b="255*$4/100"

	    ;; 
	*) echo "Unknown universal color space '$1'." >&2
	   exit 1
    esac


    hex=$(echo "scale=0; 
	        obase=16; 
		$r * 256 * 256 + $g * 256 + $b"  |  bc -q)

    while [[ ${#hex} -lt 6 ]]; do
	hex=0$hex
    done
    echo $hex
}


print_row() {
    local channel="${1}"
    shift
    local symbol="${1}"
    shift
    local data=("$@")
    
    printf "%10s" "${channel}"	# "Hue" or "Red" 
    echo -n "${symbol}"		# Degree or percent symbol.
    for i in {0..15}; do
	printf "%4s" ${data[$i]}
    done
    echo
}

get_screen_width() {
    # Default width is 800px, as on a VT340
    local width=800

    # Send control sequence to query the sixel graphics geometry to
    # find out how large of a sixel image can be shown.
    IFS=";"  read -a REPLY -s -t 0.25 -d "S" -p $'\e[?2;1;0S' >&2
    if [[ ${REPLY[2]} -gt 0 ]]; then
        width=${REPLY[2]}
    else
        # Nope. Fall back to dtterm WindowOps to approximate sixel geometry.
        IFS=";" read -a REPLY -s -t 0.25 -d "t" -p $'\e[14t' >&2
        if [[ $? == 0  &&  ${REPLY[2]} -gt 0 ]]; then
            width=${REPLY[2]}
	else
	    if [[ "$DEBUG" ]]; then
		echo "Unable to detect screen width in pixels. Using $width.">&2
	    fi
        fi
    fi

    echo ${width}
}

get_char_cell_width() {
    # Detect, if we can, the width in pixels of each character cell.

    # On a VT340, the resolution is always 800x480, but the terminal
    # can show 80 or 132 character lines. On terminal emulators, the
    # screen resolution can change as well.

    local char_width

    # First try $'\e[16t' which may return the char cell size directly
    IFS=";" read -a REPLY -s -t 0.25 -d "t" -p $'\e[16t' >&2
    if [[ $? == 0  &&  ${REPLY[2]} -gt 0 ]]; then
        char_width=${REPLY[2]}
    else
	# That didn't work, let's derive it from the screen width 
	local screen_width=$(get_screen_width)
	local cols=$(tput cols)
	if [[ $cols -eq 0 ]]; then
	    cols=80
	    if [[ "$DEBUG" ]]; then
		echo "Unable to detect number of text columns. Using $cols." >&2
	    fi
	fi
	char_width=$((screen_width/cols))
    fi

    if [[ $char_width -eq 0 ]]; then
	char_width=10		# Default, but this should never happen.
    fi	

    echo $char_width
}

sixchar() {
    # Given a binary representation of six pixels (from bottom to top),
    # output the ASCII character that represents that sixel.
    if [[ -z $1 ]]; then
	echo "Usage: sixchar 000010" >&2
    else
	for b; do
	    printf "\x$(bc -q <<<'obase=16; ibase=2; x='$b'; x+111111')"
	done
    fi
}


show_sixel_swatch() {
    # Width of each color swatch = 4 character cells. (Usually 40px)
    local width=$(( 4 * $(get_char_cell_width) ))
    local half=$((width/2-1))	# Almost half the width.
    local h=$((half-3))		# A little extra space for a curvy brace.

    tput cuf 13			# Cursor forward 13 spaces
    echo -n ${DCS}'9;1;q'	# Sixel header
    for ((i=0; i<16; i++)); do
	echo -n "#${i}!${width}~" 	# ~ == all six pixels
    done
    echo "-"			# Graphics newline
    
    # Just for fun, draw an indicator to point to the hex representation.
    brace=""
    brace+="#7"        # Color index 7 is fg text, so hopefully visible.
    brace+="@"	       # @ == just top pixel.		000001
    brace+="A"	       # A == just second pixel.	000010
		       # 				000100
    brace+="!${h}C"    # C == row of just third pixel.	000100
		       # 				000100
    brace+="G"	       # G == just fourth pixel		001000
    brace+="o"	       # all but top four        111111 110000
    brace+="G"	       # 				001000
		       # 				000100
    brace+="!${h}C"    # C == row of just third pixel.	000100
		       # 				000100
    brace+="A"	       # A == just second pixel.	000010
    brace+="@"	       # @ == just top pixel.		000001
    brace+="?"	       # ? == Graphics space (none)	000000
    for ((i=0; i<16; i++)); do
	echo -n ${brace}
    done
    echo "-"

    echo -n "#7!${half}?~"
    for ((i=0; i<15; i++)); do
	echo -n "#7!$((width-1))?~"
    done

    echo -n ${ST}
}



########################################################################
# Main

# Request Color Table Report
# NB: at 9600 bps, it takes over 1.25s for a genuine VT340 to respond.
if ! IFS=$'/\es' read -a REPLY -t 2 -s -p ${CSI}'2;2$u' -r -d '\\'; then
    echo Terminal did not respond. >&2
    if [[ ! $DEBUG ]]; then
	exit 1
    else
	echo Faking response code for debugging. >&2
	REPLY=( "" "P2$" "0;2;0;0;0" "1;2;20;20;79" "2;2;79;13;13" "3;2;20;79;20" "4;2;79;20;79" "5;2;20;79;79" "6;2;79;79;20" "7;2;46;46;46" "8;2;26;26;26" "9;2;33;33;59" "10;2;59;26;26" "11;2;33;59;33" "12;2;59;33;59" "13;2;33;59;59" "14;2;59;59;33" "15;2;79;79;79" )
    fi
fi

# Response data was originally separated by slashes, but was cut by IFS.
# Response prefix is ESC P 2 $ s and suffix is ESC \.
# However, since we have IFS cutting on /, ESC, and the letter s,
# we can simply ignore the first two elements of the REPLY array.
REPLY=("${REPLY[@]:2}")

# Degree character in current locale (if possible) for showing Hue angle
if ! degree=$(echo $'\xb0' | iconv -f latin1 2>/dev/null); then
    degree=$'\e(0f\e(B'		# Degree symbol using VT100 ACS charset 
fi

if [[ $DEBUG ]]; then
    degree=$'\e(0f\e(B'		# Force testing VT100 ACS charset 
fi

# Now, each element is of the form  Pc ; Pu ; Px ; Py ; Pz where
# 	Pc is color index (0 to 15)
#	Pu is universal color space (1 for HLS, 2 for RGB)
#	Px,Py,Pz are either Hue, Lightness, Saturation or Red, Green, Blue.
#
# Note that Hue ranges from 0 to 360. All other values range from 0 to 100.
# (Also note that Hue 0 == Hue 360.)
#

# Table header
x=(. "Hue Angle"  "Red")
y=(. "Lightness"  "Green")
z=(. "Saturation" "Blue")

# Symbol: degree for Hue or percent for Red.
symbol=(.  " $degree "  " % ")


# Print index row
tput rev
echo -n "      Index: "
printf "%4s" {0..15}
echo -n "   "
tput sgr0
echo

# Read reply into arrays for easier printing  
for entry in "${REPLY[@]}"; do
    IFS=";" read Pc Pu Px Py Pz <<<"$entry"
    Ac+=($Pc)
    Au+=($Pu)
    Axs+=("${symbol[$Pu]}")
    Ax+=($Px)
    Ay+=($Py)
    Az+=($Pz)
    # Pu is last entry's color space. 1==HLS, 2==RGB.
    if [[ $DEBUG -gt 0 ]]; then Pu=$DEBUG; fi
    Ah+=( $(hlsrgb2hex $Pu $Px $Py $Pz) )
done


print_row "${x[$Pu]}"  "${symbol[$Pu]}"  "${Ax[@]}" # "Hue" or "Red"
print_row "${y[$Pu]}"  " % "  "${Ay[@]}"	    # "Lightness" or "Green"
print_row "${z[$Pu]}"  " % "  "${Az[@]}"   	    # "Saturation" or "Blue"


# Show sixel color swatch
show_sixel_swatch
if [[ ! $XTERM_VERSION ]]; then echo; fi # Work around xterm sixel newine bug

# Show RGB hex value		     
echo -n "   RGB hex:"
for i in {0..15..2}; do
    echo -n " ${Ah[i]} "
done
echo
echo -n "               "
for i in {1..15..2}; do
    echo -n " ${Ah[i]} "
done
echo


######################################################################
# Documentation

## From DEC VTxxx Text Programming, page 206, "VT300 Reports"
#
# Use the following format to request a color table report.
#
# - DECRQTSR Request Color Table Report
#
# 	CSI	2	;	Ps2	$	u
# 	9/11	3/2	3/11	3/?	2/4	7/5
#
# where
#
# CSI, the Control Sequence Introducer, is 0x9B or ESC [ in a 7-bit environment.
# 
# Ps2 indicates the color coordinate system the terminal uses to send
# the report.
#
# 	Ps2		Color Coordinate System
# 	0 or none	HLS (default)
# 	1		HLS
# 	2		RGB

## From DEC VTxxx Text Programming, page 307, "VT300 Reports"
#
# DECCTR: Color Table Report from VT300 to Host the terminal sends
# this sequence is response to a Request Terminal State Report
# (DECRQTSR). DECCTR informs the host of the terminal's current color
# settings.
#
# PROGRAMMING TIP: Applications can use the information in the color
# table report to save the current color map. Later, the application
# can restore the saved color map.
#
## From DEC VTxxx Text Programming, page 308, "VT300 Reports"
#
# This operation is useful for applications that need to temporarily
# change the terminal's color map. When the application is finished,
# it can restore the color map that was in effect before the
# application changed it. You use the restore terminal state (DECRSTS)
# function to restore the color map. DECRSTS is described in the next
# section.
#
# 	DCS	2	$	s	D...D	ST
# 	9/0	3/2	2/4	7/3	...	9/12
#
# where
#
#	DCS is the Device Control String (0x90 or ESC P in 7-bit environments),
#
# 	D...D is the data string containing the color table information. 
#
#  	ST is the String Terminator (0x9C or ESC \ in 7-bit environments).
#
# The data string is divided into groups of five values, as follows.
#
# 	Pc;Pu;Px;Py;Pz / Pc;Pu;Px;Py;Pz / ...
# 
# where
#
# 	Pc is the color number (0 through 255).
#
#	; (semicolon, 3/11) separates the parameters.
#
# 	Pu indicates the universal coordinate system used.
#		Pu	Coordinate System
#		1	HLS (hue, lightness, saturation)
#		2	RGB (red, green, blue)
#
#	Px; Py; Pz are color coordinates in the specified coordinate system.
#
#	Parameter	HLS Values		RGB Values
#	Px	 	0 to 360 (hue angle)	0 to 100 (red intensity)
#	Py 		0 to 100 (lightness)	0 to 100 (green intensity)
#	Pz		0 to 100 (saturation)	0 to 100 (blue intensity)
#
## From DEC VTxxx Text Programming, page 309, "VT300 Reports"
#
# Restore Terminal State (DECRSTS) — VT300 Mode Only
# 
# This sequence restores the terminal to a previous state specified in
# a terminal state report (DECTSR). There are two terminal state
# reports.
#
#	Terminal state report (DECTSR)
#	Color table report (DECCTR)
#
# PROGRAMMING TIP: Applications can use DECRSTS to restore the
# terminal to a previous operating state specified in a terminal state
# report. See the "Terminal State Report (DECTSR)" and "Color Table
# Report (DECCTR)" sections in this chapter.

# Available in: VT300 mode
#

# 	DCS	Ps	$	p	D...D	ST
#	9/0	3/?	2/4	7/0	...	9/12
#
# where
#
# 	DCS	Device Control String, 0x90 or ESC P in 7-bit environments.
#
# 	Ps 	indicates the format of the data string (D...D). 
#		You can use one of the two following formats for the
# 		the data string. These formats correspond to the
# 		formats used by the two terminal state reports
# 		(DECTSR). Make sure you use the format used by the
# 		report you are restoring.
#
# 		Ps	Data String Format
#		0	Error, restore ignored.
#		1	Selects the format of the terminal state report (DECTSR)
#		2	Selects the format of the color table report (DECCTR)
#
# 	D...D	is a data string that contains the restored information.
#		This string is identical to the data string used by the
#		report you are restoring.
#
#	ST	String Terminator, 0x9C or ESC \ in 7-bit environments.
#
# Notes on DECRSTS
#
# • If there is an invalid value in the DECRSTS sequence, the terminal
#   ignores the rest of the sequence. This action may leave the
#   terminal in a partially restored state.
#
# • Software should not expect the format of the terminal state report
#   (DECTSR) to be the same for all VT300 family members.
#
