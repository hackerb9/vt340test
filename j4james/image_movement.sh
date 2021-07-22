#!/bin/bash

# Test of the effect of insert and delete operations on a Sixel image.

# On a genuine VT340, an IL (insert line) operation in the middle of an image
# will cause the lower part of the image to be shifted down in the same way
# that text is affected. Similarly, a DL (delete line) operation will erase
# part of the image, and shift the remaining segments upward.

# The character editing operations do not work in the same way though. If
# an ICH (insert character) or DCH (delete character) is executed on a line
# covered by a Sixel image, that entire section of the image is erased.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo $'\e#8'

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

test_pattern() {
  local row=${1}
  local col=${2}
  local center_line=${3}
  local upper_prefix=${4}
  local lower_prefix=${5}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q'
  echo ${upper_prefix}'#1!90~#2!30~-'
  echo ${upper_prefix}'#1!60~#2!30~#0!30~-'
  echo -n ${center_line}
  echo ${lower_prefix}'#1!30~#2!30~#0!60~-'
  echo ${lower_prefix}'#2!30~#0!90~'
  echo ${ST}
}

test_pattern 3 26

# Insert 3 lines.
echo -n ${CSI}'6H'
echo ${CSI}'3L'

test_pattern 3 8 '#3!999~-!999~-'

# Delete 3 lines.
echo -n ${CSI}'1;13r'
echo -n ${CSI}'6H'
echo -n ${CSI}'3M'
echo ${CSI}'r'

test_pattern 3 44 '' '' '!30?'

# Delete 3 characters over 3 lines.
echo ${CSI}'6;44H'${CSI}'3P'
echo ${CSI}'7;44H'${CSI}'3P'
echo ${CSI}'8;44H'${CSI}'3P'

test_pattern 3 59 '' '!30?'

# Insert 3 characters over 3 lines.
echo ${CSI}'6;59H'${CSI}'3@EEE'
echo ${CSI}'7;59H'${CSI}'3@EEE'
echo ${CSI}'8;59H'${CSI}'3@EEE'

set_cursor_pos 12 1
