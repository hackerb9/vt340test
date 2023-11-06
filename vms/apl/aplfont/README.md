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

![Montage of DEC's VT340 APL characters][montage]

[montage]: ../../../charset/uplineload/apl-montage.png "Picture enlarged to show detail"

## Usage

To load the font into the terminal (G1 and GR):

    cat 'APL$VT340_FONT.FNT'
    
To show an APL character on a non-unicode terminal:
    
    echo $'The VT340 can show Domino as character 0xE1: \xe1'

Any terminal, unicode or not, can use locking shifts:

    LS0=$'\x0F'
    LS1=$'\x0E'
    echo "With UTF-8, Domino is the letter 'a' after 0x0E: ${LS1}a${LS0}"

## Discussion

These files are in [Downline Load (DECDLD) format][DECDLD]. When
`cat`ed to the screen, the terminal loads the font into a buffer as a
Dynamically Redefinable Character Set ("DRCS") with [SCS designator][Dscs] 
`&0`. Because the files end with the byte sequence `ESC` `)` `&` `0`, 
they are automatically loaded as G1 (Graphic Set #1).

By default the VT340 uses G1 for displaying "Graphic Right", 
that is, it is the font for the 8-bit characters 0xA1 to 0xFE. 
See [DECAPL](../aplfontsb9/DECAPL.md) for the full character map. 

[DECDLD]: https://github.com/hackerb9/vt340test/raw/main/docs/EK-PPLV2-PM.B01_Level_2_Sixel_Programming_Reference.pdf#page=114

[Dscs]: https://github.com/hackerb9/vt340test/blob/main/docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf#page=105

### Problem 0: Squished characters in VT340 version.

Some of the VT340 APL characters appear to be half-height, as if they
had been designed for a VT220 instead of a VT340. See the commentary on
[hackerb9's modified fonts](../aplfontb9#squished-fonts-on-vt340) for details.

### Problem 1: 8-bit control codes in font files

The original FNT files do _not_ work on modern unicode terminals 
because they embed 8-bit control codes for **DCS** and **ST**
which conflict with UTF-8. The solution is to use 7-bit control sequences
that will work on both original and current equipment. You can fix the
files like so:

    sed -i~ $'s#\x90#\eP#; s#\x9c#\e\\#' *.FNT

Or, simply download a fixed version from hackerb9's [modified APL font](../aplfontb9).

### Problem 2: 8-bit codes from a program (GR)

Solution: Program should send **LS1** (`0x0E`), the APL characters, then **LS0** (`0x0F`).

Modern Unicode terminals cannot use Graphic Right 
to display alternate glyphs because bytes with the high-bit
set are reserved for UTF-8 sequences. A solution that works 
for both old and new terminals is to "shift in" the APL characters
so that Graphic Left (GL) — a fancy term for plain old 7-bit ASCII 
— will be displayed as APL. 

As mentioned above, DEC's APL font files load themselves
into G1 on the terminal (Graphic Set #1). A program can send
Locking Shift 1 (byte '0x0E') to signal
to the terminal that any following ASCII characters should
be displayed using the font in G1. To return to
interpreting ASCII characters normally, a program sends
Locking Shift 0 ('0x0F').

<ol><sub>
	Note 1: G0 is the default Graphic Set which is
	not necessarily but almost invariably 
	just the normal ASCII glyphs.<br/><br/>	
	Note 2: one must use a "locking shift" 
 	instead of a "single shift" because
	the committees somehow omitted SS1 
	(single shift G1 to GL) from the ANSI
	standard for terminals. [Could they have
	believed it was superfluous since G1 was
	trivially displayable using GR at the time?]
</sub></ol>


| Name            | Mnemonic | Sequence | Hex   | Function                                                  |
|-----------------|----------|----------|-------|-----------------------------------------------------------|
| Locking Shift 0 | LS0      | \<SI\>   | 0F    | The G0 character set becomes the active GL character set. |
| Locking Shift 1 | LS1      | \<SO\>   | 0E    | The G1 character set becomes the active GL character set. |

