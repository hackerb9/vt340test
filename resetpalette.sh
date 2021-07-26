#!/bin/bash
# Reset color map using DECRSTS (DEC Reset Terminal State).

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


# Send DECRSTS for Color Table Report
echo -n ${DCS}'2$p'

echo -n "0;2;0;0;0/"		# VT color #0 is black and BG text color

echo -n "1;2;20;20;80/"		# VT color #1 is blue
echo -n "2;2;80;13;13/"		# VT color #2 is red
echo -n "3;2;20;80;20/"		# VT color #3 is green

echo -n "4;2;80;20;80/"		# VT color #4 is magenta
echo -n "5;2;20;80;80/"		# VT color #5 is cyan
echo -n "6;2;80;80;20/"		# VT color #6 is yellow

echo -n "7;2;53;53;53/"	   	# VT color #7 is gray 50% and FG text color
echo -n "8;2;26;26;26/"	   	# VT color #8 is gray 25%

echo -n "9;2;33;33;60/"		# VT color #9 is pastel blue
echo -n "10;2;60;26;26/"	# VT color #10 is pastel red
echo -n "11;2;33;60;33/"	# VT color #11 is pastel green

echo -n "12;2;60;33;60/"	# VT color #12 is pastel magenta
echo -n "13;2;33;60;60/"	# VT color #13 is pastel cyan
echo -n "14;2;60;60;33/"	# VT color #14 is pastel yellow

echo -n "15;2;80;80;80"		# VT color #15 is gray 75% and BOLD text color

echo -n ${ST}			# String Terminator



# NOTES

# DECRSTS is normally used after DECRQTSR (Request Terminal State Report)
# which can save the terminal's current color settings before altering them.

# But that doesn't work in all situations. In particular, if you cat a
# sixel file to your screen, there is no way to reset the colors.
# That's where this script comes in. It simply sets the colors to the
# VT340 factory defaults.

# Note that the docs specifically say that the strings are *not*
# portable across VT300 family members, so this script is useful only
# for the VT340. One would need a database of correct values for
# DECRSTS for each terminal.
#
# Given that fact, I believe, DECRSTS should be added to TERMINFO
# entry for "vt340" so that a soft reset will fix color map problems.

# Open questions:

# * Why are there two different builtin color tables in the VT340
#   Color Set-Up screen?
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
#   DEC documentation does that same.
