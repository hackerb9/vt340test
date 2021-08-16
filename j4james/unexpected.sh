#!/bin/bash

# Test of DCS terminators and unexpected characters in the control string.

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

test_terminator() {
  local row=${1}
  local st_prefix=${2}
  local st_suffix=${3}

  set_cursor_pos ${row} 8
  echo -n ${DCS}'2;1q'

  echo -n '#6!30~#8!30~-'
  echo -n '#8!30~#6!30~-'

  # The prefix includes a terminator and some test output.
  echo -n ${st_prefix}

  # This is followed by a real ST in case the terminator doesn't work.
  echo -n ${ST}

  # The suffix adds additional test characters to match the prefix.
  echo "${st_suffix}"
}

test_controls() {
  local row=${1}
  local col=${2}
  local c1=${3:0:4}
  local c2=${3:4:4}
  local c3=${3:8:4}

  set_cursor_pos ${row} ${col}
  printf ${DCS}'2;1q'

  # Embed test characters between commands.
  printf "#6${c1}!15~${c2}#14!${c3}15~"

  # Embed test characters in the middle of commands.
  printf "#8!1${c1}5~#${c1}7!15~-"
  printf "#7!1${c2}5~#${c2}8!15~"
  printf "#14!1${c3}5~#${c3}6!15~-"

  echo ${ST}

  # If we've output XOFF, we need to follow up with XON.
  if [[ ${c2} == '\x13' ]]; then echo $'\x11'; fi
}

test_other() {
  local row=${1}
  local col=${2}
  local c1=${3:0:1}
  local c2=${3:1:1}
  local c3=${3:2:1}

  set_cursor_pos ${row} ${col}
  echo -n ${DCS}'2;1q'

  # Embed test characters between commands.
  echo -n "#6${c1}!15~${c2}#14!${c3}15~"

  # Embed test characters in the middle of commands.
  echo -n "#8!1${c1}5~#${c1}7!15~-"
  echo -n "#7!1${c2}5~#${c2}8!15~"
  echo -n "#14!1${c3}5~#${c3}6!15~-"

  echo ${ST}
}

# CAN should terminate the string and should not be output. 
test_terminator  4 $'\030...' '...'

# SUB should terminate the string but should also be output.
test_terminator 10 $'\032..' '..?'

# ESC should terminate the string and also execute the escape sequence.
test_terminator 16 $'\033[6C' $'\033[6D......'

# Other control characters should just be ignored.
test_controls 4  20 '\x00\x01\x02'
test_controls 4  32 '\x03\x04\x05'
test_controls 4  44 '\x06\x07\x08'
test_controls 4  56 '\x09\x0A\x0B'
test_controls 4  68 '\x0C\x0D\x0E'
test_controls 10 20 '\x0F\x10\x11'
test_controls 10 32 '\x12\x13\x14'
test_controls 10 44 '\x15\x16\x17'
test_controls 10 56 '\x19\x1C\x1D'
test_controls 10 68 '\x1E\x1F\x7F'

# Printable characters with no function should also be ignored.
test_other 16 20 " %&"
test_other 16 32 "'()"
test_other 16 44 "*+,"
test_other 16 56 "./:"
test_other 16 68 "<=>"

set_cursor_pos 23 1
