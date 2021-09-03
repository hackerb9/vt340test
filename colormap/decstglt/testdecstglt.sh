#!/bin/bash

# DECSTGLT
# Changes Global Set-Up -> Color Look-up Table to 
# (0) Monochrome, (1) Colormap 1, or (2) ColorMap 2.

# *Does* reset the colors in colormap 1 or 2 if I first switch monochrome.

# Does not reset to my saved colors, but to the factory defaults.
# Does not reset to look up table chosen in Global Set-up.

# Note that the weird behaviour related to colormap 2 where the
# background highlight color is darker than in colormap 1, is a
# feature not a bug. In color map 2, the reverse background color is
# color index number #8, not #7 and the bright reverse background
# color is #7, not #15. @j4james hypothesizes these darker background
# color choices were visible on both color displays and monochrome
# monitors, where a large section of bright phosphor was apt to bleed
# into the thin black pixels of black text.

# Also, there is a mysterious bug in the VT340: a rectangle of old
# text will sometimes appear on the screen when switching between
# color tables. This seems to occur more after I've run this script
# for some reason.

# And finally, for text on the screen that already has the reversed
# attribute, changing the color map betwen 1 and 2 more than once can
# be confusing. The VT340 remembers that old text has the "previous"
# color map applied, but it only remembers one previous map.
#
# For example, the following shows several lines with colormap 2
# followed by one line of colormap 1:
#
#   for m in 1 2 1 2 1 2 1 2 1; do
#     echo -n $'\e['${m}'){';
#     echo -n $'\e[7m' Reverse $'\e[m'; 
#     echo $'\e[7;1m' Bright Reverse $'\e[m'
#   done


CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

output_color_pattern() {
  echo ${DCS}'2;1q'
  echo '#0!40~ #1!40~ #2!40~ #3!40~ #4!40~ #5!40~ #6!40~ #7!40~-'
  echo '#8!40~ #9!40~ #10!40~ #11!40~ #12!40~ #13!40~ #14!40~ #15!40~-'
  echo ${ST}
}

output_color_numbers() {
  for ((n=0; n<8; n++)); do
      echo -n $n
      tput cuf 3 		# Forward three spaces
  done
  tput cub 32			# Back 4*8 spaces
  tput cud 2			# Down
  for ((n=8; n<10; n++)); do
      echo -n $n
      tput cuf 3
  done
  for ((n=10; n<16; n++)); do
      echo -n $n
      tput cuf 2
  done
}

output_text_attributes() {
  echo -n ${CSI}'m'
  echo -n ' Normal '
  echo -n ${CSI}'1m'
  echo -n ' Bright '
  echo -n ${CSI}'0;7m'
  echo -n ' Reverse '
  echo -n ${CSI}'1m'
  echo -n ' B.Reverse '
  echo -n ${CSI}'m'
  echo
}

test_lookup_table() {
  #  echo -n ${CSI}'2J'	# Clear screen
  # Home cursor, but don't clear as we want to show the weird text glitch.
  echo -n ${CSI}'H'		

  echo -n ${CSI}${1}'){'  # DECSTGLT

  set_cursor_pos 3 34
  echo -n "${2}"
  
  set_cursor_pos 6 25
  output_color_pattern
  set_cursor_pos 6 25
  output_color_numbers

  set_cursor_pos 11 23
  output_text_attributes

  set_cursor_pos 14 1

  if [[ ! "${do_snapshot}" ]]; then
      read -sn 1
  fi
}

snapshot () {
  if [[ ${do_snapshot} ]]; then
      ../mediacopy/mediacopy.sh
      convert print.six decstglt${1}.png
      rm print.six
  fi
}  


# Main

if [[ "${1}" == "-s" ]]; then do_snapshot=yes; fi

echo -n ${CSI}'2J'	# Clear screen
test_lookup_table 0 '  Monochrome  '
snapshot 0
test_lookup_table 1 'Color Table #1'
snapshot 1
test_lookup_table 2 'Color Table #2'
snapshot 2

# Reset to color table #1.  *TRIGGERS GLITCH ON SCREEN*
echo -n ${CSI}'0){'${CSI}'1){'	# DECSTGLT
