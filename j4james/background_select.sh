#!/bin/bash

# Test the effect of DECGRA on the Background Select functionality.

# When the Background Select parameter is set to 0 or 2, the background of the
# image is filled with color map entry 0, before any sixel data is output. The
# extent of the the filled area is determined by the dimensions defined in the
# DECGRA raster attributes. If not specified, the preceding DECGRA's attributes
# are used (if there were multiple DECGRAs), or otherwise the maximum extent.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n ${CSI}'?7h'
yes E | tr -d '\n' | head -c 1920

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

# This should fill area extending to the bottom right of the screen.
#-The DECGRA is ignored when not followed by a command or sixel data.
set_cursor_pos 21 73
echo -n ${DCS}'q"1;1;10;10'${ST}

# This should fill an area of 80x80px.
# The color introducer is enough to activate the DECGRA dimensions.
set_cursor_pos 1 1
echo -n ${DCS}'q"1;1;80;80#'${ST}

# This should fill an area 80px wide extending to the bottom of the screen.
# The zero DECGRA height parameter defaults to the maximum extent.
set_cursor_pos 21 1
echo -n ${DCS}'q"1;1;80;0#'${ST}

# This should fill an area 80px high extending to the width of the screen.
# The zero DECGRA width parameter defaults to the maximum extent.
set_cursor_pos 1 73
echo -n ${DCS}'q"1;1;0;80#'${ST}

# This should fill an area of 80x80px.
# The second DECGRA overrides the first, and the missing height parameter
# falls back to the value from the first DECGRA.
set_cursor_pos 11 73
echo -n ${DCS}'q"1;1;10;80"1;1;80?'${ST}

# This should fill an area of 80x80px.
# The second DECGRA overrides the first, and the missing width parameter
# falls back to the value from the first DECGRA.
set_cursor_pos 21 37
echo -n ${DCS}'q"1;1;80;10"1;1;;80?'${ST}

# This should fill an area of 80x80px.
# The second DECGRA overwrites the first, but the last one is ignored,
# since it's not followed by anything.
set_cursor_pos 1 37
echo -n ${DCS}'q"1;1;120;40"1;1;80;80"1;1;40;120'${ST}

# This should fill an area of 80x80px.
# The ? sixel is enough to activate the last DECGRA in this case.
set_cursor_pos 11 1
echo -n ${DCS}'q"1;1;120;40"1;1;40;120"1;1;80;80?'${ST}

# This should fill an area of 180x180px, containing a 60x60px blue square.
# The first DECGRA applies to the DECNL, moving down by 90px (AR 15:1).
# The second applies to the sixels, producing a height of 60px (AR 10:1).
set_cursor_pos 4 18
echo -n ${DCS}';0q"15;1-"10;1;180;180?-#1!60?!60~'${ST}

# This should fill an area of 180x180px in blue.
# When the background select is 1, the DECGRA dimensions have no effect.
set_cursor_pos 4 46
echo -n ${DCS}';1q"15;1;240;240-#1!180~-!180~'${ST}

# This should fill an area of 60x60px in black.
# The first 30px are skipped with a DECGNL, ? triggers a background fill of
# 60x30, and another 60x30 is drawn in black. The final 60x30 is transparent,
# despite the background select of 2, because it's beyond the image height.
set_cursor_pos 10 52
echo -n ${DCS}';2q"5;1;60;30-?-#0!60~-!60?'${ST}

set_cursor_pos 7 1
