CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

clear
echo -n ${CSI}'?2i'		# (MC) Send graphics to host, not printer

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in black and white
echo -n ${CSI}'?46h'		# Print in Color

# DECGPBM: Print Graphics Background Mode
echo -n ${CSI}'?46l'		# Do not send background when printing
#echo -n ${CSI}'?46h'		# Include background when printing



echo -n ${DCS}'3p'		# Enter interactive REGIS mode
echo -n $'P[150,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]' # RAF roundels
echo -n $'S(H)'			# Send hard copy [Note: redirected to host]
echo -n ${ST}			# Exit REGIS mode


#echo -n ${CSI}'?2i'		# Send graphics to host, not printer
#echo -n ${CSI}'i'		# Print screen (MC, Media Copy)

if ! IFS=$'\e' read -a REPLY -s -p ${CSI}'i' -r -d '\\'; then
    echo Terminal did not respond.
#    exit 1
fi

showargs "${REPLY[@]}" | cat -v | tee print.out

