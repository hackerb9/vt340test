#!/bin/bash

# Sixel-DECDWL Quirk #2

# A demonstration of a second quirk of the VT340 behaviour:
# sixel images that start indented on a double size line suddenly
# shift left in the middle.
# (See also decdwl-quirk1.sh).

# When a sixel image is received by a VT340, the line attribute flags
# for all lines are set to single width. However that process happens
# asynchronously with the drawing of the image.
#
# This is a problem as the VT340 starts out using the double-width
# text cursor location, indenting the image to the right twice as far
# as it would a single-width line.
#
# If rendering the sixel image takes long enough, the VT340 will shift
# the image left, to the single-width indentation, in the middle of
# drawing it. Which line this happens on is non-deterministic.

# It is not yet clear _why_ the VT340 resets the lines to single-width
# when receiving a Sixel image. It doesn't appear that it was
# necessitated by the hardware as ReGIS graphics have no such quirk.

# Workarounds for Quirk #2.
#
# 1. Send an empty sixel image first: Esc P 9;1 q Esc \
#
#    This is likely a proper barrier, the theory being that the
#    coprocess which sets the lines to single-width can run only one
#    job at a time, causing the second sixel image to have to wait.
#
#    Of course, it may work by simply delaying the timing, but this
#    seems unlikely as it has never been seen to fail.
#
# 2. Use DECSDM (Sixel Display Mode) and position the image absolutely.
#    (Difficult and not recommended). See 'decdwl-quirk1.sh' which uses 
#    this method in order to avoid exercising quirk 2.

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
${DECDWL}     VT340 Sixel & Double Size Text
${DECDWL}                Quirk #2
EOF

# Draw a complex sixel image, indented by ten double-width characters
tput cup 4
echo -n "${DECDWL}LoremIpsum"
echo -n "${Y}"
tput cup 4 40
echo -n "<-- Image starts on a double-width line"


# Now draw it again working around Quirk 2.
tput cup 11
echo -n "${DECDWL}LoremIpsum"
echo -n $'\eP9;1q\e\\'		# An empty sixel image.
echo -n "$Y"
tput cup 11 40
echo -n "<-- With workaround"


tput cup 18 0
cat <<EOF
The VT340 resets all line attributes to single-width when a sixel
image is received. This leads to a quirk where an image indented by
a double-width line suddenly reverts to single-width indentation

EOF
