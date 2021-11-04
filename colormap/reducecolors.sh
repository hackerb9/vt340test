#!/bin/bash

convert "$1" -depth 4 +dither -size '>800x>480' \
	\( +clone -colors 13 xc:black xc:gray50 xc:gray75 \
	   -unique-colors +append -write mpr:MYMAP +delete \
        \) -remap mpr:MYMAP sixel:-
