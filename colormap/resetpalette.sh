#!/bin/bash
# Reset color map using DECRSTS (DEC Reset Terminal State).

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

if [[ $1 == "-t" || $1 == "--text" ]]; then
    # If -t flag given, then just reset the text and background colors.
    maybe=:
fi

# Send DECRSTS for Color Table Report
echo -n ${DCS}'2$p'

echo -n "0;2;0;0;0/"	# VT color #0 is black and BG text color

$maybe echo -n "1;2;20;20;79/"	# VT color #1 is blue
$maybe echo -n "2;2;79;13;13/"	# VT color #2 is red
$maybe echo -n "3;2;20;79;20/"	# VT color #3 is green

$maybe echo -n "4;2;79;20;79/"	# VT color #4 is magenta
$maybe echo -n "5;2;20;79;79/"	# VT color #5 is cyan
$maybe echo -n "6;2;79;79;20/"	# VT color #6 is yellow

echo -n "7;2;46;46;46/"	   	# VT color #7 is gray 50% and FG text color
$maybe echo -n "8;2;26;26;26/"	# VT color #8 is gray 25%

$maybe echo -n "9;2;33;33;59/"	# VT color #9 is pastel blue
$maybe echo -n "10;2;59;26;26/"	# VT color #10 is pastel red
$maybe echo -n "11;2;33;59;33/"	# VT color #11 is pastel green

$maybe echo -n "12;2;59;33;59/"	# VT color #12 is pastel magenta
$maybe echo -n "13;2;33;59;59/"	# VT color #13 is pastel cyan
$maybe echo -n "14;2;59;59;33/"	# VT color #14 is pastel yellow

echo -n "15;2;79;79;79"		# VT color #15 is gray 75% and BOLD text color

echo -n ${ST}			# String Terminator



# NOTES

# DECRSTS is normally used after DECRQTSR (Request Terminal State Report)
# which can save the terminal's current color settings before altering them.

# But that doesn't work in all situations. In particular, if you cat a
# sixel file to your screen, there is no way to know what the previous
# colors were. That's where this script comes in. It simply sets the
# colors to the VT340 factory defaults (as recorded from a VT340+
# running firmware 3.7).

# Note that the docs specifically say that the strings are *not*
# portable across VT300 family members, so this script is useful only
# for the VT340. One would need a database of correct values for
# DECRSTS for each terminal.
#
# I believe, DECRSTS should be added to TERMINFO entry for "vt340" so
# that running `reset` will fix color map problems instead of having
# to use this script.

# Open questions:

# * Why are there two different builtin color maps ("color-1" and
#   "color-2") in the VT340 Global Set-Up screen? They are identical
#   and neither one gets changed when I use "Save Color Map" from the
#   Color Set-Up menu.
#
# * The VT340 allows the user to pick a custom palette that is saved
#   in non-volatile RAM. Is there a way to detect what that palette is?
#   It would be nice to be able to reset to what the user actually prefers,
#   instead of the factory default color table.
#
# * Is there truly no way to tell the VT340 to simply "reset to power
#   on defaults" for the color map?
#
# * I use the terms "palette", "color table", and "color map" interchangeably.
#   DEC documentation does that same. Variety is the spice of life.
