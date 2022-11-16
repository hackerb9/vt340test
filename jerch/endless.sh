#!/bin/bash
# sixel endless mode
# Should print an endless sine curve, abort with Ctrl-C.

pi=$(echo "scale=10; 4*a(1)" | bc -l)
period=200
amplitude=50
y=0

run=true
cleanup() {
  run=false
  /bin/echo "\x1b\\"
}
trap cleanup INT

/bin/echo -ne "\x1bP0;0;0q\"1;1#1;2;100;0;0#1"
while $run
do
  x=$(echo "s(2*${pi}*${y}/${period})*${amplitude}+2*${amplitude}+0.5" | bc -l)
  p=$(echo "scale=0; $y%6" | bc)
  case "$p" in
    0 ) /bin/echo -ne "!${x%%.*}?@\$" ;;
    1 ) /bin/echo -ne "!${x%%.*}?A\$" ;;
    2 ) /bin/echo -ne "!${x%%.*}?C\$" ;;
    3 ) /bin/echo -ne "!${x%%.*}?G\$" ;;
    4 ) /bin/echo -ne "!${x%%.*}?O\$" ;;
    5 ) /bin/echo -ne "!${x%%.*}?_\$" ;;
  esac
  [ "$p" = "5" ] && /bin/echo -e "-"
  y=$(echo "$y+1" | bc)
done

/bin/echo -e "\x1b\\"
