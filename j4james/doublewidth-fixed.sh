#!/bin/bash

ESC=$'\e'	# Escape
CSI=$'\e['	# Control Sequence Introducer 
DCS=$'\eP'	# Device Control String
ST=$'\e\\'	# String Terminator
BS=$'\b'	# Backspace
LS0=$'\017'	# Locking Shift 0
LS1=$'\016'	# Locking Shift 1

echo -n ${CSI}'?25l'  # Hide cursor

echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n ${CSI}'H'
echo -n ${CSI}'5;22H'
echo -n ${ESC}'#6'
echo -n ${ESC}'7What letter does'
echo -n ${ESC}'8'
echo -n ${ESC}'D'
echo -n ${ESC}'#6this represent?'
echo -n ${CSI}'8;26H'
echo -n ${ESC}'7'
echo -n ${ESC}'#3'
echo -n ${CSI}'4mQ'
echo -n ${CSI}'muebec'
echo -n ${ESC}'8'
echo -n ${ESC}'D'
echo -n ${ESC}'#4'
echo -n ${CSI}'4mQ'
echo -n ${CSI}'muebec'
echo -n ${CSI}'11;26H'
echo -n ${ESC}'7'
echo -n ${ESC}'#3'
echo -n ${CSI}'4mE'
echo -n ${CSI}'mcho'
echo -n ${ESC}'8'
echo -n ${ESC}'D'
echo -n ${ESC}'#4'
echo -n ${CSI}'4mE'
echo -n ${CSI}'mcho'
echo -n ${CSI}'14;26H'
echo -n ${ESC}'7'
echo -n ${ESC}'#3'
echo -n ${CSI}'4mK'
echo -n ${CSI}'milo'
echo -n ${ESC}'8'
echo -n ${ESC}'D'
echo -n ${ESC}'#4'
echo -n ${CSI}'4mK'
echo -n ${CSI}'milo'
echo -n ${CSI}'17;26H'
echo -n ${ESC}'7'
echo -n ${ESC}'#3'
echo -n ${CSI}'4mY'
echo -n ${CSI}'mankee'
echo -n ${ESC}'8'
echo -n ${ESC}'D'
echo -n ${ESC}'#4'
echo -n ${CSI}'4mY'
echo -n ${CSI}'mankee'

# The following empty sixel image resets the all lines to single-width columns
echo -n ${DCS}';1q'${ST}

# Note that instead of indenting by 4 double-spaced columns, we now
# use 8 single-spaced columns.
echo -n ${CSI}'5;9H'

echo -n ${DCS}'9;1q"50;1#2!300~$"1;1#6!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-
!49~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!43~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!37~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!31~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!25~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!19~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!13~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!7~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}-!49?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!6~-!43?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!12~-!37?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!18~-!31?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!24~-!25?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!30~-!19?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!36~-!13?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!42~-!7?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!48~-?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!54~-!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!49~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!43~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!37~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!31~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!25~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!19~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!13~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!7~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}-!49?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!6~-!43?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!12~-!37?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!18~-!31?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!24~-!25?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!30~-!19?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!36~-!13?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!42~-!7?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!48~-?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!54~-!55~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!49~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!43~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!37~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!31~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!25~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!19~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!13~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-!7~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@-~^NFB@!55?_ow{}!55~^NFB@!55?_ow{}!55~^NFB@'${ST}

read -s -n 1  # Wait for keypress

echo -n ${CSI}'?25h'  # Restore cursor
echo
