#!/bin/bash
# View a bitmap font in ASCII art. 				-*- awk -*-
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


$1 == "ENDCHAR" {
    inchar=0;
}

inchar == 1 {
    split($1, a, //);
    lineno = length( S[fontname][chr]["BITMAP"] ) + 1;
    for (c in a) {
	S[fontname][chr]["BITMAP"][lineno] = \
	    S[fontname][chr]["BITMAP"][lineno] binhex[a[c]];
    }	   
    next;
}
	
$1 == "STARTFONT" { next; }
$1 == "FONT" { pop(); fontname = $0; }
$1 == "BITMAP" { inchar = 1; }
$1 == "STARTCHAR" { chr = $2; }

NF > 1 {
    key = pop();				# $1, all fields shift left
    if (chr)
	S[fontname][chr][key] = ddq(); 		# $0, without double-quotes
    else
	S[fontname][key] = ddq();
}


END {
    # Just a data dump for now
    for (fn in S) {
	print "fontname: " fn;
	for (key in S[fn]) {
	    if (!isarray(S[fn][key])) {
		printf("%s: %s\n",  key, S[fn][key]);
	    }
	    else {
		for (key2 in S[fn][key]) {
		    if (key2 != "BITMAP") {
			printf("    %s: %s: %s\n",  key, key2,
			       S[fn][key][key2]);
		    }
		    else {
			for (i=1; i<=length(S[fn][key]["BITMAP"]); i++) {
			    printf("    %s: %s: %s\n",  key, key2,
				   S[fn][key]["BITMAP"][i]);
			}
		    }

		}
	    }
	}
    }
}


function ddq() {
    # Return $0, but without double-quote at beginning or end.
    return gensub(/^"|"$/, "", "g");
}

function pop(  i, item) {
    # Return $1 and remove it from $0 (all fields shift left).
    item=$1
    for (i=1; i<NF; i++)
	$i=$(i+1)
    NF--;
    return item;
}

' "$@"
