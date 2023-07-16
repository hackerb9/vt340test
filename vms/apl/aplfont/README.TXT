Excerpt from "VAX APL Users Guide: The VAX APL Operating Environment"

FONT FILES

APL character support for the designators listed in Table 1-10 use font files
provided with the APL software. Logical names are used to find the associated
font file. You can define these logical names to point to your own font files.
Otherwise, APL uses the font files installed with VAX APL.

Table 1-10 Terminal Designator Font Files

| Designator | 8O-column Mode Logical | 132-column Mode Logical |
|------------|------------------------|-------------------------|
| VT220      | APL$VT220_FONT         | APL$VT220_FONT          |
| VT240      | APL$VT240_FONT         | APL$VT240_FONT_132      |
| VT320      | APL$VT22O_FONT         | APL$VT320_FONT_132      |
| VT330      | APL$VT330_FONT         | APL$VT330_FONT_132      |
| VT340      | APL$VT340_FONT         | APL$VT340_FONT_132      |

----------------------------------------------------------------------

Note from hackerb9:

The official fonts from DEC have some suboptimal characters for the
VT340. Apparently, the person designing the font did not have access
to a VT340 and so some of the characters would look right on a VT220,
which has pixels that are twice as tall as they are wide. The VT340
has square pixels, so circles appear squashed. (Consider the logarithm
operator, Circled Star at 0xEB.)

Amusingly, if I load the VT220 font on my VT340, the circles actually
are circular because the VT340 knows to double the height of VT220
fonts. Of course, the tradeoff in resolution is not worth it. (The
VT220 font is 7x10, while the VT340's is 10x20).

At some point, it would be good if someone edited the VT340 APL font
and doubled the height of all glyphs which appear squashed. Other than
the alphabet, which was copied from the VT340's actual font, every
glyph should be examined. However, the work can be narrowed down to
these typographical sins crying out to heaven for justice:

Worst offenders:    DF, E0, EB, EC, ED, EE, B4

Could be better:    DD, DE, B0, F2, F3, BA, BB
      	  	    E1..E5, B2, B1, BC, BE, C0

