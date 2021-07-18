#!/bin/bash
# hackerb9 July 7, 2021
# Reset VT340 color map to system default

# NOTE THIS IS CURRENTLY DONE IN AN UGLY WAY, USING THE ORDER THE
# SIXEL COLORS ARE ASSIGNED. DO NOT USE THIS YET.

# The right way is to use DECRSTS (DEC Reset Terminal State), however,
# the docs specifically say that the strings are not portable across
# VT300 family members, so it would be useful only for the VT340. I
# believe DECRSTS should be added to TERMINFO so that a soft reset
# will fix color map problems.
# 


DCS=$'\eP'			# Device Control String
RA='"'				# Raster Attributes (pixel shape, dimensions)
ST=$'\e\\'			# String Terminator


# Device Control String "q" starts Sixel data
echo -n "${DCS}0;2;0q"

# Mandatory Raster Attributes
echo -n "${RA}"
# 1 to 1 pixel aspect ratio (square)
echo -n "1;1;"
# Image Width x Height in pixels
# Note: used only for clearing background, does not limit image.
echo -n "800;480"   
     				

# Color mapping syntax:  # Pc ; Pu; Px; Py; Pz
# Hash is "Color Introducer"
# Pc: color entry from 0 to 15
# Pu: color coordinate system 1 (HLS) or 2 (RGB)
# Px,Py,Pz: Hue, Lightness, Saturation or Red, Green, Blue
#	All range 0 to 100 percent, except Hue which spans 0 to 360 degrees.
#
# Note that the VT340 uses color entry #0 as background and #7 as foreground.

# However, BEWARE that defined sixel colors are assigned sequentially
# to VT colors starting with VT color #1 (NOT #0). So, no matter what
# number you assign colors in the sixel map, it is unrelated to the VT
# color. All that matters is the *order* you assigned them.

# The SIXTH color you assign will become the text foreground color and
# the SIXTEENTH becomes the text background!!!! 

# Note: although the colors listed here are taken directly from the
# VT340 graphics programming guide, they are slightly brighter than
# the actual system defaults. This may be because the chapter was
# describing using the colors for REGIS, not sixel.

# TODO: Or, perhaps
# instead of ranging from 0 to 100, these colors range from 0 to 99?

# Note that values of 97,98,99,100, and beyond all seem to be equal in
# appearance.

echo -n "#1;2;20;20;80;"	# VT color #1 is blue

echo -n "#2;2;80;13;13;"	# VT color #2 is red
echo -n "#3;2;20;80;20;"	# VT color #3 is green

echo -n "#4;2;80;20;80;"	# VT color #4 is magenta
echo -n "#5;2;20;80;80;"	# VT color #5 is cyan
echo -n "#6;2;80;80;20;"	# VT color #6 is yellow

echo -n "#7;2;53;53;53;"	# VT color #7 is gray 50% and FG text color
echo -n "#8;2;26;26;26;"	# VT color #8 is gray 25%

echo -n "#9;2;33;33;60;"	# VT color #9 is pastel blue
echo -n "#10;2;60;26;26;"	# VT color #10 is pastel red
echo -n "#11;2;33;60;33;"	# VT color #11 is pastel green

echo -n "#12;2;60;33;60;"	# VT color #12 is pastel magenta
echo -n "#13;2;33;60;60;"	# VT color #13 is pastel cyan
echo -n "#14;2;60;60;33;"	# VT color #14 is pastel yellow

echo -n "#15;2;80;80;80;"	# VT color #15 is gray 75% and BOLD text color

echo -n "#0;2;0;0;0;"		# VT color #0 is black and BG text color

echo -n "${ST}"
