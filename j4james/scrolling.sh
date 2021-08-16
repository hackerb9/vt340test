#!/bin/bash

# Test of the boundary points at which a Sixel image triggers scrolling.

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

set_margin() {
  echo ${CSI}${1}';'${2}'r'
}

reset_margin() {
  echo -n ${CSI}'r'
}

test_case() {
  local row=${1}
  local col=${2}
  local height=${3}
  local end_with_lf=${4}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'1;1q'
  echo -n '#1'
  
  for i in $(seq ${height})
  do
    echo -n '!60~'
    if [[ ${i} -lt ${height} || ${end_with_lf} = true ]]; then echo -n '-'; fi
  done

  echo
  echo -n ${ST}

  set_cursor_pos ${marker_line} $((${col}+2))
  echo '--'
  marker_line=$((${marker_line}-1))
}

marker_line=21

test_case  24  8 2 true
test_case  24 20 3 false
test_case  23 32 3 true
test_case  23 44 4 false
test_case  22 56 4 true
test_case  22 68 5 false

marker_line=9

set_margin  1 12
test_case  12  8 2 true
test_case  12 20 3 false
test_case  11 32 3 true
test_case  11 44 4 false
test_case  10 56 4 true
test_case  10 68 5 false
reset_margin

set_cursor_pos 12 1
