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
  local macro_param=${3}
  local height=${4}
  local end_with_lf=${5}

  set_cursor_pos ${row} ${col}
  echo ${DCS}${macro_param}';1q'
  echo -n '#1'
  
  for i in $(seq ${height})
  do
    echo -n '!60~'
    if [[ ${i} -lt ${height} || ${end_with_lf} = true ]]; then echo -n '-'; fi
  done

  echo
  echo -n ${ST}
  echo '---'
}

test_case  3  8 9 14 false
test_case  3 20 9 13 true
test_case  3 32 9 13 false
test_case  3 44 9 12 true
test_case  3 56 9 11 false
test_case  3 68 9 10 true
test_case 10  8 2  2 false
test_case 10 20 2  1 true
test_case  9 32 9 10 false
test_case  9 44 9  9 true
test_case  8 56 2  3 false
test_case  8 68 2  2 true

set_cursor_pos 6 1
echo '>'${CSI}'80C<'
set_cursor_pos 11 1
echo '>'${CSI}'80C<'

set_cursor_pos 15 1
