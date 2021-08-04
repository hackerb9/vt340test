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
#   with the eighth bit set high and then pause for a long time before
#   transmitting again. Test image tty.jpg triggers this glitch.
#
#   Perhaps my RS232 cable is flakey and it is just that the complex
#   images take longer to send? Should double check, but it seems to
#   always glitch at the same spot in the image.

# * When image has finished saving, make sure it is a level 2 image.
#   If not, show the commands needed to rescale to 1:1 aspect ratio.
#   (Also, give a message suggesting that the user change the printing
#   mode to level2 in the VT340 Set-Up screen).
#
# * After saving to print.six convert to PNG if ImageMagick is installed.
#
# * Add command line options to print just a region of the screen.
#
# * Command line args should allow percentage, not required pixel coords.
#
# * Don't presume ST will be at start, but remove it if it is. (sed?).
#
# * Investigate if there is some secret, undocumented way to enable
#   level 2 printing from the application side.

########################################

# REGIS Screen Hard Copy with no parameters sends the whole screen, 
# offset 50 pixels to the right. We use P[0,0] to disable the offset.
# Full screen on VT340 is equivalent to X1=0; Y1=0; X2=799; Y2=479
REGIS_H="S(H(P[0,0]))"

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
echo -n ${ST}			# Exit REGIS mode


###
# BUGGY: MC (Media Copy) DOES NOT SEEM TO WORK FOR GRAPHICS TO HOST. 
# WOULD IT RESPOND IF I HAD A PRINTER? 
#echo -n ${CSI}'i'		# Print screen (MC, Media Copy)
###

###
# TYPICAL `read` IDIOM IS BUGGY. DOES NOT GET A RESPONSE. WHY?
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

# TODO: Do we still need this now that we only use expanded mode?
# We were not receiving the final line in "compressed" mode.
# Kludge: Don't leave terminal in sixel mode after catting file.
#echo -n ${ST} >> print.six

# TODO: Check if image got saved to print.six correctly as Level 2.
# If it didn't, then use ImageMagick to convert the image to the
# proper aspect ratio. (E.g., convert -sample 50%x100%).




# Notes:

# * There are multiple options that affect the sixel data:
#
#   1. [Level 1]/Level 2 graphics	# Only in Set-Up
#   2. [No Terminator]/Send formfeed,	# Only in Set-Up
#   3. [Compressed]/Expanded,			# DECGEPM 43
#   4. [Mono]/Color,				# DECGPCM 44
#   5. [HLS]/RGB,				# DECGPCS 45
#   6. [No Background]/Print Background,	# DECGPBM 46
#   7. [Compressed+Expanded]/Rotated,		# DECGRPM 47
#   
#      [VT340 defaults are in square brackets.] 

# * Level 2 prints are the only known way to get a proper 1:1 pixel
#   aspect ratio. However, that requires the user to first go into the
#   VT340 Set-Up menu to enable it as there appears to be no escape
#   sequence to change from the default of Level 1. Phooey.
#
#     [Set-Up] key -> Printer Set-Up -> Sixel Graphics Level = level 2

# * Level 2 graphics ignores the compressed/expanded option.
#   Rotation does work.

# * Printout is shifted 50 pixels to the right by default, use the
#   P[0,0] suboption to REGIS's H() command to undo that offset.
#   Note that the order of nesting parentheses is incorrect in the
#   VT3xx documentation:
#
#	REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"	# This works
#	REGIS_H="S(H(P[0,0][$X1,$Y1][$X2,$Y2]))"	# This does not

# * Compressed prints lose vertical resolution as they use the printer's
#   2:1 pixel aspect ratio, giving an effective resolution of 800x240. 

# * Expanded prints have the proper vertical resolution, but they
#   double the horizontal resolution (1600x480) in an attempt to make
#   printouts look right on DEC printers' 2:1 pixel aspect ratio.

# * Rotating level 1 prints does not help as they still suffer the pixel
#   aspect ratio problems depending on compressed or expanded setting.
#   (400x480 or 800x960)

# * It takes several minutes to send a full screen of sixel data, so
#   you'll want to print just a cropped part if you're debugging this.

# * Before sending the sixel data, the VT340 sends ST (`Esc \`). 
#   However, ImageMagick gets confused by sixel images that start with
#   the String Terminator (it thinks they have only one pixel).

# * VT340 defaults to printing in "mono". Must set to "color" using
#   the DECGPCM (`Esc [?44h`) escape sequence.
  
# * ImageMagick cannot handle HLS sixel graphics. Must set to RGB by
#   using DECGPCS (`Esc [?45h`).

# * When sending level 1 compressed prints, I can't seem to read the
#   VT340 String Terminator sequence that marks the end of the print.
#   Weirdly, it *does* display on the screen as "^[\". It shows even
#   with 'stty -echo' set, which should have prevented anything from
#   showing. It must be some bizzaro vt340 firmware fluke.
#   Fortunately, it's unlikely anybody wants a compressed print.

# * Since I couldn't read the end of print message (ST), I tried using
#   a repeated 1 second time out. However, that doesn't always work.
#   In particular, the VT340 takes a long pause in the middle of
#   sending an image when Print Graphics Background Mode is turned
#   off. There may be other circumstances... Oops, spoke too soon, now
#   the delay is happening even when the Background Mode is turned on.
#   Moral: Timeouts cannot be relied on with using Media Copy to host.

# * Since I can't rely on getting the String Terminator with level 1
#   compressed graphics, nor can I use a timeout if no data has been
#   received for a while, one solution is to wait for a Form Feed (^L)
#   at the end. However, that only gets sent if you enable it manually
#   in the VT340 Set-up. I do not see a way to enable the Print
#   Terminator via escape sequences. Also, it only seems to work in
#   Compressed graphics mode, not Expanded.
#
#   Again: this is probably not worth fixing as people can just use
#   level 2 or expanded prints.

# * Level 1 aspect ratio is displayed incorrectly in ImageMagick and
#   xterm. Width seem fine, height is squashed by half. [I believe
#   these programs simply ignore sixel's ability to change the pixel
#   aspect ratio to 2:1.]

# * Level 1 Compressed Print Mode (the default) has a few problems
#
#   * Fonts look grotty (due to lower resolution)
#
#   * String Terminator (ESC \) at end of file gets shown on screen
#     instead of sent to the host which makes it hard (impossible?) to
#     tell when the the VT340 has finished.
#
#   * There is some other garbage shown on the screen after the ST,
#     looks like the first 80 characters of the printout.
#   
#   * ImageMagick and XTerm get the geometry wrong because they do not
#     understand a pixel aspect ratio of 2:1. They show the image as
#     800x240 instead of 800x480.

# * Level 1 Expanded Print Mode is better in that no resolution is
#   lost, but it still has a few problems:
#
#   * ImageMagick can't read it if the starting ST isn't removed.
#     (Treats the images as a single pixel)
#
#   * ImageMagick and XTerm get the geometry wrong. They show expanded
#     prints as 1600x480 instead of 1600x960.
#
#   * Image is too large to fit on screen when catted to VT340. Repair
#     with `convert -sample 50%x100% print.six print.png`.
#
#   * Print Terminator of Form Feed doesn't seem to get sent even
#     when it is enabled in the Set-Up screen. This is annoying
#     because I want to use that to detect the end of the printout.
#     (On the upside, the final line, including ST *are* sent.)
#
#   * Rotated & Expanded prints of a region begin with 0A XX P, where
#     XX is some random byte such as E3 or FC. It should begin with
#     newline (0A) then the 7-bit DCS sequence (ESC P). This seems to
#     be a bug. Changing those first two bytes to a single ESC makes
#     the sixel file valid.
#
#       ( echo -n $'\e'; tail -c+3 < rotated-expanded.six ) > foo.six
#
#     [UPDATE: After resetting my VT340 this bug is not reproducing].

