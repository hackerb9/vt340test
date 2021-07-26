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

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

large_block() {
  set_cursor_pos ${1} ${2}
  echo ${DCS}'2;1q#1'
  if [[ ${3} == true ]]
  then
    echo '!200~-'
    echo '!200~-'
    echo '!200~-'
    echo '!200~-'
  else
    echo '!20~!160N!20~-'
    echo '!20~!160?!20~-'
    echo '!20~!160?!20~-'
    echo '!20~!160{!20~-'
  fi
  echo ${ST}
}

small_block() {
  set_cursor_pos ${1} ${2}
  echo ${DCS}'2;1q#1'
  echo '!40~-'
  echo '!40B-'
  echo ${ST}
}

error_line() {
  set_cursor_pos ${1} ${2}
  echo ${DCS}'2;1q#2'
  echo '!200N-'
  echo ${ST}
}

test_message() {
  set_cursor_pos ${1} ${2}
  echo -n ${4}
  echo "${3}"
}

test_message 5 33 '  Regular Size  '
test_message 6 17 ' DECDWL ' ${DECDWL}
test_message 7 17 ' DECDHL ' ${DECDHLT}
test_message 8 17 ' DECDHL ' ${DECDHLB}

large_block 4 31 false
small_block 6 14
small_block 6 64

large_block 13 31 true
small_block 15 14
small_block 15 64

test_message 14 33 '  Regular Size  '
test_message 15 17 ' DECDWL ' ${DECDWL}
test_message 16 17 ' DECDHL ' ${DECDHLT}
test_message 17 17 ' DECDHL ' ${DECDHLB}

set_cursor_pos 11 20
echo '||'
error_line 11 31
set_cursor_pos 11 1
echo ${DECDWL}

set_cursor_pos 22 1
