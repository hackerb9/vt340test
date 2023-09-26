# DECterm

DECterm (aka `dxterm`) is DEC's VT340 emulator for Unix/X and
VMS/DECwindows. It does sixel and ReGIS graphics, but with
limitations.

* Not to be confused with **dtterm**, which was a later terminal
  emulator that lacked VT340 emulation.

* DECterm can emulate Japanese features (in VT382-J mode) that were
  not present in the VT340. 
  
* In VT382-J mode, the DECterm's Primary Device Attributes are
  generated as follows:

	    CSI ? 63 ; 1 ; 2 ; 4 ; 5 ; 6 ; 7 ; 8 ; 10 ; 15 ; 43 c

  This is almost exactly the same as the VT382 DA report, with the
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

* Unlike a VT340, DECterm supports the Japanese VT382 extension for
  ruled lines. (Primary device attribute extension #43). See section
	  4.2 of [Writing Software for the International Market](https://www.cs.auckland.ac.nz/references/unix/digital/AQ0R4CTE/DOCU_006.HTM),

* Despite the attributes shown above, DECterm does suppport ReGIS
  graphics, just without Command Display mode, Scrolling, or Output
  Cursors. Additionally ReGIS addresses the entire window, not just 24
  rows and 80 columns, so the aspect ratio between text and graphics
  might not always be the same as on the VT330 or VT340 terminal.

* DECterm handles character sets differently from a true VT340:

  * Does NOT emulate the VT340's Downline Loadable Characters ("soft
    fonts"). DECDLD control string is ignored. [See 4.3 below.]

  * Does not use the VT382's method for preloading or on-demand
    loading of Asian characters.

  * Instead, DEC Character Sets are implemented using X.
  
    DECterm software supports only the Standard Character Set (SCS)
	component of DRCS. When DECterm software receives the SCS
	characters, it searches the X window server for the fonts with
	XLFD named as -*-dec-drcs and treats them as a soft character set.
	The software ignores the DECDLD control string sent by the
	terminal programming application.

  * Sidenote: DEC didn't have to go that route. 

    * See [“RLogin”](http://nanno.dip.jp/softlib/man/rlogin/) for a
      terminal that does support DECDLD.

    * See [drcsterm](https://pypi.org/project/drcsterm/) for a filter
      that converts UCS Private Area (Plain 16) to Dynamically
      Redefined Charater Sets via ISO-2022 designation sequences.

      * Mapping Rule

      	DRCSTerm uses UCS 16 Plane (U+100000-U+10FFFF). If output
		character stream includes characters in this range, such as;

		U+10*XXYY* ( 0x40 <= 0x*XX* <=0x7E, 0x20 <= 0x*YY* <= 0x7F )

    	DRCSTerm converts them into the ISO-2022 Designation Format:

		`ESC` `(` `SP` <\x*XX*> <\x*YY*> `ESC` `(` `B`


      
* See also, [hackerb9's extracts](decterm.intl.txt) from 
  [Writing Software for the International Market](../../docs/kindred/vt382/Writing\ International.pdf) from the Digital UNIX documentation Library, March 1996.
