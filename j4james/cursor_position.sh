#!/bin/bash

# Test of the text cursor position after a Sixel image is output.

# On a genuine VT340, after an image is output, the text cursor position is
# set to the same row as the top of the final sixel line (regardless of
# whether anything is output on that line). The column position remains
# unchanged, i.e. it should align with the left of the image.

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

test_case() {
  local row=${1}
  local col=${2}
  local height=${3}
  local end_with_lf=${4}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'9;1q'
  echo -n '#1'
  
  for i in $(seq ${height})
  do
    echo -n '!70~'
    if [[ ${i} -lt ${height} || ${end_with_lf} = true ]]; then echo -n '-'; fi
  done

  echo
  echo -n ${ST}
  echo '---'
}

test_case 4 6 11 false
test_case 4 15 10 true
test_case 3 24 14 false
test_case 3 33 13 true
test_case 4 42 10 false
test_case 4 51 9 true
test_case 4 60 13 false
test_case 4 69 12 true

set_cursor_pos 10 1
