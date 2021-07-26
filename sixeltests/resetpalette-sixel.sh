#!/bin/bash
# hackerb9 July 7, 2021
# Reset VT340 color map to system default

# NOTE THIS FILE RESETS THE VT340 PALETTE IN SIXEL'S PECULIAR WAY, 
# USING THE *ORDER* IN WHICH SIXEL COLORS ARE ASSIGNED.

# This is not the "right" way. However, I'm keeping this script around
# because it does demonstrate the non-intuitive way the sixel colormap
# affects the VT340's colormap and the text foreground/background colors.

# One would presume that the sixel color table and the VT340 color
# table would have a one-to-one mapping, but that is not the case.

# Sixel colors, no matter what index is used, are assigned
# sequentially to the VT340's color table starting with entry number
# one (not zero!). This is bizarre, but has a nice side effect which
# is possibly the intent: the screen's background color (VT340 entry
# #0) is not changed unless a sixel image defines all sixteen colors.
# Additionally, if your sixel image uses five or less colors,
# displaying it will not affect the VT340's text foreground (entry #7).

# What is the right way to reset the color palette? I believe it is
# DECRSTS (DEC Reset Terminal State). Please see resetpalette.sh.

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

# However, BEWARE that defined sixel colors are assigned *sequentially*
# to VT colors starting with VT color #1 (NOT #0). So, no matter what
# number you assign colors in the sixel map, it is unrelated to the VT
# color. All that matters is the *order* you assigned them.

# ADDITIONAL BUGABOOS:
# The SIXTH color you assign will change the text foreground color,
# THE FIFTEENTH changes the bold text foreground color and
# the SIXTEENTH changes the text background. 

# Note: although the colors listed here are taken directly from the
# VT340 graphics programming guide, they are slightly brighter than
# the actual system defaults. This may be because the chapter was
# describing using the colors for REGIS, not sixel.
# 
# The colortable.sh shell script shows that some colors appear to be
# one less than what is documented. 

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
