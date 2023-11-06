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

<ul><i>

<sup><sub>Duplicates: The [install file](../saveset/A/kitinstal.com) copies the
VT220 80-column font as "VT240" and both the 80- and 132-column VT330
fonts as "VT340". Note that the VT240 has a 132-column font which the
VT220 lacks.</sub></sup>

</i></ul>


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
   (replacing the ASCII characters). An application could send **LS1**,
   the APL characters, then **LS0**.


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

Some of the characters appear squashed. See the commentary on
[hackerb9's modified fonts](../aplfontb9) for details.
