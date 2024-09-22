#!/bin/bash

# Test the effect of Background Select when an image scrolls.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'

# Enable reverse screen mode so the background is white
echo -n ${CSI}'?5h'

# Position the cursor 3 rows from the bottom
echo -n ${CSI}'22;35H'

# Fill 120x120 of the background in black (clamped to 3 rows, 60 pixels)
echo -n ${DCS}'q"1;1;120;120'

# Render a 60x60 square in blue on the bottom 3 rows
echo -n '#1!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~-'

# Render a 60x60 square in red, scrolling up another 3 rows
echo -n '#2!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~-!60~'

# Apply a bunch of graphic new lines to scroll the image up to the middle
echo -n '------------------------------'

# End the image sequence
echo -n ${ST}

# Move the cursor back to home
echo -n ${CSI}'H'