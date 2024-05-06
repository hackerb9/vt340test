# VWSVT font


<img alt="The DEC Technical Character Set in the VWSVT font, enlarged into ASCII art and animated as a video" src="README.md.d/dectech38.webp" align="right">

This bitmap font was included on DEC's Freeware CD for VMS v4.0. It
includes several bitmap terminal fonts that are meant to be used
together to make a single typeface.

The files are in [PCF](pcf) bitmap format with a [BDF](bdf) version
added for convenience. If you want a quick peek at the fonts without
installing them, you can preview them in glorious ASCII art in the
[txt](txt) directory. All of the above are also archived in a single
[ZIP](dxfont_axp_vwsvt0_pcf010.zip) file.

## Installation

You can copy the [pcf](pcf) directory to
/usr/local/share/fonts/vwsvtfont then add the directory to your
system's font search path. For example, for X11, you can use:

```bash
xset fp+ /usr/local/share/fonts/vwsvtfont
xset fp rehash
```

## Usage

You can run the `dir2alias` script in this directory to create the
fonts.alias file and add the directory to the X11 font path.

The fonts.alias file exists to allow for short names, so one can use
"vwsvt0-dblwide19" instead of
"-digital-vwsvt0-medium-r-double*wide--20-190-75-75-c-200-iso8859-1"

Note that some applications will not show the font by default as it is
a bitmap, not scalable. For example, one may need to disable scalable
font rendering in xterm.

```
xterm -fn vwsvt0-19 -xrm 'xterm*renderFont: False'
```

### Fonts in this typeface

* Weight: medium or bold
* Width: narrow, normal, wide, or double-wide
* Height: normal or double-height
* Encoding: Latin-1 or DEC Technical

<br clear=all>

### Mapping filenames to terminal attributes

The filenames map to various states of the terminal: 80 or
132-columns, single or double width, Latin-1 or DEC Special Graphic
&amp; Technical Character Set, and so on. This table will help you to
decode which is which. Click on the name to see an ASCII art preview.

| Filename<BR>vwsvt0-\_\_.txt                                     | SGR1<br>(Blank: Medium) | DECDHL, DECDWL Size<br>(Blank: Single) | DECCOLM<br>(Blank: 80 columns) | Character Set<br>(Blank: Latin-1) | Cell Size |
|-----------------------------------------------------------------|:-----------------------:|----------------------------------------|:------------------------------:|-----------------------------------|:---------:|
| [19](txt/vwsvt0_19.txt)                                         |                         |                                        |                                |                                   | 10x20     |
| [narrow19](txt/vwsvt0_narrow19.txt)                             |                         |                                        | 132                            |                                   | 6x20      |
| [wide19](txt/vwsvt0_wide19.txt)                                 |                         | Single-height, double-width            | 132<sup>†</sup>                |                                   | 12x20     |
| [dblwide19](txt/vwsvt0_dblwide19.txt)                           |                         | Single-height, double-width            |                                |                                   | 20x20     |
| [bold19](txt/vwsvt0_bold19.txt)                                 | Bold                    |                                        |                                |                                   | 10x20     |
| [bold_narrow19](txt/vwsvt0_bold_narrow19.txt)                   | Bold                    |                                        | 132                            |                                   | 6x20      |
| [bold_wide19](txt/vwsvt0_bold_wide19.txt)                       | Bold                    | Single-height, double-width            | 132<sup>†</sup>                |                                   | 12x20     |
| [bold_dblwide19](txt/vwsvt0_bold_dblwide19.txt)                 | Bold                    | Single-height, double-width            |                                |                                   | 20x20     |
|                                                                 |                         |                                        |                                |                                   |           |
| [dectech19](txt/vwsvt0_dectech19.txt)                           |                         |                                        |                                | DEC Gfx, Tech                     | 10x20     |
| [narrow_dectech19](txt/vwsvt0_narrow_dectech19.txt)             |                         |                                        | 132                            | DEC Gfx, Tech                     | 6x20      |
| [wide_dectech19](txt/vwsvt0_wide_dectech19.txt)                 |                         | Single-height, double-width            | 132<sup>†</sup>                | DEC Gfx, Tech                     | 12x20     |
| [dblwide_dectech19](txt/vwsvt0_dblwide_dectech19.txt)           |                         | Single-height, double-width            |                                | DEC Gfx, Tech                     | 20x20     |
| [bold_dectech19](txt/vwsvt0_bold_dectech19.txt)                 | Bold                    |                                        |                                | DEC Gfx, Tech                     | 10x20     |
| [bold_narrow_dectech19](txt/vwsvt0_bold_narrow_dectech19.txt)   | Bold                    |                                        | 132                            | DEC Gfx, Tech                     | 6x20      |
| [bold_wide_dectech19](txt/vwsvt0_bold_wide_dectech19.txt)       | Bold                    | Single-height, double-width            | 132<sup>†</sup>                | DEC Gfx, Tech                     | 12x20     |
| [bold_dblwide_dectech19](txt/vwsvt0_bold_dblwide_dectech19.txt) | Bold                    | Single-height, double-width            |                                | DEC Gfx, Tech                     | 20x20     |
|                                                                 |                         |                                        |                                |                                   |           |
| [38](txt/vwsvt0_38.txt)<sup>‡</sup>                             |                         | Double-height, double-width            |                                |                                   | 20x40     |
| [narrow38](txt/vwsvt0_narrow38.txt)                             |                         | Double-height, double-width            | 132<sup>†</sup>                |                                   | 12x40     |
| [bold38](txt/vwsvt0_bold38.txt)<sup>‡</sup>                     | Bold                    | Double-height, double-width            |                                |                                   | 20x40     |
| [bold_narrow38](txt/vwsvt0_bold_narrow38.txt)                   | Bold                    | Double-height, double-width            | 132<sup>†</sup>                |                                   | 12x40     |
|                                                                 |                         |                                        |                                |                                   |           |
| [dectech38](txt/vwsvt0_dectech38.txt)                           |                         | Double-height, double-width            |                                | DEC Gfx, Tech                     | 20x40     |
| [narrow_dectech38](txt/vwsvt0_narrow_dectech38.txt)             |                         | Double-height, double-width            | 132<sup>†</sup>                | DEC Gfx, Tech                     | 12x40     |
| [bold_dectech38](txt/vwsvt0_bold_dectech38.txt)                 | Bold                    | Double-height, double-width            |                                | DEC Gfx, Tech                     | 20x40     |
| [bold_narrow_dectech38](txt/vwsvt0_bold_narrow_dectech38.txt)   | Bold                    | Double-height, double-width            | 132<sup>†</sup>                | DEC Gfx, Tech                     | 12x40     |


<ul><p>
<sup>†</sup> <i>When DECCOLM is set to "132-column" mode AND double-wide
characters are being shown, the actual number of columns available is 66.
</i></p></ul>

<ul><p> <sup>‡</sup> <i>The filenames vwsvt0-38.pcf and
vwsvt0-bold38.pcf had been switched in the original distribution from
DEC. They have been corrected by hackerb9 in the files available here.
</i></p></ul>

### VT340 Control functions

**SGR1**: Select Graphic Rendition 1 enables bold text on a
terminal: `Esc [ 1 m`. To turn off bold text on the VT340, one uses
SGR22, `Esc [ 22 m`. (Older terminals may require SGR0 to disable all
attributes).

**DECDWL**: Double-Width, Single-Height Line, `Esc # 6`, makes the
entire line the cursor is on display characters at twice their normal
width. Use `Esc # 5` to return to Single-Width, Single Height.

**DECDHL**: Double-Width, Double-Height Line sets a pair of lines to
display characters at twice their size in both width and height. The
line which holds the top half of the characters is set with `Esc # 3`,
the bottom half, `Esc # 4`. Both lines must hold the same characters.

**DECCOLM**: DEC Private Mode 3 sets the column mode. When set low
with `Esc [ ? 3 l`, the terminal is set to 80-column mode. When set
high with `Esc [ ? 3 h`, 132-column mode.

### Character encoding

Encoding is in Latin-1 or "dectech" (for graphics), both of which use
8-bit characters (>128) and are thus incompatible with Unicode. You'll
need to set your shell's encoding to Latin-1 to have them display
correctly — e.g., `export LANG=en_US.iso8859-1`. Not all systems
include Latin-1 support by default. For example, on Debian GNU/Linux,
you'll need to uncomment the line that says `en_US.ISO-8859-1` in the
file /etc/locale.gen and then run `locale-gen`.

Note that the "dectech" fonts include the DEC Special Graphics font in
GL (7-bit ASCII) and the DEC Technical Character Set in GR ("high ASCII").

<img alt="An example of the double-high, double-wide DEC Technical Character Set in the VWSVT font" src="README.md.d/dectech38.png" width=80%>

<details><summary>How one could use this encoding on a VT340</summary>

If one wanted to set up a terminal to use the same character encoding
as this font it could be configured like so:

| Set assignments       | Escape sequence |
|-----------------------|-----------------|
| G0 ⇐ ASCII            | `ESC` `(` `B`   |
| G1 ⇐ TCS              | `ESC` `)` `>`   |
| G2 ⇐ Latin-1          | `ESC` `.` `A`   |
| G3 ⇐ Special Graphics | `ESC` `+` `0`   |

Then, to use the "dectech" encoding, one could do these locking shifts:

| Shift   | Escape sequence | Note                                     |
|---------|-----------------|------------------------------------------|
| GL ⇐ G3 | `ESC` `o`       | 7-bit ASCII range shows Special Graphics |
| GR ⇐ G1 | `ESC` `~`       | "High ASCII" shows TCS                   |

and to switch back to ASCII/Latin-1:

| Shift   | Escape sequence | Note                     |
|---------|-----------------|--------------------------|
| GL ⇐ G0 | `0x0F`          | 7-bit ASCII shows ASCII  |
| GR ⇐ G2 | `ESC` `}`       | High ASCII shows Latin-1 |

See the notes on [the VT340 character sets](../../charset/README.md)
for more information.

</details>

## History

This font was created by DEC and given away as "freeware". DEC
recommended it for use on their VT340 emulator, DECTerm, in order to
have the correct proportions for ReGIS graphics.

These .pcf files were extracted from
[dxfont_axp_vwsvt0_pcf010.a](dxfont_axp_vwsvt0_pcf010.a), which was
downloaded from: https://www.digiater.nl/openvms/freeware/v40/vwsvt/

The .a extension indicates the file is a VMS Backup Saveset archive.
To extract it, hackerb9 used a program called vmsbackup which is
available from: ftp://ftp.process.com/vms-freeware/free-vms/ .

Notable differences of Hackerb9's version from the original: 

* Filenames for 38 and 38-bold are no longer swapped
* Conversion to bdf and txt from the pcf font format
* Includes files fonts.dir and font.alias files for easily using these
  fonts with X11.
* Repackaged as a zip file, [dxfont_axp_vwsvt0_pcf010.zip](dxfont_axp_vwsvt0_pcf010.zip).

## Questions

* Why does the vwsvt font look so different from the actual hardware
  fonts even though it is the correct size to match a VT340?
  
* Is it possible to use its double-width / double-height / 132 column
  fonts with xterm +u8?

* Why does it include characters that are not in Latin-1? I'm guessing
  they are from some National Replacement Character-sets, but on the
  VT340, all [NRC](../../../charset/nrc.md) characters are accounted
  for in Latin-1.
  
	| Codepoint | Glyph | Name        |
	|-----------|-------|-------------|
	| 0x80      | Œ     | OE          |
	| 0x81      | œ     | oe          |
	| 0x82      | Ÿ     | Y diaeresis |

