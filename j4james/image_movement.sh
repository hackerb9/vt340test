#!/bin/bash

# Test of the effect of insert and delete operations on a Sixel image.

# On a genuine VT340, an IL (insert line) operation in the middle of an image
# will cause the lower part of the image to be shifted down in the same way
# that text is affected. Similarly, a DL (delete line) operation will erase
# part of the image, and shift the remaining segments upward.

# The character editing operations do not work in the same way though. If
# an ICH (insert character) or DCH (delete character) is executed on a line
# covered by a Sixel image, that entire section of the line is erased.

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
  local color=${3}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q#'${color}
  echo '!60~-'
  echo '!60~'
  echo ${ST}
}

clear_edges() {
  local row=${1}
  local col=${2}

  set_cursor_pos ${row} ${col}
  echo -n ${CSI}'1K'
  echo -n ${CSI}'13C'
  echo ${CSI}'K'
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

# Setup images and text to be moved.
clear_edges 18 37
small_test_pattern 18 38 1
clear_edges 20 31
small_test_pattern 18 21 2

# Delete 3 characters.
set_cursor_pos 18 32
echo ${CSI}'3P'

# Insert 3 characters.
set_cursor_pos 20 32
echo ${CSI}'3@'

# Followup image for balance.
small_test_pattern 18 55 2

set_cursor_pos 12 1
