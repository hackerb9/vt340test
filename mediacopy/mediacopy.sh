#/!/bin/bash

# Save current screen from a VT340 as a sixel screenshot in print.six. 

# THIS WORKS ON A GENUINE VT340, BUT IS NOT WELL TESTED.

# For this to work, the VT340 probably has to have the following
# settings changed in the Setup menu:
#
# 1. Printer Set-up -> Send form feed
# 2. Printer Set-up -> Level 2 graphics

# Questions:
#
# * Why doesn't Compressed mode send last line of sixel data?
# * Why doesn't Expanded mode send form feed?
# * Does Rotated mode solve the above problems?
# * Do we truly need Level 2 graphics?
# * If I only use Expanded mode, can I avoid asking user to change Setup?
# * Should this script print the background by default or not? Probably so.
# * How do I inquire the geometry of the graphics screen? 
# * Does the VT340 send 1:1 pixel aspect ratio sixel data when the
#   Set-up -> Printer Type is set to DEC's LA75 or LN03 printer?

# TODO:
# * After saving to print.six convert to PNG and rescale correctly.
# * Try Rotated graphics mode. 
# * Don't presume ST will be at start, but remove it if it is. (sed).
# * Add command line options to print just a region of the screen.
# * Command line args should allow percentage, not required pixel coords.
# * Maybe change default to print background.

########################################

# REGIS Screen Hard Copy with no parameters sends the whole screen, 
# offset 50 pixels to the right. We use P[0,0] to disable the offset.

# Full screen is equivalent to X1=0; Y1=0; X2=799; Y2=479
REGIS_H="S(H(P[0,0]))"

# For debugging, we can send just a small cropped part.
X1=350; Y1=190; X2=450; Y2=290
#REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"	# This works
#REGIS_H="S(H(P[0,0][$X1,$Y1][$X2,$Y2]))"	# This does not


CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator
FF=$'\f'			# Form Feed

echo -n ${CSI}'?2i'		# (MC) Send graphics to host, not printer

# DECGEPM: Graphics Expanded Print Mode
#echo -n ${CSI}'?43l'		# Compressed:  6" x 3" printout, 800x240
echo -n ${CSI}'?43h'		# Expanded:   12" x 8" printout, 1600x480

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in black and white
echo -n ${CSI}'?44h'		# Print in color

# DECGPCS: Print Graphics Color Syntax
#echo -n ${CSI}'?45l'		# Print using HLS colors
echo -n ${CSI}'?45h'		# Print using RGB colors (ImageMagick reqs)

# DECGPBM: Print Graphics Background Mode
echo -n ${CSI}'?46l'		# Do not send background when printing
#echo -n ${CSI}'?46h'		# Include background when printing

# DECGRPM: Graphics Rotated Print Mode
echo -n ${CSI}'?46l'		# Compress Y axis (or expand X).
#echo -n ${CSI}'?46h'		# Swap X and Y axes. 8" x 12" printout, 960x800

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
while read -r -s -t $((3*60)) -d "\\"; do
    if [[ -z "$REPLY" ]]; then
	echo >&2
	echo End of transmission. >&2
	break;
    fi
    echo -n "$REPLY" 
    echo -n "$REPLY" | cat -v >&2
    if [[ "$REPLY" == *$FF ]]; then break; fi
    if [[ "$REPLY\\" == *$ST ]]; then break; fi     # read's delimiter is '\'
    echo "," >&2
done > print.six   2> err.out


# XXX we're not receiving the final line in "compressed" mode.
# Kludge: Don't leave terminal in sixel mode after catting file.
echo -n ${ST} >> print.six


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

# * Compressed prints lose vertical resolution as they use the printer's
#   2:1 pixel aspect ratio, giving an effective resolution of 800x240. 

# * Expanded prints have the proper vertical resolution, but they
#   double the horizontal resolution (1600x480) in an attempt to make
#   printouts look right on the DEC printers' 2:1 pixel aspect ratio.

# * Rotated prints...
#   ... I have not tried yet.  XXX TODO.

# * It takes several minutes to send a full screen of sixel data, so
#   you'll want to print just a cropped part if you're debugging this.

# * Before sending the sixel data, the VT340 sends ST (`Esc \`). 
#   However, ImageMagick gets confused by sixel images that start with
#   the String Terminator (it thinks they have only one pixel).

# * VT340 defaults to printing in "mono". Must set to "color" using
#   the DECGPCM (`Esc [?44h`) escape sequence.
  
# * ImageMagick cannot handle HLS sixel graphics. Must set to RGB by
#   using DECGPCS (`Esc [?45h`).

# * When sending compressed prints, I can't seem to read the VT340
#   String Terminator sequence that marks the end of the print.
#   Weirdly, it *does* display on the screen as "^[\". It shows even
#   with 'stty -echo' set, which should have prevented anything from
#   showing. It must be some bizzaro vt340 firmware fluke.

# * Since I can't read the end of print message (ST), I tried using a
#   repeated 1 second time out. However, that doesn't always work. In
#   particular, I know the VT340 takes a long pause in the middle of
#   sending an image when Print Graphics Background Mode is turned
#   off. There may be other circumstances. Oops, spoke too soon, now
#   the delay is happening even when the Background Mode is turned on.
#   Timeouts cannot be used.

# * Since I can't rely on getting the String Terminator, nor can I use
#   a timeout if no data has been received for a while, one solution
#   is to wait for a Form Feed (^L) at the end. However, that only
#   gets sent if you enable it manually in the VT340 Set-up. I do not
#   see a way to enable the Print Terminator via escape sequences.
#   Also, it only seems to work in Compressed graphics mode, not
#   Expanded.

# * Aspect ratio is displayed incorrectly in ImageMagick and xterm.
#   Width seem fine, height is squashed by half. [I believe these
#   programs simply ignore sixel's ability to change the pixel aspect
#   ratio to 2:1.]

# * Compressed Print Mode (the default) has a few problems
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

# * Expanded Print Mode is better in that no resolution is lost, but
# * still has a few problems:
#
#   * ImageMagick can't read it if the starting ST isn't removed.
#     (Treats the images as a single pixel)
#
#   * ImageMagick and XTerm get the geometry wrong. They show expanded
#     prints as 1600x480 instead of 1600x960.
#
#   * Image is too large to fit on screen when catted to VT340. Repair
#     with `convert print.six temp.png`, then `convert -geometry
#     50%x100% temp.png foo.png`. (Due to an ImageMagick 6.9.11-60 bug,
#     it must be done in two steps or else the image is completely
#     black.)
#
#   * Print Terminator of Form Feed doesn't seem to get sent even
#     when it is enabled in the Set-Up screen. This is annoying
#     because I want to use that to detect the end of the printout.
#     (On the upside, the final line, including ST *are* sent.)

# * Printout is shifted 50 pixels to the right by default, use the
#   P[0,0] suboption to REGIS's H() command to undo that offset.
#   Note that the order of nesting parentheses is incorrect in the
#   VT3xx documentation:
#
#	REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"	# This works
#	REGIS_H="S(H(P[0,0][$X1,$Y1][$X2,$Y2]))"	# This does not
