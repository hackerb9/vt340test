#!/bin/bash

# trawlmodes:
# Try DEC Private modes 0 to 255 and see how the terminal responds.
# Outputs a MarkDown table. Based on checksixelmode.


# Allow user to specify range on command line. E.g., trawlmodes.sh {256..1023}
if [[ $# -eq 0 ]]; then
    set - {0..255}
fi


# Ps holds the array of DEC Private Modes
# Sources (most used first):
#	XTerm ctlseqs.pdf (default if not otherwise marked)
# 	VT520/525 Reference Manual		ek-520-rm
# 	VT300 Text Programming	 		ek-vt3xx-tp
#	VK100 Technical Manual			ek-vk100-tm
# 	VT382 (Japanese) Reference Manual	ek-vt382-rm
#	VT382 (Thai) User Guide			ek-vt38t-ug
#	VT100 User Guide 			VT100-UG
#	VT382 (Korean) -- missing! --

Ps=()
Ps[1]="Application Cursor Keys (DECCKM), VT100."
Ps[2]="Designate US ASCII/ANSI for character sets G0-G3 (DECANM), VT100." # From Xterm
Ps[2]="VT52 (ANSI) Mode (DECANM), VT520." 		# From ek-520-rm
	Nt[2]="To leave VT52 mode, use Esc <."
Ps[3]="132 Column Mode (DECCOLM), VT100."
Ps[4]="Smooth (Slow) Scroll (DECSCLM), VT100."
Ps[5]="Reverse Video Screen (DECSCNM), VT100."
	Nt[5]="SET is light bg, RESET is dark bg." 	# From EK-VT38T-UG.
Ps[6]="Origin Mode (DECOM), VT100."
Ps[7]="Auto-Wrap Mode (DECAWM), VT100."
Ps[8]="Auto-Repeat Keys (DECARM), VT100."
Ps[9]="Interlace mode (DECINLM), VT1xx only."   # Documented in VT100-UG
Ps[9]="Send Mouse X & Y on button press, X10 XTerm." # Conflicts with VT100-UG
	Nt[9]="VT100 used mode 9 for interlace, but dropped it in VT200+."
Ps[10]="Show toolbar, rxvt."			# Conflicts with ek-vt3xx-tp.
Ps[10]="Edit Mode (DECEDM)." 			# As documented by ek-vt3xx-tp.
Ps[11]="Line Transmit Mode (DECLTM)."	 	# Added from ek-vt3xx-tp.
Ps[12]="Start blinking cursor (AT&T 610)."	# Conflicts with ek-vt382-rm.
Ps[12]="Katakana Shift Mode (DECKANAM), VT382-J" # Documented in ek-vt382-rm.
Ps[13]="Start blinking cursor, xterm." 		# Conflicts with ek-vt3xx-tp.
Ps[13]="Space compression field delimiter (DECSCFDM)" # As documented by ek-vt3xx-tp.
Ps[14]="XOR of blinking cursor control sequence and menu." # Conflicts with ek-vt3xx-tp.
Ps[14]="Transmit execution (DECTEM)."	# As documented by ek-vt3xx-tp.

Ps[16]="Edit key execution (DECEKEM)."	# Added from ek-vt3xx-tp.

Ps[18]="Print Form Feed (DECPFF), VT220."
Ps[19]="Set printer extent to full screen (DECPEX), VT220."
Ps[20]="Overstrike Mode (OS), VK100" 		# Documented in ek-vk100-tm-001
Ps[21]="Local BASIC Mode (BA), VK100" 		# Documented in ek-vk100-tm-001
Ps[22]="Host BASIC Mode (BA), VK100" 		# Documented in ek-vk100-tm-001
Ps[23]="Programmed Keypad Mode (PK), VK100" 	# Documented in ek-vk100-tm-001
Ps[24]="Auto Hardcopy Mode (AH), VK100"		# Documented in ek-vk100-tm-001
Ps[25]="Text cursor enable (DECTCEM), VT220."

Ps[30]="Show scrollbar, rxvt."

Ps[34]="Cursor direction, right to left." 	# Added from ek-520-rm
Ps[35]="Tektronix mode (DECTEK), incorrect."	# As erroneously documented by ek-vt3xx-tp.
	Nt[35]="ek-vt3xx-tp is in error. DECTEK is actually 38."
Ps[35]="Font-shifting functions, rxvt."	# As documented by Xterm
Ps[35]="Hebrew keyboard mapping."	 	# Added from ek-520-rm
Ps[36]="Hebrew encoding mode."			# Added from ek-520-rm

Ps[38]="Tektronix mode (DECTEK), VT240, xterm."	# As documented by Xterm

Ps[40]="Allow 80/132 mode, xterm."
Ps[41]="more(1) fix."
Ps[42]="National Replacement Character sets (DECNRCM), VT220."
	Nt[42]="On the VT340 and perhaps other terminals, DECNRCM is PERMANENTLY RESET when the Keyboard Dialect selected in the Set Up menu is 'North American'."
Ps[43]="Graphics Expanded Print Mode (DECGEPM)."
Ps[44]="Margin bell, xterm."			# Conflicts with ek-vt3xx-tp.
Ps[44]="Graphics Print Color (DECGPCM)"		# As documented by ek-vt3xx-tp
Ps[45]="Reverse-wraparound mode, xterm."	# Conflicts with ek-vt3xx-tp.
Ps[45]="Graphics Print Color Space (DECGPCS)."	# As documented by Xterm.
Ps[45]="Graphics Print Color Syntax (DECGPCS)."	# As documented by ek-vt3xx-tp.
Ps[46]="Start logging, xterm."			# Conflicts with ek-vt3xx-tp.
Ps[46]="Graphics Print Background (DECGPBM)."	# As documented by ek-vt3xx-tp.
Ps[47]="Use Alternate Screen Buffer, xterm."	# Conflicts with ek-vt3xx-tp.
Ps[47]="Graphics Rotated Print Mode (DECGRPM)."	# As documented by ek-vt3xx-tp.

Ps[49]="Thai Keyboard Input Mode (DECTHAIM), VT382-T" 	# Added from ek-vt38t-ug
Ps[50]="Thai Cursor Mode (DECTHAICM), VT382-T" 	# Added from ek-vt38t-ug
	Nt[50]="SET is internal cursor, RESET is physical cursor"

Ps[53]="VT131 transmit (DEC131TM)."		# Added from ek-vt3xx-tp.

Ps[57]="North American / Greek keyboard mapping (DECNAKB)" 	# Added from ek-520-rm
Ps[58]="IBM ProPrinter Emulation (DECIPEM)" 	# Added from ek-520-rm
	Nt[58]="Interpret subsequent data according to the IBM ProPrinter protocol syntax instead of the DEC protocol."
Ps[59]="Kanji/Katakana Display Mode (DECKKDM), VT382-J"	# Documented in ek-vt382-rm.
Ps[60]="Horizontal cursor coupling (DECHCCM)."	# Added from ek-vt3xx-tp.
Ps[61]="Vertical cursor coupling (DECVCCM)."	# Added from ek-vt3xx-tp.

Ps[64]="Page cursor coupling (DECPCCM)."	# Added from ek-vt3xx-tp.

Ps[66]="Application/Numeric keypad mode (DECNKM), VT320"
Ps[67]="Backarrow key sends backspace (DECBKM), VT340, VT420, VT520."
	Nt[67]="When RESET (the default), backarrow key sends delete."
Ps[68]="Keyboard Usage: Data Processing or Typewriter Keys (DECKBUM)." # Added from ek-vt3xx-tp.
	Nt[68]="Data Processing characters are printed on the right half of the keycaps. According to ek-520-rm, 'If you use the North American language, then DECKBUM should always be RESET (typewriter). For all other languages, you can use either mode.'"
Ps[69]="Left and right margin mode (DECLRMM), VT420 and up." # Allows DECSLRM to set margins
Ps[69]="Vertical split screen / Left and right margin mode (DECVSSM/DECLRMM), VT420 and up." 	# Added from ek-520-rm. (Yes, it gives two different mnemonics!)

Ps[73]="Transmit rate limiting (DECXRLM)."	# Added from ek-vt3xx-tp.

Ps[80]="Sixel Display Mode (DECSDM)."
Ps[81]="Keyboard sends key position reports instead of character codes (DECKPM)." 	# Added from ek-520-rm
Ps[90]="Thai Space Compensating Mode (DECTHAISCM), VT382-T" # Added from ek-vt38t-ug

Ps[95]="Do not clear screen when DECCOLM is set/reset (DECNCSM), VT510 and up."
Ps[96]="Perform a copy/paste from right-to-left (DECRLCM), VT520" 	# Added from ek-520-rm
	Nt[96]="Only valid with Hebrew keyboard language, see DEC mode 35"
Ps[97]="CRT Save Mode (DECCRTSM), VT520" 	# Added from ek-520-rm
Ps[98]="Auto-resize the number of lines-per-page when the page arrangement changes (DECARSM), VT520" 	# Added from ek-520-rm
Ps[99]="Modem Control Mode: require DSR or CTS before communicating (DECMCM), VT520" 	# Added from ek-520-rm
Ps[100]="Send automatic answerback message 500ms after a communication line connection is made (DECAAM), VT520" 	# Added from ek-520-rm
Ps[101]="Conceal Answerback Message (DECCANSM), VT520" 	# Added from ek-520-rm
Ps[102]="Discard NUL characters upon receipt, or pass them on to the printer (DECNULM)" 	# Added from ek-520-rm
Ps[103]="Half-Duplex Mode (DECHDPXM), VT520" 	# Added from ek-520-rm
Ps[104]="Enable Secondary Keyboard Language (DECESKM), VT520" 	# Added from ek-520-rm

Ps[106]="Overscan mode for monochrome VT520 terminal (DECOSCNM)" 	# Added from ek-520-rm

Ps[108]="Num Lock Mode of keyboard (DECNUMLK)"		# Added from ek-520-rm
Ps[109]="Caps Lock Mode of keyboard (DECCAPSLK)" 	# Added from ek-520-rm
Ps[110]="Keyboard LED's Host Indicator Mode (DECKLHIM)"	# Added from ek-520-rm
Ps[111]="Framed Windows with title bars, borders, and icons (DECFWM), VT520" 	# Added from ek-520-rm
Ps[112]="Allow user to Review Previous Lines that have scrolled off the top (DECRPL)" 	# Added from ek-520-rm
Ps[113]="Host Wake-up Mode, CRT and Energy Saver (DECHWUM), VT520" 	# Added from ek-520-rm
Ps[114]="Use an alternate text color for underlined text (DECATCUM), VT520" 	# Added from ek-520-rm
Ps[115]="Use an alternate text color for blinking text (DECATCMB), VT520" 	# Added from ek-520-rm
Ps[116]="Bold and blink styles affect background as well as foreground (DECBSM), VT520" 	# Added from ek-520-rm
Ps[117]="Erase Color is screen background (VT) or text background (PC) (DECECM), VT520" 	# Added from ek-520-rm
	Nt[117]="Background color used when text is erased or new text is scrolled on to the screen"

Ps[1000]="Send Mouse X & Y on button press and release. (X11 XTerm mouse)."
Ps[1001]="Use Hilite Mouse Tracking, xterm."
Ps[1002]="Use Cell Motion Mouse Tracking, xterm."
Ps[1003]="Use All Motion Mouse Tracking, xterm."
Ps[1004]="Send FocusIn/FocusOut events, xterm."
Ps[1005]="UTF-8 Mouse Mode, xterm."
Ps[1006]="SGR Mouse Mode, xterm."
Ps[1007]="Alternate Scroll Mode, xterm."

Ps[1010]="Scroll to bottom on tty output, rxvt."
Ps[1011]="Scroll to bottom on key press, rxvt."
Ps[1015]="Urxvt Mouse Mode, rxvt."
Ps[1016]="SGR Mouse PixelMode, xterm."
Ps[1021]="High intensity bold/blink color, rxvt." 	# From VTE modes.py
Ps[1034]="Interpret 'Meta' key, xterm."
	Nt[1034]="This sets the eighth bit of keyboard input."
Ps[1035]="Enable special modifiers for Alt and NumLock keys, xterm."
Ps[1036]="Send ESC when Meta modifies a key, xterm."
Ps[1037]="Send DEL from the editing-keypad Delete key, xterm."
Ps[1039]="Send ESC when Alt modifies a key, xterm."
Ps[1040]="Keep selection even if not highlighted, xterm."
Ps[1041]="Use the CLIPBOARD selection, xterm."
Ps[1042]="Enable Urgency windowmanager hint when Control-G received, xterm."
Ps[1043]="Enable raising of the window when Control-G is received, xterm."
Ps[1044]="Reuse the most recent data copied to CLIPBOARD, xterm"
Ps[1046]="Enable switching to/from Alternate Screen Buffer, xterm."
Ps[1047]="Use Alternate Screen Buffer, xterm."
Ps[1048]="Save cursor as in DECSC, xterm."
Ps[1049]="Save cursor as in DECSC, switch to the Alternate Screen Buffer."
Ps[1050]="Set terminfo/termcap function-key mode, xterm."
Ps[1051]="Set Sun function-key mode, xterm."
Ps[1052]="Set HP function-key mode, xterm."
Ps[1053]="Set SCO function-key mode, xterm."
Ps[1060]="Set legacy keyboard emulation, i.e, X11R6, xterm."
Ps[1061]="Set VT220 keyboard emulation, xterm."
Ps[1070]="Use private color registers for each graphic, xterm."
	Nt[1070]="When SET, each Sixel/ReGIS graphic gets a fresh palette. When RESET, colormap changes persist just like on a true VT340. SET is the default for XTerm."
Ps[2004]="Set bracketed paste mode, xterm."
Ps[2026]="Synchronized output. iTerm2, Contour, Kitty." # From https://gist.github.com/christianparpart/d8a62cc1ab659194337d73e399004036
	Nt[2026]="When SET, new data is not displayed until the mode is RESET. Can be used by applications for double-buffering & page flipping to prevent screen tearing."
Ps[8452]="Sixel leaves cursor right of image, RLogin, xterm."

status=("not recognized" "set" "reset" "permanently set" "permanently reset")

echo "Mode | VT340 Response | Description | Notes"
echo "-----|----------------|-------------|------"

for mode; do
    if ! IFS=";$" read -a REPLY -t 0.25 -s -p $'\e[?'$mode'$p' -d y; then
	echo "Terminal did not respond to mode $mode." >&2
    else
	if [[ ${REPLY[1]} == 0 ]]; then continue; fi 	# Skip "Not recognized"
	echo -n "$mode | "
	echo -n "${status[${REPLY[1]}]}"
	echo "| ${Ps[$mode]} | ${Nt[$mode]}"
    fi
done



