#!/bin/bash

# Should move the text cursor downwards, even if no pixels were
# modified (given sixel scrolling is on).

clear
echo "A test of Sixel Graphics Carriage Return and Graphics Line Feed"
echo -e '\x1bPq$-$-$-$-\x1b\\'
echo -n "Your terminal ended here ->    (incorrect implementation)"
tput cup 4 28
echo "<- A genuine VT340 would end here."


