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
# * Add command line options to print just a region of the screen.
#
# * Command line args should allow percentage or even row & column,
#   not require pixel coords.
#
# * Don't presume ST will be at start, but remove it if it is. (sed?).
#
# * Investigate if there is some secret, undocumented way to enable
#   level 2 printing from the application side.

########################################

# Turn on host flow-control in case the VT340 overwhelms it with data. (Ha ha).
stty ixoff

# REGIS Screen Hard Copy with no parameters sends the whole screen, 
# offset 50 pixels to the right. We use P[0,0] to disable the offset.
# Full screen on VT340 is equivalent to X1=0; Y1=0; X2=799; Y2=479
REGIS_H="S(H(P[0,0]))"
REGIS_H="S(H)"

# Requests larger than the screen get cropped to full screen.
X1=0; Y1=0; X2=4095; Y2=4095

# For debugging, we can send just a small cropped part. (100x100, ~30 seconds)
if [[ "$1" == "-debug" ]]; then X1=350; X2=449; Y1=190; Y2=289; fi

if (( X1>0 || Y1>0 || X2>0 || Y2>0 )); then
    REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"
fi

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator
FF=$'\f'			# Form Feed

echo -n ${CSI}'?2i'		# (MC) Send graphics to host, not printer

# DECGEPM: Graphics Expanded Print Mode (only for Level 1 Graphics)
#echo -n ${CSI}'?43l'		# Compressed:  6" x 3" printout, 800x240
echo -n ${CSI}'?43h'		# Expanded:   12" x 8" printout, 1600x480

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in black and white
echo -n ${CSI}'?44h'		# Print in color

# DECGPCS: Print Graphics Color Syntax
#echo -n ${CSI}'?45l'		# Print using HLS colors
echo -n ${CSI}'?45h'		# Print using RGB colors (ImageMagick reqs)

# DECGPBM: Print Graphics Background Mode  (always on for level 1 graphics)
#echo -n ${CSI}'?46l'		# Do not send background (transparent bg)
echo -n ${CSI}'?46h'		# Include background when printing

# DECGRPM: Graphics Rotated Print Mode (90 degrees counterclockwise)
echo -n ${CSI}'?47l'		# Use compress or expand to fit on printer.
#echo -n ${CSI}'?47h'		# Rotate image CCW. 8" x 12" printout

# Send a hard copy using REGIS
echo -n ${DCS}'p'		# Enter REGIS mode
echo -n ${REGIS_H}		# Send hard copy sequence
# Note: We send the String Terminator to exit ReGIS mode at the script end.

###
# BUGGY: MC (Media Copy) DOES NOT SEEM TO WORK FOR GRAPHICS TO HOST. 
# WOULD IT RESPOND IF I HAD A PRINTER? WHY DOES ReGIS WORK and this not?
#echo -n ${CSI}'i'		# Print screen (MC, Media Copy)
###

###
# TYPICAL `read` IDIOM DOES NOT GET A RESPONSE.
# Partly because the VT340 sends ST *before* a print as well as after.
#if ! IFS=$'\e' read -a REPLY -s -p ${CSI}'i' -r -d '\\'; then
#    echo Terminal did not respond.
#    exit 1
#fi
###

###
# Wait for data to start... so we can timeout when it stops
# XXX Ooops, this doesn't work since VT340 can pause in the middle of printing.
#while ! read -t 0; do
#    sleep 1
#    echo -n "." >>err.out
#done
###


# Read until the first backslash to dispose of the String Terminator
# (`Esc \`) sent before the print out. Note that ImageMagick and
# libsixel fail to read images that begin with `Esc \`.
read -r -s -d "\\"

# Read until second backslash to get all data up to the String Terminator.
while read -r -s -d "\\"; do
    if [[ -z "$REPLY" ]]; then
	# Debugging 
	echo >&2
	echo 'WARNING: Got an empty REPLY.' >&2
	# How is this happening? Even for ST, we should get an ESC first.
	# If read is timing out, the 'while' loop should just exit.
	# But even after this the terminal keeps sending more data...
	# Trying to Media Copy complex images like cp16gray.six triggers this.
    fi

    if LANG=C egrep -q "[^[:print:][:cntrl:]]" <<<"$REPLY"; then
	# Debugging: check for non ASCII characters
	echo >&2
	echo 'WARNING: 8-bit Glitch. Received data with the eighth bit set high.'>&2
    fi

    # Debugging: log it to err.out
    date +"%s: " | tr -d '\n' >&2
    echo -n "$REPLY" | sed $'s/\e/Esc /g' |  cat -v >&2

    # Write the response to the file
    echo -n "$REPLY" 

    # read's delimiter is backslash '\', so make sure it isn't consumed.
    if [[ "$REPLY\\" == *$ST ]]; then echo -n "\\"; break; fi
    echo "," >&2
done > print.six   2> err.out

# All done reading the sixels, so it's safe to exit REGIS mode now.
echo -n ${ST}			


# TODO: Check if image got saved to print.six correctly as Level 2.
# If it didn't, then use ImageMagick to convert the image to the
# proper aspect ratio. (E.g., convert -sample 50%x100%).

