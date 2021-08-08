#!/bin/bash

# Test of the effect of DECSTBM margin clipping on a Sixel image.

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

blank_lines() {
  local count=${1}
  for i in $(seq ${count}); do echo -n '-'; done
  echo
}

solid_lines() {
  local count=${1}
  local color=${2}
  for i in $(seq ${count}); do echo ${color}'!240~-'; done
}

multicolor_lines() {
  local count=${1}
  local color1=${2}
  local color2=${3}
  local end_with_lf=${4}
  local prefix=${5}
  for i in $(seq ${count})
  do
    echo -n ${prefix}${color1}'!120~'${color2}'!120~'
    if [[ ${i} -lt ${count} || ${end_with_lf} = true ]]; then echo -n '-'; fi
    echo
  done
}

set_cursor_pos 13 9
echo ${DCS}'2;1q'
solid_lines  2 '#2'
multicolor_lines 2 '#3' '#1' false
echo -n ${ST}

set_margin 10 15
set_cursor_pos 7 9
echo ${DCS}'2;1q'
multicolor_lines 2 '#1' '#3' true
solid_lines  4 '#2'
multicolor_lines 2 '#1' '#3' true
multicolor_lines 2 '#3' '#1' false
echo -n ${ST}

set_cursor_pos 10 9
echo -n $'\eM'
echo ${DCS}'1;1q'
multicolor_lines 2 '#1' '#3' false
echo -n ${ST}

set_cursor_pos 19 9
echo ${DCS}'2;1q'
solid_lines  2 '#2'
blank_lines 2
echo -n ${ST}

set_margin 4 21
set_cursor_pos 4 41
echo ${DCS}'2;0q'
echo '?' # trigger background fill
blank_lines 2
multicolor_lines 4 '#9' '#11' true '!80?'
multicolor_lines 4 '#11' '#9' false '!80?'
echo -n ${ST}

reset_margin
