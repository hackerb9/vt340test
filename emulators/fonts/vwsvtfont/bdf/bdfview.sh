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
	    sprintf ("%sx%s%+d%d", bwidth, bheight, bxoffset, byoffset);

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

	# Draw a baseline for the glyphs to rest on.
	yoff = S[fontname]["FONT_ASCENT"];
	yoff = (yoff == "")? numlines + byoffset : yoff = int(yoff);
	gsub(/\./, "_", S[fontname][chr]["BITMAP"][yoff]);
    }
}

END {
    for (fn in S) {
	# Sort characters by encoding number
	asort( S[fn], sorted, "sortbyencoding" );

	# Print out every character
	for (i in sorted) {
	    if (!isarray(sorted[i])) continue;
	    if (!isarray(sorted[i]["BITMAP"])) continue;
	    chr = sorted[i]["STARTCHAR"];

	    /* Print first n lines with data on the right */
	    lineno=1;
	    printf("%s\t%s\n", sorted[i]["BITMAP"][lineno++], chr);
	    e = int(sorted[i]["ENCODING"]);
	    printf("%s\t%s-%s #%s", sorted[i]["BITMAP"][lineno++], S[fn]["CHARSET_REGISTRY"], S[fn]["CHARSET_ENCODING"], sorted[i]["ENCODING"]);
	    if (e>32 && e<127) printf(" (%c)", e);
	    printf("\n");
	    printf("%s\t%s\n", sorted[i]["BITMAP"][lineno++], sorted[i]["GEOMETRY"]);
	    printf("%s\tFoundry: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["FOUNDRY_NAME"]);
	    printf("%s\tFamily: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["FAMILY_NAME"]);
	    printf("%s\tWeight: %s, Slant: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["WEIGHT_NAME"], S[fn]["SLANT"]);
	    printf("%s\tWidth: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["SETWIDTH_NAME"]);
	    printf("%s\tPt size and DPI: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["SIZE"]);
	    printf("%s\tCap-height: %s, x-height: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["CAP_HEIGHT"], S[fn]["X_HEIGHT"]);
	    printf("%s\tDescent: %s, Ascent: %s\n", sorted[i]["BITMAP"][lineno++], S[fn]["FONT_DESCENT"], S[fn]["FONT_ASCENT"]);

	    /* Print the rest of the lines, if any */
	    for (; lineno <= numlines; lineno++) {
		print sorted[i]["BITMAP"][lineno];
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

function sortbyencoding(i1, v1, i2, v2,    t1, t2) {
    if ( isarray(v1) ) 
	t1 = int(v1["ENCODING"]);
    else
	t1 = -1;

    if ( isarray(v2) ) 
	t2 = int(v2["ENCODING"]);
    else
	t2 = -1;
    
    return (t1 - t2);
}



' "$@"
