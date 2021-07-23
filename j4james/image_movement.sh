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
echo -n ${CSI}'?7h'
yes E | tr -d '\n' | head -c 1920

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

test_pattern() {
  local row=${1}
  local col=${2}
  local center_line=${3}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q'
  echo '#1!90~#2!30~-'
  echo '#1!60~#2!30~#0!30~-'
  echo -n ${center_line}
  echo '#1!30~#2!30~#0!60~-'
  echo '#2!30~#0!90~'
  echo ${ST}
}

small_test_pattern() {
  local row=${1}
  local col=${2}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q'
  echo '#2!30~#0!30~#3!170o-'
  echo '#2!30~#3!200~'
  echo ${ST}
  set_cursor_pos $((${row} + 1)) 1
  echo '   '${CSI}'40C   '
}

test_pattern 3 49

# Insert 3 lines.
echo -n ${CSI}'6H'
echo ${CSI}'3L'

test_pattern 3 21 '#3!999~-!999~-'

# Delete 3 lines.
echo -n ${CSI}'1;13r'
echo -n ${CSI}'6H'
echo -n ${CSI}'3M'
echo ${CSI}'r'

small_test_pattern 16 38

# Delete 3 characters.
set_cursor_pos 17 41
echo ${CSI}'3P'

# Insert 3 characters.
set_cursor_pos 18 41
echo ${CSI}'3@'

set_cursor_pos 12 1
