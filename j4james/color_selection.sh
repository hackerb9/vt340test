#!/bin/bash

# Test of the Sixel image color table.

# On a genuine VT340, the order in which the color table is updated, is
# independent of the color numbers assigned in a Sixel image. The first color
# defined will replace color table entry 1 rather than 0, the second will
# replace color table entry 2, etc. up to the fifteenth color. The sixteenth
# color defined will replace color table entry 0.

# The color table is global, and shared between images and text, so changes
# to the colors in a Sixel image will affect existing images on screen as
# well as the representation of text attributes. Color table entry 0 is the
# background color, color 7 is used for regular text, and 15 for bold text.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n ${CSI}'?7h'

# Fill screen with an identifiable background that is sixel compressible
LINES=$(tput lines); COLUMNS=$(tput cols)
yes . | tr -d '\n' | head -c $((LINES*COLUMNS))

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

output_text_attributes() {
  set_cursor_pos ${1} 23
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

output_color_pattern_1() {
  echo '!80~ #11!80~ #3!80~ #14!80~ #6!80~ #12!80~ #4!80~ #7!80~ #15!80~-'
  echo '!80? #13!80~ #5!80~ #9!80~ #1!80~ #10!80~ #2!80~ #8!80~ #0!80~-'
}

output_color_pattern_2() {
  echo '#0!80~ #1!80~ #2!80~ #3!80~ #4!80~ #5!80~ #6!80~ #7!80~ #0!80~-'
  echo '#8!80~ #9!80~ #10!80~ #11!80~ #12!80~ #13!80~ #14!80~ #15!80~ #8!80~-'
}

update_color_table() {
  echo '#12;1;206;50;100'
  echo '#14;1;309;50;100'
  echo '#2;1;103;35;100'
  echo '#6;1;309;35;100'
  echo '#10;1;103;50;100'
  echo '#4;2;40;70;0'
  echo '#7;1;360;35;100'
  echo '#15;1;0;50;100'
  echo '#11;2;100;58;0'
  echo '#13;2;0;100;30'
  echo '#1;1;52;35;100'
  echo '#5;2;0;70;21'
  echo '#9;2;86;0;100'
  echo '#3;2;70;41;0'
  echo '#0;2;0;0;0'
  echo '#8;2;100;100;100'
}

# Output a Sixel test pattern using the default colors.
set_cursor_pos 3 5
echo ${DCS}'2q"5;1;720;60'
output_color_pattern_1
echo ${ST}

# Output text attributes using the default colors.
output_text_attributes 17

# Output two Sixel test patterns, updating the color table inbetween.
set_cursor_pos 6 5
echo ${DCS}'2q"5;1;720;120'
output_color_pattern_1
update_color_table
output_color_pattern_2
echo ${ST}

# Output a Sixel test pattern inheriting the updated color table.
set_cursor_pos 12 5
echo ${DCS}'2q"5;1;720;60'
output_color_pattern_1
echo ${ST}

# Output text attributes using the updated color table.
output_text_attributes 18

echo
