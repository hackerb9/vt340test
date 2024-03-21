# DECterm

DECterm (aka `dxterm`) is DEC's VT340 emulator for Unix/X and
VMS/DECwindows. It does sixel and ReGIS graphics, but with
limitations.

* Not to be confused with **dtterm**, which was a later terminal
  emulator that lacked VT340 emulation.

* DECterm can emulate Japanese features (in VT382-J mode) that were
  not present in the VT340. 
  
* DECterm does not allow the VT340's soft fonts nor the VT382's
  on-demand loading of Asian characters.

## Device Attributes
  
* In VT382-J mode, the DECterm's Primary Device Attributes are
  generated as follows:

	    CSI ? 63 ; 1 ; 2 ; 4 ; 5 ; 6 ; 7 ; 8 ; 10 ; 15 ; 43 c

  This is almost exactly the same as the [VT382](../docs/kindred/EK-VT382-RM-001_Kanji_Display_Terminal_Programmer_Reference_Manual.pdf) DA report, with the
  addition of extension number "43" (ruled lines), which the VT382-J
  does support despite not advertising it.

* On paper, a DECterm compares moderately well with an actual VT340,
  which reports the following Device Attributes:
  
		CSI ? 63 ; 1 ; 2 ; 3 ; 4 ; 6 ; 7 ; 8 ; 9; 13 ; 15 ; 18; 19 c
	
* Comparison of features
	
   | Psn | Extension           | VT340 only | DECterm/VT382 only |
   |-----|---------------------|------------|--------------------|
   | 1   | 132 columns         |            |                    |
   | 2   | printer port        |            |                    |
   | 3   | ReGIS graphics      | X          |                    |
   | 4   | sixel graphics      |            |                    |
   | 5   | Katakana            |            | X                  |
   | 6   | selective erase     |            |                    |
   | 7   | soft character set  |            |                    |
   | 8   | user-defined keys   |            |                    |
   | 9   | NRC sets            | X          |                    |
   | 10  | two-byte Kanji      |            | X                  |
   | 13  | local editing mode  | X          |                    |
   | 15  | DEC technical set   |            |                    |
   | 16  | locator device port | X          |                    |
   | 18  | user windows        | X          |                    |
   | 19  | dual sessions       | X          |                    |
   | 43  | ruled line drawing  |            | X                  |

## Graphics differences

* Unlike a VT340, DECterm supports the Japanese VT382 extension for
  ruled lines. (Primary device attribute extension #43). See section
	  4.2 of [Writing Software for the International Market](https://www.cs.auckland.ac.nz/references/unix/digital/AQ0R4CTE/DOCU_006.HTM),

* Despite the attributes shown above, DECterm does suppport ReGIS
  graphics, somewhat.
  
  * DECterm lacks the VT340's ReGIS Command Display mode, Scrolling,
  and Output Cursors.
  
  * DECterm's ReGIS addresses the entire window, not just 24 rows and
  80 columns. The DECterm documentation mentions that this will throw
  the aspect ratio off between text and graphics. Presumably, this
  refers to ReGIS's graphical text, not the more ordinary character
  cell text, which could never be safely mixed with ReGIS graphics.
  (To mix graphics and character cell text, one should use sixel, not
  ReGIS).

* The extant documentation for DECterm does not detail the sixel
  behavior. Hackerb9 suspects that it differs from a VT340's
  implementation at least in terms of color registers and the sixel
  palette when multiple images are displayed. Additionally, it is
  unclear if the sixel canvas is limited to 800x480, as it is on the
  VT340, or if it is allowed to change with the window size, as modern
  terminal emulators do. 
  
## Character Sets

* DECterm handles character sets differently from a true VT340:

  * Does NOT emulate the VT340's Downline Loadable Characters ("soft
    fonts"). **DECDLD** control string is ignored.

  * Does not use the VT382's method for preloading or on-demand
    loading of Asian characters.

  * Instead, DEC Character Sets are implemented using X.
  
	<blockquote>	
    DECterm software supports only the Standard Character Set (SCS)
	component of DRCS. When DECterm software receives the SCS
	characters, it searches the X window server for the fonts with
	XLFD named as `-*-dec-drcs` and treats them as a soft character set.
	The software ignores the **DECDLD** control string sent by the
	terminal programming application.
	</blockquote>

  * Sidenote: DEC didn't have to go that route. 

    * See [“RLogin”](http://nanno.dip.jp/softlib/man/rlogin/) for a
      terminal emulator that does support **DECDLD** soft fonts.

    * See [drcsterm](https://pypi.org/project/drcsterm/) for a filter
      that converts UCS Private Area (Plane 16) to Dynamically
      Redefined Charater Sets via ISO-2022 designation sequences.

      * Mapping Rule

      	DRCSTerm uses UCS Plane 16 (U+100000-U+10FFFF). If output
		character stream includes characters in this range, such as;

		U+10*XXYY* ( 0x40 <= 0x*XX* <=0x7E, 0x20 <= 0x*YY* <= 0x7F )

    	DRCSTerm converts them into the ISO-2022 Designation Format:

		`ESC` `(` `SP` <\x*XX*> <\x*YY*> `ESC` `(` `B`

* See also, [hackerb9's extracts](decterm.intl.txt) from 
  [Writing Software for the International Market](../docs/kindred/VT382/Writing%20International.pdf) from the Digital UNIX documentation Library, March 1996.

* http://vt100.net/dec/vt320/soft_characters

## Fonts and ReGIS

Apparently DECterm's ReGIS graphics were not aligned quite right by
default. The fix was to use the font from VWS VT200 emulator,
available in the [vwsvtfont/](vwsvtfont/) as .pcf (X Portable Compiled
Format) font files. Despite being called a "VT200" font, these seem to
be more suited to the VT340 as the font bounding box is 10x20 (for the
files that end in "19") or 20x40 (for the files ending in "38"). The
VT220's font was only 8x10.

