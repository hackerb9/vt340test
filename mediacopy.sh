
# DO NOT USE YET
# BUGGY. This doesn't work to read all the sixel data.
# I'm just using 'script' and even then it doesn't reproduce correctly.
# Probably should just capture output to the Printer port.


# Testing reading before sending print. Nope, that didn't help.
#( if ! IFS=$'\e' read -a REPLY -s -r -d '\\'; then
#    echo Terminal did not respond.
#    exit 1
#   echo "$REPLY" > print.out
#fi ) &


CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

echo -n ${CSI}'?2i'		# (MC) Send graphics to host, not printer

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in black and white
echo -n ${CSI}'?46h'		# Print in Color

# DECGPBM: Print Graphics Background Mode
echo -n ${CSI}'?46l'		# Do not send background when printing
#echo -n ${CSI}'?46h'		# Include background when printing

echo -n ${DCS}'p'		# Enter REGIS mode
echo -n $'S(H)'			# Send hard copy [Note: redirected to host]
echo -n ${ST}			# Exit REGIS mode


#echo -n ${CSI}'i'		# Print screen (MC, Media Copy)
#if ! IFS=$'\e' read -a REPLY -s -p ${CSI}'i' -r -d '\\'; then

wait

