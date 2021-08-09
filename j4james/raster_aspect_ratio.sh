#!/bin/bash

# Test of the raster attributes aspect ratio in a Sixel image.

# If an image includes a raster attributes command, the first two parameters
# define the numerator and denominator of the pixel aspect ratio. On a genuine
# VT340, this ratio is rounded up to the nearest integer value, with a minimum
# value of 1. For example, 3:2 is 1.5, which rounds up to 2 (i.e. an aspect
# ratio of 2:1). If the denominator is zero, the aspect ratio is ignored, and
# will fall back to the value determined by the initial macro parameter.

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

aspect_ratio_test() {
  local col=${1}
  local aspect_ratio=${2}
  local sixel_lines=${3}

  set_cursor_pos 3 ${col}
  echo ${DCS}'2;1q"'${aspect_ratio}
  echo -n '#1'
  for i in $(seq ${sixel_lines}); do echo -n '!60~-'; done
  echo
  echo ${ST}
}

range_test() {
  for aspect_ratio in {1..22}
  do
    local col=$((${aspect_ratio} * 3 + 5))
    local macro_param=2
    if [[ ${aspect_ratio} = 5 ]]; then macro_param=1; fi 

    set_cursor_pos 8 ${col}
    echo -n ${DCS}${macro_param}';1q"'${aspect_ratio}';1'
    echo -n '#1!30~'
    echo ${ST}
  done
}

aspect_ratio_test  8 ''     2    # a blank AR falls back to the macro parameter value (5:1)
aspect_ratio_test 18 '0;0'  2    # a zero denominator also falls back to 5:1
aspect_ratio_test 28 '0;1' 10    # 0:1 = 0, but the minimum is 1:1
aspect_ratio_test 38 '1;3' 10    # 1:3 = 0.333, which rounds up to 1:1
aspect_ratio_test 48 '3;2'  5    # 3:2 = 1.5, which rounds up to 2:1
aspect_ratio_test 58 '7;4'  5    # 7:4 = 1.75, which rounds up to 2:1
aspect_ratio_test 68 '37;4' 1    # 37:4 = 9.25, which rounds up to 10:1

range_test

set_cursor_pos 17 1
