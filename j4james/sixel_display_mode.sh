#!/bin/bash

# Test of DECSDM (Sixel Display Mode).

# On a genuine VT340,
# when DECSDM is reset,	${CSI}?80l, sixel scrolling is enabled and
# 			images start drawing at the text cursor (default);
# when DECSDM is set, 	${CSI}?80h, sixel scrolling is disabled and
# 			images start drawing at the upper left hand corner.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n $'\e#8'

echo -n ${CSI}'22;57H'
echo -n ${DCS}'2;1q#1'
echo '!120~-'
echo '!120~-'
echo '!120~-'
echo '!120~-'
echo '--'
echo -n ${ST}
echo -n ${CSI}'H'

# Set DECSDM
echo -n ${CSI}'?80h'

echo -n ${CSI}'3;34H'
echo -n ${DCS}'2;1q#2'
echo '--------'
echo '!120?!120~-'
echo '!120?!120~-'
echo '!120?!120~-'
echo '!120?!120~-'
echo '----'
echo -n ${ST}

echo -n ${CSI}'5B'
echo -n ${CSI}'3C DECSDM '

# Reset DECSDM
echo -n ${CSI}'?80l'

echo -n ${CSI}'13;35H'
echo -n ${DCS}'2;1q#3'
echo '!120~-'
echo '!120~-'
echo '!120~-'
echo '!120~-'
echo '-----'
echo -n ${ST}
echo -n ${CSI}22H
