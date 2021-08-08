#!/bin/bash

# Test of the effect of raster attribute dimensions on a Sixel image.

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

raster_test() {
  local row=${1}
  local col=${2}
  local macro_param=${3}
  local raster_attributes=${4}
  local test_pattern=${5}
  local suffix=${6}

  set_cursor_pos ${row} ${col}
  echo ${DCS}${macro_param}'q"'${raster_attributes}
  echo ${test_pattern}
  echo ${ST}${suffix}
}

raster_test  4  8 1 '2;1;120;60' '#1?----!48?!24~-!48?!24~'
raster_test  4 26 1 '2;1;60;60'  '#1!12?!108~-!24?!96~-!36?!84~-!48?!72~-!60?!60~' '.'
raster_test  4 44 1 '2;1;120;30' '#1!12~-!24~-!36~-!48~-!60~-!60~-!60~-!60~-!60~-!60~'
raster_test  4 62 1 '2;1;0;0'    '#1!12?!108~-!24?!96~-!36?!84~-!48?!72~-!60?!60~-!60?-!60?-!60?-!60?-!60?-'
raster_test 16  7 2 '5;1;245;17' '#1!245~#0!35~-#1!30~-!30~-#0!30~'
raster_test 13 41 2 '5;1'        '#1?--!60?!280~-!60?!280~-!60?!280~-!60?!280~'

set_cursor_pos 11 1
