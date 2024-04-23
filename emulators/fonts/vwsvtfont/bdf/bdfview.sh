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

$1 == "ENDFONT" {
    # Trim or expand each character to its bounding box.
    # "BBX 8 16 0 -2 declares a bounding box that is 8 pixels wide and
    #  16 pixels tall. The lower left-hand corner of the character is
    #  offset by 0 pixels on the X-axis and -2 pixels on the Y-axis." -wikipedia
    print "Processing ", fontname
    for (chr in S[fontname]) {
	if (!isarray(S[fontname][chr])) continue;
	if (!isarray(S[fontname][chr]["BITMAP"])) continue;

	split(S[fontname][chr]["BBX"], bbx);
	bwidth = bbx[1]; bheight = bbx[2];
	bxoffset = bbx[3]; byoffset = bbx[4];

	S[fontname][chr]["GEOMETRY"]= \
	    sprintf ("%sx%s%+d%d\n", bwidth, bheight, bxoffset, byoffset);

	numlines = length(S[fontname][chr]["BITMAP"]);

	if (bheight != numlines) {
	    printf( "%s has %d lines and bbx height of %d\n",
		    fontname chr, numlines, bheight) >"/dev/stderr";
	    print "ERROR: This script does not yet handle characters which are defined with a different height than their bounding box." >"/dev/stderr";
	}

	# Each pixel is shown as two columns "@@" to correct for aspect ratio.
	pixelwidth = length(S[fontname][chr]["BITMAP"][1]) / 2;
	if (bwidth > pixelwidth) {
	    printf( "%s is %d pixels wide and the bbx width is %d\n",
		    fontname chr, pixelwidth, bwidth) >"/dev/stderr";
	    print "ERROR: This script does not handle characters which are defined with a smaller width than their bounding box." >"/dev/stderr";
	}

	# Trim to bwidth pixels.
	for (lineno=1; lineno <= numlines; lineno++) {
	    S[fontname][chr]["BITMAP"][lineno] = \
		substr(S[fontname][chr]["BITMAP"][lineno], 1, 2*bwidth);
	}

	# Draw a baseline for the y-offset.
	gsub(/\./, "_", S[fontname][chr]["BITMAP"][numlines + byoffset]);
    }
}

END {
    # Just a data dump for now
    # TODO: print out each character on left with vital stats on right
    for (fn in S) {
	# Sort characters by encoding
	asort(S[fn],S[fn],"sortbyencoding");

	# Print out every character
	for (chr in S[fn]) {
	    if (!isarray(S[fn][chr])) continue;
	    if (!isarray(S[fn][chr]["BITMAP"])) continue;
	    for (lineno=1; lineno <= numlines; lineno++) {
		print S[fn][chr]["BITMAP"][lineno];
	    }
	    print "\n";
	}
    }
    exit;
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

function sortbyencoding(i1, v1, i2, v2) {
    if ( !isarray(v1) || !isarray(v2) )
	return 0;
    return (v1[encoding] < v2[encoding]);
}



' "$@"
