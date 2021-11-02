#!/bin/bash

# Test of DECSTBM (Set Scrolling Region) and DECSDM.

# How does DECSDM (sixel display mode) which always starts sixel
# images in the "home" position interact with DECOM (origin mode)
# DECSTBM (scrolling margins) which changes the home position?

# Answer: DECSDM ignores DECOM and DECSTBM

CSI=$'\e['

echo -n ${CSI}H${CSI}J		# Clear screen
echo -e "\n\n\t\tTesting DECSTBM (scrolling region) interaction with DECSDM"

top=10
bot=15
echo
echo -n ${CSI}"$((top-1));1H"
echo -e "\tvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo -n ${CSI}"$((bot+1));1H"
echo -e "\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

echo -e "\t\tScrolling region set from $top to $bot" 
echo -e "\t\tEnabled DECSDM Sixel Display Mode (sixels start at home)"
echo -e "\t\tand DECOM Origin Mode (Cursor cannot leave region)"

# DECSTBM
echo -n "${CSI}${top};${bot}r"

# DECOM
echo -n "${CSI}?6h"

# DECSDM
echo -n ${CSI}"?80h"

echo -n ${CSI}"H"	# Move to home position
echo "<-- HOME location for text is now within the scrolling region"

#convert -size x40 -fill gray80 -background black \
#	label:"$(LANG=utf-8 printf '\u21f1 Sixel Display Mode home is here')" \
#	+dither -colors 2 sixel:- >sdmhome.six

# Send a sixel image: does it start at home or is it within the region?
cat sdmhome.six

echo "Another line of text immediately after the sixels."
echo "Note the extra blank line caused by a bug in ImageMagick which"
echo "appends a text newline after every sixel image."

# Unset scrolling region.
echo -n ${CSI}"r"

# Disable DEC Origin Mode: Cursor can leave region
echo -n "${CSI}?6l"

# Reset DECSDM: Sixels are inline with text and scroll
echo -n ${CSI}"?80l"

# Place cursor at end of screen
echo -n ${CSI}"$((bot+6));1H"
