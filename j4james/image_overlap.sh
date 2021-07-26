#!/bin/bash

# Test of overlapping Sixel images and color introducer edge cases.

# On a genuine VT340, if the background select parameter is set to 1, it is
# possible to layer multiple images on top of each other, without the lower
# images being erased.

# And when definining a color table entry with the color introducer command,
# the parameters are interpreted as follows:
# - If not enough parameters are supplied, missing values are interpreted as 0.
# - If more parameters are provided than necessary, extra values are ignored.
# - If a color coordinate is left empty, that is also interpreted as 0.
# - If a color coordinate is out of range, it is clamped to the maximum value.
# - If an invalid coordinate system is specified, the color table won't be
#   updated, but the color number will still be selected.
# - If no number is given after the color introducer, color 0 is selected.

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

update_color_table() {
  set_cursor_pos 19 16
  echo ${DCS}'2;1q'
  echo '#1;2;100;70'           # not enough parameters
  echo '#2;2;0;60;32;100'      # more parameters than necessary
  echo '#3;2;;65;100'          # empty color coordinate value
  echo '#4;2;130;20;30'        # out of range color coordinate
  echo '-'
  echo '#12#3;3;60;0;60!100~'  # invalid color coordinate system
  echo '#1!100~'
  echo '#12#!100~'             # missing color number
  echo '#2!100~'
  echo '#4!100~'
  echo ${ST}
}

output_ring() {
  local top_format=${1}
  local edge_format=${2}
  local color=${3}
  local row=${4}
  local col=${5}
  local yoffset=${6}
  local xoffset=${7}

  set_cursor_pos ${row} ${col}
  echo ${DCS}'2;1q'${color}
  for i in $(seq ${yoffset}); do echo -n '-'; done
  echo
  local padding=''
  if [[ ${xoffset} -gt 0 ]]; then padding='!'${xoffset}'?'; fi
  echo ${padding}${top_format}
  echo ${padding}${edges_solid}
  echo ${padding}${edges_solid}
  echo ${padding}${edge_format}
  echo ${padding}${edges_solid}
  echo ${padding}'!180~-'
  echo ${ST}
}

top_solid='!180~-'
top_with_gap='!50~!30?!100~-'
edges_solid='!30~!120?!30~-'
edges_with_gap='!150?!30~-'

update_color_table

output_ring ${top_solid} ${edges_solid}    '#3'   1 1  2 110
output_ring ${top_with_gap} ${edges_solid} '#1'   1 1  5 210 
output_ring ${top_solid} ${edges_with_gap} '#12#' 4 32 0   
output_ring ${top_with_gap} ${edges_solid} '#2'   7 42 1   
output_ring ${top_solid} ${edges_with_gap} '#4'   4 52 0  

set_cursor_pos 23 1
