#!/bin/bash
#
# Use REGIS to draw some graphics on the VT340 screen and then use the
# MC (Media Copy) command to read the graphics back as Sixel data.

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

clear

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in black and white
echo -n ${CSI}'?46h'		# Print in Color

# DECGPBM: Print Graphics Background Mode
echo -n ${CSI}'?46l'		# Do not send background when printing
#echo -n ${CSI}'?46h'		# Include background when printing

echo -n ${DCS}'3p'		# Enter interactive REGIS mode
echo -n $'P[400,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]' # RAF roundels
echo -n ${ST}			# Exit REGIS mode


