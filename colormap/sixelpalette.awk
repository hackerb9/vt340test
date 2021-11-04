#!/bin/bash

# Given a sixel file, print out the colors within it using the color
# index number a vt340 would use (which is based on the order
# assigned, not the literal number like "#0").

if [[ $# == 0 ]]; then set -- -; fi

# Palette size (for modulo)
p=16				# Sixteen is correct for the VT340


main() {
    for file; do
      sixtract "$file" | awk -F';' -v RS='#' \
	'
	  NR==2 {
	      if ($2 == "1") printf("Index:  Hue  Light  Sat\n");
	      if ($2 == "2") printf("Index:  Red  Green  Blue\n");
	  }
	  /^[0-9]+;/ {
	      idx=(NR-1)%'$p';
	      printf("%5d: %3d%%, %3d%%, %3d%%", idx, $3, $4, $5);
	      if (idx ==  7) printf("\t<-- Foreground");
	      if (idx == 15) printf("\t<-- Bright FG");
	      if (idx ==  0) printf("\t<-- Background");
	      printf("\n");
	  }
	'
    done
}

sixtract() {
    # Given a filename as $1, spit out the sixel data after skipping
    # over the byte the VT340 adds that confuse ImageMagick.
    #
    # Delete all lines and characters up until the first Esc P[;0-9]*q.
    # Print everything from the Esc P onward. (Escape is 0x1B).

    cat "$1" | 
	sed -E -n 's/^.*(\x1BP[;0-9]*q)/\1/; T; :end; p; n; bend'
}

main "$@"      
