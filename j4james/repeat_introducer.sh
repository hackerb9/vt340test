#!/bin/bash

# Test of the repeat introducer command in a Sixel image.

# The repeat introducer command allows sixels to be run-length encoded by
# specifying a repeat count indicating the number of times that the next
# sixel is to be repeated. On a genuine VT340, the repeat count parameter
# is interpreted as follows:
# - If the count is missing, the following sixel is just used once.
# - If the count is zero, the following sixel is still used once.
# - If there is another command between the repeat count and the next sixel,
#   the repeat is ignored (i.e. the sixel is used once), but the intervening
#   command is still executed.
# - If the count is large enough that the repeated sixels would extend past
#   the edge of the screen, the image is simply truncated at the right border.

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

repeat_test() {
  local color=${1}
  local instances=${2}
  local repeat_introducer=${3}
  local suffix=${4}

  echo -n ${color}
  for i in $(seq ${instances})
  do
    echo -n ${repeat_introducer}
  done
  echo -n ${suffix}

  echo -n ' #2!20~'     # marker to indicate the end of the test section
  echo -n ' #3!32800~'  # large repeat count should fill to end of line
  echo '-'
}

set_cursor_pos 3 5
echo ${DCS}'2;1q'

# conventional repeat 20 (1 instance)
repeat_test '#1' 1 '!20~'

# empty repeat interpreted as 1 (20 instances)
repeat_test '#1' 20 '!~'

# zero repeat interpreted as 1 (20 instances)
repeat_test '#1' 20 '!0~'

# repeat 10 followd by a color change insterpreted as 1
repeat_test '#3' 5 '!10#1~' '!15~'

echo ${ST}

set_cursor_pos 11 1
