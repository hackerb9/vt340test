#!/bin/bash

CSI=$'\e['			# Control Sequence Introducer 
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

exec 5>testscroll.md	# Send output sent to filedescriptor 5 to a file.

set_cursor_pos() {
  echo -n ${CSI}${1}';'${2}'H'
}

test_case() {
  local ar=${1}
  local sixel_count=${2}
  local start_row=${3}

  echo -n ${CSI}'2J'

  set_cursor_pos 24 1
  echo -n 'Scrolled ->'

  set_cursor_pos ${start_row} 40

  echo ${DCS}'1q"'${ar}';1'
  for i in $(seq ${sixel_count})
  do
    echo -n '#'$((i%2 + 1))
    echo -n '!100~'
    if [[ ${i} -lt ${sixel_count} ]]; then echo -n '-'; fi
  done
  echo -n ${ST}

  for i in {0..10}
  do
    set_cursor_pos $((24 - i)) 13
    echo -n ${i}' rows'
  done

  local pixel_height=$((sixel_count * 6 * ar))
  local line_height=$(echo "scale=1;${pixel_height}/20"|bc)
  local overflow=$((start_row + ((pixel_height+19) / 20) - 25))

  set_cursor_pos 24 40
  read -e  -p "Scroll number? " -i "$overflow" scroll
  
  if [[ ${overflow} != ${scroll} ]]; then
      printf "|%12s"  "$ar:1"  "$pixel_height"  "$overflow"  "$scroll" >&5
      echo "|" >&5
      # "${line_height} rows"
      # "${start_row}"
  fi
}

printf "|%12s" "**AR**" "**Height**" "**Overflow**" "**Scroll**" >&5
echo "|" >&5
echo "|:-:|:-:|:-:|:-:|" >&5

for sixel_count in 10 15 20 25
do
  test_case 1 ${sixel_count} 22
done

for sixel_count in 5 7 10 13
do
  test_case 2 ${sixel_count} 22
done

for sixel_count in 5 6 9 10
do
  test_case 4 ${sixel_count} 19
done

for sixel_count in 2 3 4 5
do
  test_case 5 ${sixel_count} 22
done

for sixel_count in 5 6 8 10
do
  test_case 6 ${sixel_count} 16
done

for sixel_count in 2 3 4
do
  test_case 15 ${sixel_count} 16
done

set_cursor_pos 24 1
