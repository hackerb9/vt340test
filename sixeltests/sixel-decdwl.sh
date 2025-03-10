#!/bin/bash

# A test of the interaction of sixel graphics upon line attributes.
# (DECDWL - Double Width Line, DECDHL - Double Height Lines).

# Although only DECDWL is shown, the effect for DECDHL is the same.

#  DECDWL - Double Width Line - Esc # 6
#  DECDHL - Double Height Lines - Esc # 3 and Esc # 4
#  DECSWL - Single Width Line - Esc # 5

# When a sixel image is received by a VT340, the line attribute flags
# for all lines are set to single width and the entire backing text
# buffer is cleared. However, the bitmap of any existing text is not
# erased from the screen.

# This makes it problematic to integrate double-size text and sixel
# graphics. ReGIS is much more amenable (see regis-decdwl.sh).


# This tests all orderings of Line Attributes, Text, and Graphics.
#
# The most natural ordering is to set the attributes immediately
# before the text, with the graphics coming before or after:
# 1. ATG
# 2. GAT
# Less natural would be to set the attributes immediately after the text:
# 3. TAG
# 4. GTA
# Most peculiar would be to draw graphics between the attributes and text:
# 5. AGT
# 6. TGA



# Define a sixel image to draw a 120x120 flag
Y='P//~
TITLE=Yankee
\P//~
COMMENT=The letter Y represented using the International Code of Signals.
\P//~
CREATOR=James Holderness
\P//~
URL=https://github.com/j4james/vtinterco/
\P9;1q"20;1#2!120~$"1;1#6!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}-!13?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!6~-!7?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!12~-?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!18~-!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}-!13?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!6~-!7?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!12~-?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!18~-!19~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!13~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-!7~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@-~^NFB@!19?_ow{}!19~^NFB@!19?_ow{}!19~^NFB@\'

DECDWL=$'\e#6'

clear
tput cup 1
cat <<EOF
	      The effect of ordering upon sixel graphics
	       with line attributes (double-size text)
EOF

tput cup 5 10
echo ${DECDWL}"1. Attributes, Text, Graphics"

tput cup 7 10
echo "3. Text, Attributes, Graphics"${DECDWL}

tput cup 9			# Line 5. AGT
echo ${DECDWL}

tput cup 10 10
echo "6. Text, Graphics, Attributes"


sleep .5

# Draw the flag using macro starting at line 6
echo $'\ePq\e\\'
tput cup 5 5
echo -n "$Y"

sleep .5

tput cup 6 10
echo ${DECDWL}"2. Graphics, Attributes, Text"

tput cup 8 10
echo "4. Graphics, Text, Attributes"${DECDWL}

tput cup 9 10
echo "5. Attributes, Graphics, Text"

tput cup 10			# Line 6. TGA
echo ${DECDWL}

tput cup 12 0
cat <<EOF
The VT340 resets all line attributes to single-width and clears the
underlying text buffer when a sixel image is received. Existing text
is retained only in the bitmap buffer and cannot be edited.

Lines 2 and 4 of the graphic are erased when the attributes are set.
Line 6 loses text & graphics, since its order is Text, Graphics, Attributes.
Line 5 has the text printed on top of the image because the double-
width attribute that makes columns twice as wide was reset.

EOF
