#!/bin/bash

# Test of DECSDM (Sixel Display Mode).

# On a genuine VT340,
# when DECSDM is reset,	${CSI}?80l, sixel scrolling is enabled and
# 			images start drawing at the text cursor (default);
# when DECSDM is set, 	${CSI}?80h, sixel scrolling is disabled and
# 			images start drawing at the upper left hand corner.

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator


echo -n ${CSI}'H'
echo -n ${CSI}'J'
echo -n ${CSI}'?7h'
yes E | tr -d '\n' | head -c 1920

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

cursor_home() {
  echo ${CSI}'H'
}

cursor_down() {
  echo -n ${CSI}${1}'B'
}

cursor_right() {
  echo -n ${CSI}${1}'C'
}

test_pattern() {
  local row=${1}
  local col=${2}
  local color=${3}
  local suffix=${4}
  local prefix=${5}
  local padding=${6}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q'${color}
  echo ${prefix}
  echo ${padding}'!120~-'
  echo ${padding}'!120~-'
  echo ${padding}'!120~-'
  echo ${padding}'!120~-'
  echo ${suffix}
  echo -n ${ST}
}

test_pattern 22 57 '#1' '--'
echo -e '\n'
cursor_home

# Set DECSDM
echo ${CSI}'?80h'

test_pattern 3 34 '#2' '----' '--------' '!120?'
cursor_down 6
cursor_right 3
echo ' DECSDM '

# Reset DECSDM
echo ${CSI}'?80l'

test_pattern 13 35 '#3' '-----'
set_cursor_pos 22 1
