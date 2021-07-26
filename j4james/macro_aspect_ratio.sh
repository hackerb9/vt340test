#!/bin/bash

# Test of the macro parameter aspect ratio in a Sixel image.

# On a genuine VT340, the macro parameter defines the pixel aspect ratio
# of the image, assuming that isn't overridden by the raster attributes
# command. The macro parameter is interpreted as follows:
# - The default aspect ratio is 2:1.
# - Macro parameter values 7,8,9 select an aspect ratio of 1:1.
# - Macro parameter values 0,1,5,6 select an aspect ratio of 2:1.
# - Macro parameter values 3,4 select an aspect ratio of 3:1.
# - Macro parameter value 2 selects an aspect ratio of 5:1.
# - Any other parameter value selects an aspect ratio of 1:1.

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

macro_param_test() {
  local row=${1}
  local col=${2}
  local macro_param=${3}
  local sixel_lines=${4}
  local suffix=${5}

  set_cursor_pos ${row} ${col}
  echo ${DCS}${macro_param}';1q'
  echo -n '#1'
  for i in $(seq ${sixel_lines}); do echo -n '!60~-'; done
  if [[ ${sixel_lines} == *.3 ]]; then echo -n '!60B-'; fi
  echo
  echo ${ST}
}

macro_param_test 3  8 '' 5
macro_param_test 3 20 0  5
macro_param_test 3 32 1  5
macro_param_test 3 44 2  2
macro_param_test 3 56 3  3.3
macro_param_test 3 68 4  3.3
macro_param_test 8  8 5  5
macro_param_test 8 20 6  5
macro_param_test 8 32 7  10
macro_param_test 8 44 8  10
macro_param_test 8 56 9  10
macro_param_test 8 68 10 10

set_cursor_pos 13 1
