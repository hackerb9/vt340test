#!/bin/bash

# Test of DECSTBM (Set Scrolling Region) and sixels.
# Do sixels obey scrolling regions and origin mode? Yes.

CSI=$'\e['

echo -n ${CSI}H${CSI}J		# Clear screen
echo -e "\t\tTesting DECSTBM (scrolling region) interaction with sixels"

top=10
bot=15
echo
echo -n ${CSI}"$((top-1));1H"
echo -e "\tvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo -n ${CSI}"$((bot+1));1H"
echo -e "\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

case "$1" in
    "")    echo -e "\t\tScrolling region set from $top to $bot" ;;
    decom) echo -e "\t\tScrolling region set from $top to $bot" 
	   echo -en "\t\tand DECOM Origin Mode enabled"
	   echo " (Cursor cannot leave region)"
	   ;;
    nodecstbm) echo -e "\n\t\t\t[Example with no scrolling region set]" ;;
    *) echo "Usage: $0 [nodecstbm | decom]" >&2; exit 1 ;;
esac

if [[ "$1" != "nodecstbm" ]]; then
    echo -n "${CSI}${top};${bot}r"
fi

if [[ "$1" == "decom" ]]; then
    echo -n "${CSI}?6h"
fi

echo -n ${CSI}H			# Move cursor to home (1,1)

echo -n "Line 1"
indent=" "
for n in {2..24}; do
    echo -en "\n${indent}Line $n"
    indent="${indent} "
    sleep 0.1
done

# Test of sixels image that scrolls
echo -n ${CSI}H			# Move cursor to home (1,1)
cat cat3.six
       
# Clear scrolling region.
echo -n ${CSI}"r"

# Disable DEC Origin Mode: Cursor can leave region
echo -n "${CSI}?6l"

# Place cursor at end of screen
echo -n ${CSI}"$((bot+4));1H"
