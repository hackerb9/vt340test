#!/bin/bash
#
# Use REGIS to draw some graphics on the VT340 screen

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

clear

echo -n ${DCS}'3p'		# Enter interactive REGIS mode
#echo -n $'S(M(
echo -n $'P[400,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]' # RAF roundels
echo -n ${ST}			# Exit REGIS mode


