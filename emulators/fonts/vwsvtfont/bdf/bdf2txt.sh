#!/bin/bash
gawk '
BEGIN { inchar=0;
	binhex["0"]="........";
	binhex["1"]="......@@";
	binhex["2"]="....@@..";
	binhex["3"]="....@@@@";
	binhex["4"]="..@@....";
	binhex["5"]="..@@..@@";
	binhex["6"]="..@@@@..";
	binhex["7"]="..@@@@@@";
	binhex["8"]="@@......";
	binhex["9"]="@@....@@";
	binhex["A"]="@@..@@..";
	binhex["B"]="@@..@@@@";
	binhex["C"]="@@@@....";
	binhex["D"]="@@@@..@@";
	binhex["E"]="@@@@@@..";
	binhex["F"]="@@@@@@@@";
}
/ENDCHAR/ { inchar=0;
	  printf("\n");
}
inchar == 1 {
       split($1, a, //);
       for (c in a) {
       	   printf( "%s", binhex[a[c]]);
       }	   
       printf("\n");
}
	
/BITMAP/ { inchar=1; }

' "$@"
