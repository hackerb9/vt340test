#!/bin/bash

# Test of line attribute interactions with a Sixel image.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

DECDHLT=$'\e#3'			# Double Height Line (top)
DECDHLB=$'\e#4'			# Double Height Line (bottom)
DECDWL=$'\e#6'			# Double Width Line


echo -n ${CSI}'!p'
echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo $'\e#8'

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

test_pattern() {
  local row=${1}

  set_cursor_pos ${row} 3
  echo ${DCS}'2;1q'
  echo '#1!120~-'
  echo '#1!120~-'
  echo '#1!120~-'
  echo '#1!120~'
  echo ${ST}

  set_cursor_pos $((${row} + 2)) 19
  echo ${DCS}'2;1q'
  echo '#1!40~-'
  echo '#1!40F-'
  echo ${ST}
}

test_message() {
  set_cursor_pos ${1} ${2}
  echo -n ${4}
  echo "${3}"
}

test_message 3 33 ' DECDWL ' ${DECDWL}
test_message 4 33 ' DECDWL ' ${DECDWL}
test_message 5 33 ' DECDHL ' ${DECDHLT}
test_message 6 33 ' DECDHL ' ${DECDHLB}

test_pattern 2

test_message 3 4 'DW'
test_message 4 4 'DW'
test_message 5 4 'DH'
test_message 6 4 'DH'

test_message 10 33 ' DECDWL '
test_message 11 33 ' DECDWL '
test_message 12 33 ' DECDHL '
test_message 13 33 ' DECDHL '

test_pattern 9

test_message 10 4 'DW' ${DECDWL}
test_message 11 4 'DW' ${DECDWL}
test_message 12 4 'DH' ${DECDHLT}
test_message 13 4 'DH' ${DECDHLB}

set_cursor_pos 23 1
