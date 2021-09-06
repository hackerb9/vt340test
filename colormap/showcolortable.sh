#!/bin/bash

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

hlsrgb2hex() {
    # Convert percent RGB (eventually HLS) to web RGB hexadecimal color format.
    local hex
    local r="255*$2/100"	# Convert from 0--100% to 0--255 
    local g="255*$3/100"
    local b="255*$4/100"

    case $1 in
	1) 			# HLS not implemented yet
	    
	   ;;
	2) 			# RGB
	    hex=$(echo "scale=0; 
	    	        obase=16; 
			$r * 256 * 256 + $g * 256 + $b"  |  bc -q)
	    ;; 
	*) echo "Unknown universal color space '$1'." >&2
	   exit 1
    esac

    while [[ ${#hex} -lt 6 ]]; do
	hex=0$hex
    done
    echo $hex
}


printrow() {
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

####
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
    degree=$'\e(0f\e(B'		# Force using VT100 ACS charset 
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
echo -n "      Index: "
tput smul
printf "%4s" {0..15}
tput rmul
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
    Ah+=( $(hlsrgb2hex $Pu $Px $Py $Pz) )
done

# Pu is last entry's color space. 1==HLS, 2==RGB.
if [[ $DEBUG -gt 0 ]]; then Pu=$DEBUG; fi

printrow "${x[$Pu]}"  "${symbol[$Pu]}"  "${Ax[@]}" # "Hue" or "Red"
printrow "${y[$Pu]}"  " % "  "${Ay[@]}"		   # "Lightness" or "Green"
printrow "${z[$Pu]}"  " % "  "${Az[@]}"   	   # "Saturation" or "Blue"


# Show sixel color swatch
#XXX


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
