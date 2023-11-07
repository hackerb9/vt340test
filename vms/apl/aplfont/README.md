# The APL soft fonts from DEC and how to use them

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

To load the font into the terminal as G1:

    cat 'APL$VT340_FONT.FNT'
    
To show an APL character on VT340 and modern terminals, use locking shifts:

    LS0=$'\x0F'
    LS1=$'\x0E'
    echo "With UTF-8, Domino is the letter 'a' after 0x0E: ${LS1}a${LS0}"

<details><summary><h3>Alternate method using 8-bit characters</h3></summary>

This works on a VT340 and other Latin-1 terminals, but is not
compatible with modern UTF-8 terminals.
    
    LS1R=$'\x1B\x7E'
    LS2R=$'\x1B\x7D'

	echo ${LS1R} 		# Map GR as G1 (APL)
    echo $'The VT340 can show Domino as character 0xE1: \xe1'
	echo ${LS2R} 		# Map GR as G2 (Default, usually Latin-1 on VT340)

</details>

## Discussion

These files are in [Downline Load (DECDLD) format][DECDLD]. When
`cat`ed to the screen, the terminal loads the font into a buffer as a
Dynamically Redefinable Character Set ("DRCS") with [SCS designator][Dscs] 
`&0`. Because the files end with the byte sequence `ESC` `)` `&` `0`, 
they are automatically loaded as G1 (Graphic Set #1).

[DECDLD]: https://github.com/hackerb9/vt340test/raw/main/docs/EK-PPLV2-PM.B01_Level_2_Sixel_Programming_Reference.pdf#page=114

[Dscs]: https://github.com/hackerb9/vt340test/blob/main/docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf#page=105

### Detailed walkthrough of LS1, LS0

As a reminder, this APL font is used by a program sending **LS1**
(`0x0E`), the APL characters as ASCII, then **LS0** (`0x0F`).

The solution that works for both old and new terminals is to "shift
in" the APL characters to "Graphic Left" (GL) — a fancy term for how
the terminal interprets characters from 0x20 to 0x7F, which is usually
just plain old 7-bit ASCII. Once shifted, ASCII values will display as
APL instead of ASCII text.

As mentioned above, DEC's APL font files load themselves into G1 on
the terminal (Intermediate Graphic Set #1). A program can send Locking
Shift 1 (byte '0x0E') to signal to the terminal that all following
ASCII characters should be displayed using the font in G1. To return
to interpreting ASCII characters normally, a program can send Locking
Shift 0 ('0x0F').

| Name                  | Mnemonic | Hex   | Set the active GL character set to |
|-----------------------|----------|-------|------------------------------------|
| Locking Shift 0       | LS0      | 0F    | the G0 character set.              |
| Locking Shift 1       | LS1      | 0E    | the G1 character set.              |



<details><summary><h3>Discussion on using 8-bit characters</h3></summary>

By default the VT340 uses Intermediate Graphics Set G2 for displaying
"Graphic Right", that is, it looks in G2 for the font to display the
8-bit characters 0xA1 to 0xFE. (Usually, G2 holds the Latin-1 font.)

Modern Unicode terminals cannot use Graphic Right to display alternate
glyphs because bytes with the high-bit set are reserved for UTF-8
sequences. However, a non-Unicode terminal like the VT340 have the
option to access APL characters more efficiently by using 8-bit
characters. This saves on the bytes sent every time a program wants to
switch between 7-bit characters being interpreted as ASCII or APL.
Since a program will often want to show both, it is plausible that
20th century programmers would have chosen to simply load the APL font
into GR and only switch it out if one wanted to use characters from
the Latin-1 _répertoire_.

Of course, now that UTF-8 is the standard for terminals, there is no
point in using Graphic Right for this kind of optimization. 

However, if you wish to do it, the key is to simply use the "Right"
versions of the Locking shift. In particular, shift in G1 to GR using
**LS1R**. From then on, ASCII characters can be used as normal and APL
can be shown any time using 8-bit characters. See
[DECAPL](../aplfontb9/DECAPL.md) for a full character map.

To reset the terminal to the default, use **LS2R** to shift G2 to GR.
That will once again allow access to Latin-1 characters. 

| Name                  | Mnemonic | Hex   | Set the active GR character set to |
|-----------------------|----------|-------|------------------------------------|
| Locking Shift 1 Right | LS1R     | 1B 7E | the G1 character set.              |
| Locking Shift 2 Right | LS2R     | 1B 7D | the G2 character set.              |

</details>



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


<ol><sub>
	Note 1: G0 is the default Graphic Set which is
	not necessarily but almost invariably 
	just the normal ASCII glyphs.
</sub></ol>

<ol><sub>
	Note 2: one must use a "locking shift" 
 	instead of a "single shift" because
	the standards committees somehow omitted SS1 
	(single shift G1 to GL) from the ANSI
	standard for terminals. [Could they have
	believed it was superfluous since G1 was
	trivially displayable using GR at the time?]
</sub></ol>

<ol><sub> 
	Note 3: Technically, the default for G2 on a VT340 is "MCS",
	the DEC Multilingual Character Set. However, since it is so
 	similar to the much better known Latin-1, I just call it "Latin-1".
    Additionally, anyone who uses a VT340 in modern times
    probably has configured it to genuine Latin-1. (I certainly recommend
	doing that.)
</sub></ol>

