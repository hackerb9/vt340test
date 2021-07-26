#!/bin/bash

# Test of the XOR mode and the home command in a Sixel image.

# On some terminal emulators, if you use a graphic carriage return to overwrite
# a line of sixels with another color, the color numbers are combined using an
# XOR operator. This allows for much more efficient multicolor output. However,
# this functionality is NOT supported on a genuine VT340.

# On the VT240, there is a home command (the '+' character), which moves the
# active sixel position back to the top left of the screen. This command is
# NOT support on a genuine VT340 though.

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

xor_test_pattern() {
  set_cursor_pos 7 11
  echo ${DCS}'2;1q'
  local patterns=('~F' 'w~')
  for color1 in {0..7}
  do
    echo '#'${color1}'!240~'
    echo -n '$'
    for color2 in {0..7}
    do
      local sixel=${patterns[${color1}/4]:${color2}/4:1}
      echo -n '#'${color2}'!30'${sixel}
    done
    echo '-'
  done
  echo ${ST}
}

home_command() {
  set_cursor_pos 7 47
  echo ${DCS}'2;1q'
  for color in 0 2 1 3
  do
    if [[ ${color} = 3 ]]; then echo '+'; fi
    echo '#'${color}'!240~-'
    echo '#'${color}'!240~-'
  done
  echo ${ST}
}

xor_test_pattern
home_command

set_cursor_pos 1 1
