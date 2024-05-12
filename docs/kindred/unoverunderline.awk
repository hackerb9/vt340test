#!/bin/bash
#							-*- awk -*-
# DEC's markup convention in the file EK-VSXPR-TM-001 appears to use
# underscores as a special character. (See examples at end of file).

# This script tries to undo that and make a file that can be viewed on
# a terminal using standard ^H sequences for overstriking and
# underlining. (See ul(1)).
#
######################################################################

# Mostly works. Todo: Emphasis when text is above or below the line.


gawk '
BEGIN {
    und=-1;
    super[0]="⁰";
    super[1]="¹";
    super[2]="²";
    super[3]="³";
    super[4]="⁴";
    super[5]="⁵";
    super[6]="⁶";
    super[7]="⁷";
    super[8]="⁸";
    super[9]="⁹";
    super[","]="⸴";
    super["["]=" ";
    super[" "]=" ";
    super["]"]=" ";
}


# Save each line in a buffer to be processed
{ lines[NR]=$0; }


# Superscript [1] [2,3]
/\[[0-9, ]+\]/ {
    lines[NR]=""; foot=0;
    patsplit($0, a, ".");
    for (i in a) {
	c = a[i];
	if ( c == "[" ) foot=1;
	if ( !foot ) lines[NR] = lines[NR] c;
	else         lines[NR] = lines[NR] super[c];
	if ( c == "]" ) foot=0;
    }
}


# Bullet point: previous line should have a bullet point
/^ *_$/ && BP == NR-2 {
    lines[NR-1]=substr(lines[NR-1], length()+1);
    lines[NR-2]="";
    for (i=0; i<length()-1; i++)
	lines[NR-2]=lines[NR-2]" "; 
    lines[NR-2]=lines[NR-2]"\xe2\x80\xa2" lines[NR-1];
    NR=NR-2;
    BP=0;
    next;
}

NR>2 && BP == NR-2 {
    # Whoops, that previous character was not a bullet point!
    lines[NR-2] = underline(lines[NR-1], lines[NR-2]);
    NR=NR-2;
    BP=0;
    und=-1;
    # Fall through to continue processing lines[NR]
}


# Bullet point detection: Following line will have a bullet point at
# column 5 iff the line after it also looks like "    _$", see above.
/^ *_$/ {
    BP=NR;
    next;
}


# Standout: Underlining + bold when text can be merged two lines up.
NR>2 && und == NR-1 && !/^ *\[ *[0-9]+ *\]/ && !/^ *[⁰¹²³⁴⁵⁶⁷⁸⁹]+/ {
    if (mergeable(lines[NR], lines[NR-2])) {
	lines[NR-2] = standout(lines[NR], lines[NR-2]);
	NR=NR-2;
	und=-1;
	next;
    }
}

# Underlining: this line gets underlined and moved up, if not a footnote.
und == NR-1 && !/^ *\[[0-9 ]+ *\]/ && !/^ *[⁰¹²³⁴⁵⁶⁷⁸⁹]+/ {
    lines[NR-1] = underline(lines[NR], lines[NR-1]);
    NR=NR-1;
    und=-1;
    # Fall through bolding
}

# Underline detection: next line will get underlined and moved up.
/^[ _]*_[ _]*$/ {
    und = NR;
    next;
}

# Emphasis: if two lines could be merged together,
#            make upper one bold and merge them.
NR>1 && BP != NR-1 {
    if (mergeable(lines[NR-1], lines[NR])) {
	lines[NR-1] = boldmerge(lines[NR-1], lines[NR] );	NR=NR-1;
    }
}



END {
    for (n=1; n<=NR; n++) {
	print lines[n];
    }
}

#### Functions

# mergeable: return true iff s2 has spaces where s1 has text
# (and s2 is not completely blank).
function mergeable(s1, s2,      i, j, c1, c2, seen1, seen2) {
    seen1=0; seen2=0;
    s1 = pad(s1, length(s2), " ");
    s2 = pad(s2, length(s1), " ");
    j=1;
    for (i=1; i<=length(s1); ) {
	c1=substr(s1, i, 1);
	c2=substr(s2, j, 1);
	while ( substr(s1, i+1, 1) == "\b" ) {
	    c1 = substr(s1, i+2, 1);
	    i=i+2;
	}
	while ( substr(s2, j+1, 1) == "\b" ) {
	    c2 = substr(s2, j+2, 1);
	    j=j+2;
	}

	if (c1 != " " && c2 != " ")
	    return 0; 		# False: both strings have a char at pos. i.
	if (c1 !~ /[ \t\f\n\r\v]/) seen1=1;
	if (c2 !~ /[ \t\f\n\r\v]/) seen2=1;

	while (substr(s1, i+1, 1) == "\b") i=i+2;
	while (substr(s2, j+1, 1) == "\b") j=j+2;

	i++; j++;
    }
    return seen1 && seen2;		# True: strings are mergeable.
}

# bold: return s2, with spaces replaced by matching text in s1, emboldened.
function boldmerge(s1, s2) {
    return boldmaybestandout(s1, s2);
}

# standout: return s2 with spaces replaced by matching text in s1, ul & bold.
function standout(s1, s2) {
    return boldmaybestandout(s1, s2, "_\b");
}


# boldmaybestandout:
# return s2 with spaces replaced by matching text in s1, modified.
# If mod="", then s1 is made bold. If mod="_\b", the s2 is made ul and bold.
function boldmaybestandout(s1, s2, mod,     i, j, c1, c2, c1end) {
    rv="";
    s1=pad(s1, length(s2), " ");
    s2=pad(s2, length(s1), " ");
    j=1;
    for (i=1; i<=length(s1); ) {
	c1=substr(s1, i, 1);
	c2=substr(s2, j, 1);
	while ( substr(s1, i+1, 1) == "\b" ) {
	    c1 = c1 substr(s1, i+1, 2);
	    i=i+2;
	}
	while ( substr(s2, j+1, 1) == "\b" ) {
	    c2 = c2 substr(s2, j+1, 2);
	    j=j+2;
	}

	c1end=substr(c1, length(c1), 1);
	if (c1end == " ")
	    rv=rv c2
	else
	    rv=rv mod c1 "\b" c1end
	i++; j++;
    }
    return rv;
}

# Pad string s to length n using char c, if it is not that long already
function pad(s, n, c) {
    n = n - length(s);
    while (n-->0) {
	s = s c
    }
    return s;
}

# Underline the characters in s where there is an underscore in u.
function underline(s, u,    i, rv) {
    rv=""
    s = pad(s, length(u), " ");
    u = pad(u, length(s), "_");
    for (i=1; i<=length(s); i++) {
	if (substr(u,i,1) == "_") {
	    rv=rv "_\b";
	}
	rv=rv substr(s,i,1);
    }
    return rv;
}


# # bold: any text in string s is duplicated with ^H to display in bold
# function oldbold(s) {
#     return gensub(/[^[:space:]]/, "&\b&", "g", s);
# }


# function oldunderline(s,    a, rv, c) {
#     rv="";
#     split(s, a, "");
#     for (c in a) {
# 	rv = rv a[c] "\b_";
#     }
#     return rv;
# }





' "$@"





######################################################################
# Examples of the weird over-underlining in the DEC documentation source markup.
# The text should be moved *two* lines up and underlined.

    #                           .
    #                ___ ___ ___
    #                DEC STD 015

# Underlined paragraph. Probably should be rendered as italic as
# underlining everything would be super ugly. Unfortunately, I don't
# know how to do italics with ^H.

    # ____
    # Note
    #      _________ ___ __________ ________ __ ___ ________
    #      Normally, the peripheral repeater is not repaired
    #    __ ___ ______ ________ ___ ________ ________ __
    #    in the field; instead, the internal assembly is
    #    _________
    #    replaced.

# And then sometimes, words seem to be raised up a line for emphasis
# (bold?). I cannot figure out the rule for how to distinguish that
# from normal underlining.

    #
    #                           _____
    #                           KA800
    #   __________ ____ _______       ______ __ ___
    #   Throughout this manual,       refers to the
    #   _________ _________ __ ___ __________ _________
    #   processor connected to the peripheral repeater,
    #       ____
    #       host
    #   ___      ______ __ ___ ____ _________ __________
    #   and      refers to the host subsystem processor.

# In this example, a pair of single underscores seem to indicate a
# bullet point on the line between them. (/^ {4}_$/).

    #     _
    #       Byte 6 is the bit-encoded configuration, where
    #     _
    #             is set if a device with an active device
    #       ___ _
    #       bit n
    #       present signal is attached to       .
    #                                     ____ _
    #                                     port n
    #
    #     _
    #       Byte 7 is the hexadecimal value of the periph-
    #     _
    #       eral repeater's firmware revision.


# A long line of dashes seems to indicate a horizontal rule. Usually,
# but not always, they appear *before* the text which the horizontal
# rule will underscore. This is rendered the same as underlining.

    #   ____________________________________________________
    #   Table 1-5 (Continued): Environmental Specifications
    #   ____________________________________________________
    #   Parameter                         Specification
    #
    #                                     _______  _______
    #   Acoustics                         LPNE     LPA
    #
    #                                     4.8 B    42 dBa
    #   ____________________________________________________
    #

# However, a line with a footnote should *not* appear above the
# horizontal rules that precedes it.

    #   ____________________________________________________
    #   ADDR  State Description
    #
    #         LLL   Receiver Buffer (ADDR 07 = H)
    #         LLL   Transmitter Holding Register (ADDR 07 =
    #         LLH   L)
    #         LHL   Status Register
    #         LHH   Mode Registers 1 and 2[1]
    #         HLL   Command Register
    #         HLH   Interrupt Summary Register
    #         HHL   Data Set Change Summary Register
    #         HHH   Not used
    #               Not used
    #   ____________________________________________________
    #   [1]Mode Registers 1 and 2 are accessed by sequen-
    #   tial operations (read/read, read/write, write/read,
    #   or write/write) to the same address. The first op-
    #   eration accesses Mode Register 1, the next Mode
    #   Register 2, the next Mode Register 1, and so on.
    #   ____________________________________________________
    #

# Here is an example that mixes horizontal rules, underlining, and
# table footnotes.

    #    Table 2-18: Diagnostic and Function LED Indication
    #     ____________________________________________________
    #                 Summary
    #    Function     Diagnostic
    #    ____________________________________________________
    #    LED          LEDs[1]       Description
    #
    #                 __  ________
    #                 76  543210
    #
    #
    #    Green        00  000000    No peripheral repeater
    #                               (PR) or KA800 errors. PR
    #                               is in operational mode.
    #
    #    Green        01  eeeeee    KA800 error, no PR
    #                               error. PR is in
    #                               operational mode.[2]
    #
    #    Green        10  eeeeee    PR error, no KA800
    #                               error. PR is attempting
    #                               to enter operational
    #                               mode.[3]
    #
    #    Yellow       10  dddddd    Self-test. PR is
    #                               executing self-test.
    #
    #    Yellow       10  eeeeee    PR 8031 error. PR will
    #                               not enter operational
    #                               mode.[3]
    #
    #    Red          10  dddddd    Manufacturing mode.
    #                               PR is in manufacturing
    #                               mode.
    #
    #    ____________________________________________________
    #    [1]1 = on, 0 = off, d = dynamic, e = error code.
    #    [2]For additional information on error codes see
    #    the                              .
    #        __________ ____ ______ ______
    #        VAXstation 8000 System Manual
    #    [3]8031 errors are the only errors which will
    #    prevent the peripheral repeater from entering
    #    operational mode.
