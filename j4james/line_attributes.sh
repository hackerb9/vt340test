#!/bin/bash

# Test of line attribute interactions with a Sixel image.

# Placing an image on top of a double width/height line has no effect on the
# dimensions of the image. It renders just as it would on a single width line.
# Changing a line from single width to double width, after an image has been
# output, will erase the image content on that line along with any text.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

DECDHLT=$'\e#3'			# Double Height Line (top)
DECDHLB=$'\e#4'			# Double Height Line (bottom)
DECDWL=$'\e#6'			# Double Width Line


echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n ${CSI}'?7h'

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

large_block() {
  set_cursor_pos ${1} ${2}
  echo ${DCS}';1q"20;1#1'
  if [[ ${3} == true ]]
  then
    echo '!200^'
  else
    echo '!20^!160P!20^'
  fi
  echo ${ST}
}

small_blocks() {
  set_cursor_pos ${1} ${2}
  echo ${DCS}';1q"10;1#1'
  echo '!40]!520?!40]'
  echo ${ST}
}

test_message() {
  set_cursor_pos ${1} ${2}
  echo -n ${4}
  echo "${3}"
}

# Output some double-size text.
test_message 6 17 ' DECDWL ' ${DECDWL}
test_message 7 17 ' DECDHL ' ${DECDHLT}
test_message 8 17 ' DECDHL ' ${DECDHLB}

# Render some images on top of that text.
large_block 5 31 false
small_blocks 6 11

# Render another set of images.
large_block 16 31 true
small_blocks 17 11

# Output some double-size text on top of those images.
test_message 17 17 ' DECDWL ' ${DECDWL}
test_message 18 17 ' DECDHL ' ${DECDHLT}
test_message 19 17 ' DECDHL ' ${DECDHLB}

# Output a double-height sequence of text.
set_cursor_pos 12 1
echo ${DECDHLT}
echo ${DECDHLB}
set_cursor_pos 12 1
yes '+' | tr -d '\n' | head -c 80
test_message 12 17 ' DOUBLE '
test_message 13 17 ' DOUBLE '

# Render an image to try and reset the line attributes.
set_cursor_pos 12 1
echo ${DCS}';1q?'${ST}

# Output additional text on those lines.
test_message 12 9 ' SINGLE '
test_message 13 9 ' SINGLE '
test_message 12 100 ' SINGLE ' ${CSI}'15D'
test_message 13 100 ' SINGLE ' ${CSI}'15D'

set_cursor_pos 1 1
