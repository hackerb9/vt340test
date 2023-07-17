# The APL soft fonts from DEC and their discontents

These files are the "soft fonts" that DEC shipped with VAX APL. 

**Table 1-10 Terminal Designator Font Files**

| Designator | 8O-column Mode Logical               | 132-column Mode Logical                      |
|------------|--------------------------------------|----------------------------------------------|
| VT220      | [APL$VT220_FONT](APL$VT220_FONT.FNT) | [APL$VT220_FONT](APL$VT220_FONT)             |
| VT240      | [APL$VT240_FONT](APL$VT240_FONT.FNT) | [APL$VT240_FONT_132](APL$VT240_FONT_132.FNT) |
| VT320      | [APL$VT22O_FONT](APL$VT22O_FONT.FNT) | [APL$VT320_FONT_132](APL$VT320_FONT_132.FNT) |
| VT330      | [APL$VT330_FONT](APL$VT330_FONT.FNT) | [APL$VT330_FONT_132](APL$VT330_FONT_132.FNT) |
| VT340      | [APL$VT340_FONT](APL$VT340_FONT.FNT) | [APL$VT340_FONT_132](APL$VT340_FONT_132.FNT) |

<ul><sub><i>

Duplicates: The [install file](../saveset/A/kitinstal.com) copies the
VT220 80-column font as "VT240" and both the 80- and 132-column VT330
fonts as "VT340". Note that the VT240 has a 132-column font which the
VT220 lacks.

</i></sub></ul>


## Usage

These files are in [Downline Load (DECDLD) format][DECDLD]. When
`cat`ed to the screen, the terminal loads the font into a buffer as a
Dynamically Redefinable Character Set ("DRCS"). These fonts have use
the SCS designator ("Dscs") `&0`. Because the files end with the
sequence `ESC` `)` `&` `0`, they are automatically loaded as G1
(Graphic Set #1), which, by default on the VT340 means they will be
used for GR (Graphic Right, which is the 8-bit characters 0xA1 to
0xFE).

These original files do _not_ work on modern terminals which support
UTF-8. Please see hackerb9's [modified APL font](../aplfontb9) which
should work on both original and new equipment.

1. The files use the 8-bit control codes for **DCS** and **ST** which
   conflict with UTF-8. A simple solution is to use 7-bit controls:

		sed -i $'s#\x90#\eP#; s#\x9c#\e\\#' *.FNT

2. Graphic Right does not work on terminals where `LANG` is set to
   UTF-8. The solution is to temporarily map the set to Graphic Left
   (replacing the ASCII characters). An application could send LS1,
   the APL characters, then LS0.


| Name            | Mnemonic | Sequence | Hex   | Function                                                  |
|-----------------|----------|----------|-------|-----------------------------------------------------------|
| Locking Shift 0 | LS0      | \<SI\>   | 0F    | The G0 character set becomes the active GL character set. |
| Locking Shift 1 | LS1      | \<SO\>   | 0E    | The G1 character set becomes the active GL character set. |
| Locking Shift 2 | LS2      | ESC n    | 1B 6E | The G2 character set becomes the active GL character set. |
| Locking Shift 3 | LS3      | ESC o    | 1B 6F | The G3 character set becomes the active GL character set. |



[DECDLD]: https://github.com/hackerb9/vt340test/raw/main/docs/EK-PPLV2-PM.B01_Level_2_Sixel_Programming_Reference.pdf#page=114


## Excerpt from "VAX APL Users Guide: The VAX APL Operating Environment"

### Font Files

APL character support for the designators listed in Table 1-10 use font files
provided with the APL software. Logical names are used to find the associated
font file. You can define these logical names to point to your own font files.
Otherwise, APL uses the font files installed with VAX APL.


----------------------------------------------------------------------

## Squished fonts on VT340

These official fonts from DEC have some suboptimal characters for the
VT340. Apparently, the font designer did not have access to a VT340 as
many of the characters would look right on a VT220, which has pixels
that are twice as tall as they are wide. The VT340 has square pixels,
so circles appear squashed. Consider, for example, the logarithm
operator, Circled Star at 0x6B.

![Montage of DEC's VT340 APL characters][montage]

In a twist, using the VT220 font on a VT340 does not have this
problem. The VT340 knows to double the height of VT220 fonts, so the
circles actually are circular. Of course, the tradeoff in resolution
is not worth it; the VT340's matrix is 10x20, while the VT220's is
only 7x10.

At some point, it would be good if someone edited the VT340 APL font
and doubled the height of all glyphs which appear squashed. Hackerb9
has compiled a table with the actual glyph size to help identify which
ones can be simply doubled in height to fix them.

<details><summary>Click to see table of characters with glyph dimensions</summary>

`for f in char-apl-10x20-??.png; do convert $f +trim info:-; done  | column -t -o" | "`
| Filename              |                                              |       |           |
|-----------------------|----------------------------------------------|-------|-----------|
| char-apl-10x20-21.png | <img src="chars-orig/char-apl-10x20-21.png"> | 7x2   | 10x20+2+4 |
| char-apl-10x20-22.png | <img src="chars-orig/char-apl-10x20-22.png"> | 8x11  | 10x20+1+5 |
| char-apl-10x20-23.png | <img src="chars-orig/char-apl-10x20-23.png"> | 7x7   | 10x20+2+7 |
| char-apl-10x20-24.png | <img src="chars-orig/char-apl-10x20-24.png"> | 7x7   | 10x20+2+7 |
| char-apl-10x20-25.png | <img src="chars-orig/char-apl-10x20-25.png"> | 8x14  | 10x20+1+3 |
| char-apl-10x20-26.png | <img src="chars-orig/char-apl-10x20-26.png"> | 6x8   | 10x20+2+6 |
| char-apl-10x20-27.png | <img src="chars-orig/char-apl-10x20-27.png"> | 7x6   | 10x20+2+7 |
| char-apl-10x20-28.png | <img src="chars-orig/char-apl-10x20-28.png"> | 8x1   | 10x20+1+4 |
| char-apl-10x20-29.png | <img src="chars-orig/char-apl-10x20-29.png"> | 9x7   | 10x20+1+7 |
| char-apl-10x20-2A.png | <img src="chars-orig/char-apl-10x20-2A.png"> | 8x8   | 10x20+1+7 |
| char-apl-10x20-2B.png | <img src="chars-orig/char-apl-10x20-2B.png"> | 7x7   | 10x20+2+8 |
| char-apl-10x20-2C.png | <img src="chars-orig/char-apl-10x20-2C.png"> | 5x11  | 10x20+3+4 |
| char-apl-10x20-2D.png | <img src="chars-orig/char-apl-10x20-2D.png"> | 8x7   | 10x20+1+7 |
| char-apl-10x20-2E.png | <img src="chars-orig/char-apl-10x20-2E.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-2F.png | <img src="chars-orig/char-apl-10x20-2F.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-30.png | <img src="chars-orig/char-apl-10x20-30.png"> | 6x7   | 10x20+2+7 |
| char-apl-10x20-31.png | <img src="chars-orig/char-apl-10x20-31.png"> | 6x4   | 10x20+2+8 |
| char-apl-10x20-32.png | <img src="chars-orig/char-apl-10x20-32.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-33.png | <img src="chars-orig/char-apl-10x20-33.png"> | 8x8   | 10x20+1+7 |
| char-apl-10x20-34.png | <img src="chars-orig/char-apl-10x20-34.png"> | 8x6   | 10x20+1+7 |
| char-apl-10x20-35.png | <img src="chars-orig/char-apl-10x20-35.png"> | 7x10  | 10x20+1+7 |
| char-apl-10x20-36.png | <img src="chars-orig/char-apl-10x20-36.png"> | 5x11  | 10x20+3+4 |
| char-apl-10x20-37.png | <img src="chars-orig/char-apl-10x20-37.png"> | 8x10  | 10x20+1+5 |
| char-apl-10x20-38.png | <img src="chars-orig/char-apl-10x20-38.png"> | 7x7   | 10x20+2+8 |
| char-apl-10x20-39.png | <img src="chars-orig/char-apl-10x20-39.png"> | 8x7   | 10x20+1+7 |
| char-apl-10x20-3A.png | <img src="chars-orig/char-apl-10x20-3A.png"> | 8x5   | 10x20+1+9 |
| char-apl-10x20-3B.png | <img src="chars-orig/char-apl-10x20-3B.png"> | 8x5   | 10x20+1+9 |
| char-apl-10x20-3C.png | <img src="chars-orig/char-apl-10x20-3C.png"> | 9x7   | 10x20+1+7 |
| char-apl-10x20-3D.png | <img src="chars-orig/char-apl-10x20-3D.png"> | 9x9   | 10x20+1+6 |
| char-apl-10x20-3E.png | <img src="chars-orig/char-apl-10x20-3E.png"> | 9x7   | 10x20+1+7 |
| char-apl-10x20-3F.png | <img src="chars-orig/char-apl-10x20-3F.png"> | 8x11  | 10x20+1+5 |
| char-apl-10x20-40.png | <img src="chars-orig/char-apl-10x20-40.png"> | 9x9   | 10x20+1+6 |
| char-apl-10x20-41.png | <img src="chars-orig/char-apl-10x20-41.png"> | 9x9   | 10x20+1+6 |
| char-apl-10x20-42.png | <img src="chars-orig/char-apl-10x20-42.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-43.png | <img src="chars-orig/char-apl-10x20-43.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-44.png | <img src="chars-orig/char-apl-10x20-44.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-45.png | <img src="chars-orig/char-apl-10x20-45.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-46.png | <img src="chars-orig/char-apl-10x20-46.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-47.png | <img src="chars-orig/char-apl-10x20-47.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-48.png | <img src="chars-orig/char-apl-10x20-48.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-49.png | <img src="chars-orig/char-apl-10x20-49.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-4A.png | <img src="chars-orig/char-apl-10x20-4A.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-4B.png | <img src="chars-orig/char-apl-10x20-4B.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-4C.png | <img src="chars-orig/char-apl-10x20-4C.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-4D.png | <img src="chars-orig/char-apl-10x20-4D.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-4E.png | <img src="chars-orig/char-apl-10x20-4E.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-4F.png | <img src="chars-orig/char-apl-10x20-4F.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-50.png | <img src="chars-orig/char-apl-10x20-50.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-51.png | <img src="chars-orig/char-apl-10x20-51.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-52.png | <img src="chars-orig/char-apl-10x20-52.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-53.png | <img src="chars-orig/char-apl-10x20-53.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-54.png | <img src="chars-orig/char-apl-10x20-54.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-55.png | <img src="chars-orig/char-apl-10x20-55.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-56.png | <img src="chars-orig/char-apl-10x20-56.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-57.png | <img src="chars-orig/char-apl-10x20-57.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-58.png | <img src="chars-orig/char-apl-10x20-58.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-59.png | <img src="chars-orig/char-apl-10x20-59.png"> | 9x13  | 10x20+1+3 |
| char-apl-10x20-5A.png | <img src="chars-orig/char-apl-10x20-5A.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-5B.png | <img src="chars-orig/char-apl-10x20-5B.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-5C.png | <img src="chars-orig/char-apl-10x20-5C.png"> | 8x13  | 10x20+1+3 |
| char-apl-10x20-5D.png | <img src="chars-orig/char-apl-10x20-5D.png"> | 7x7   | 10x20+2+8 |
| char-apl-10x20-5E.png | <img src="chars-orig/char-apl-10x20-5E.png"> | 8x8   | 10x20+1+7 |
| char-apl-10x20-5F.png | <img src="chars-orig/char-apl-10x20-5F.png"> | 8x8   | 10x20+1+7 |
| char-apl-10x20-60.png | <img src="chars-orig/char-apl-10x20-60.png"> | 8x8   | 10x20+1+7 |
| char-apl-10x20-61.png | <img src="chars-orig/char-apl-10x20-61.png"> | 8x11  | 10x20+1+4 |
| char-apl-10x20-62.png | <img src="chars-orig/char-apl-10x20-62.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-63.png | <img src="chars-orig/char-apl-10x20-63.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-64.png | <img src="chars-orig/char-apl-10x20-64.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-65.png | <img src="chars-orig/char-apl-10x20-65.png"> | 9x11  | 10x20+1+4 |
| char-apl-10x20-66.png | <img src="chars-orig/char-apl-10x20-66.png"> | 8x17  | 10x20+1+1 |
| char-apl-10x20-67.png | <img src="chars-orig/char-apl-10x20-67.png"> | 8x17  | 10x20+1+1 |
| char-apl-10x20-68.png | <img src="chars-orig/char-apl-10x20-68.png"> | 9x13  | 10x20+1+2 |
| char-apl-10x20-69.png | <img src="chars-orig/char-apl-10x20-69.png"> | 8x11  | 10x20+1+3 |
| char-apl-10x20-6A.png | <img src="chars-orig/char-apl-10x20-6A.png"> | 8x11  | 10x20+1+3 |
| char-apl-10x20-6B.png | <img src="chars-orig/char-apl-10x20-6B.png"> | 9x6   | 10x20+1+7 |
| char-apl-10x20-6C.png | <img src="chars-orig/char-apl-10x20-6C.png"> | 8x17  | 10x20+1+1 |
| char-apl-10x20-6D.png | <img src="chars-orig/char-apl-10x20-6D.png"> | 8x14  | 10x20+1+3 |
| char-apl-10x20-6E.png | <img src="chars-orig/char-apl-10x20-6E.png"> | 8x6   | 10x20+1+7 |
| char-apl-10x20-6F.png | <img src="chars-orig/char-apl-10x20-6F.png"> | 8x8   | 10x20+1+9 |
| char-apl-10x20-70.png | <img src="chars-orig/char-apl-10x20-70.png"> | 8x14  | 10x20+1+3 |
| char-apl-10x20-71.png | <img src="chars-orig/char-apl-10x20-71.png"> | 8x14  | 10x20+1+3 |
| char-apl-10x20-72.png | <img src="chars-orig/char-apl-10x20-72.png"> | 8x7   | 10x20+1+9 |
| char-apl-10x20-73.png | <img src="chars-orig/char-apl-10x20-73.png"> | 8x7   | 10x20+1+9 |
| char-apl-10x20-74.png | <img src="chars-orig/char-apl-10x20-74.png"> | 6x10  | 10x20+2+7 |
| char-apl-10x20-75.png | <img src="chars-orig/char-apl-10x20-75.png"> | 8x10  | 10x20+1+5 |
| char-apl-10x20-76.png | <img src="chars-orig/char-apl-10x20-76.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-77.png | <img src="chars-orig/char-apl-10x20-77.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-78.png | <img src="chars-orig/char-apl-10x20-78.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-79.png | <img src="chars-orig/char-apl-10x20-79.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-7A.png | <img src="chars-orig/char-apl-10x20-7A.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-7B.png | <img src="chars-orig/char-apl-10x20-7B.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-7C.png | <img src="chars-orig/char-apl-10x20-7C.png"> | 5x14  | 10x20+3+3 |
| char-apl-10x20-7D.png | <img src="chars-orig/char-apl-10x20-7D.png"> | 10x14 | 10x20+0+3 |
| char-apl-10x20-7E.png | <img src="chars-orig/char-apl-10x20-7E.png"> | 5x14  | 10x20+3+3 |

</details>



Other than
the alphabet, which was copied from the VT340's actual font, every
glyph should be examined. However, the work can be narrowed down to
these typographical sins crying out to heaven for justice:

* Worst offenders:
<ul>
5F, 60, 6B, 6C, 6D, 6E, 34
</ul>

* Could be better: 
<ul>
5D, 5E, 30, 72, 73, 3A, 3B<br/>
61..65, 32, 31, 3C, 3E, 40
</ul>



[montage]: ../../../charset/uplineload/apl-montage.png "Note how symbols such as 6B are squashed"
