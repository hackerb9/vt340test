## Documentation Errata

This is a page for accruing the errors I've found in the manuals.

### EK-VT3XX-GP-002

DEC VT330/340 Graphics Programming, second edition

* DECSDM reversed regarding sixel scrolling.

  On hackerb9's vt340:
  - When DECSDM is set (`Esc` `[?80h`), sixel scrolling is disabled. 
  - When DECSDM is reset (`Esc` `[?80l`), sixel scrolling is enabled.

* DECLBD "Ky1" is merely the first Ky, not an identifier. Also,
  indentation for Pc is incorrect.


### EK-VT3XX-TP-002

DEC VT330/340 Text Programming, second edition

* DECRPSS response to DECRQSS query is inverted

  VT340 manual states that 0 = host's request is valid, 1 = invalid.
  However, the way the VT340 actually works is the opposite. (See
  @j4james's test in #13).

  On hackerb9's vt340, a valid query for SGR returns 1:
  ```
  $ printf '\eP$qm\e\\'; read -rd '\'; echo
  ^[P1$r0m^[\
  ```

  An invalid query returns 0:
  ```
  $ printf '\eP$qx\e\\'; read -rd '\'; echo
  ^[P0$r^[\
  ```

* DECSTGLT (Select Text/Graphics Look-up Table) is terminated with a
  left curly brace, not right.

  The escape sequence for DECSTGLT that works on a VT340 is:

  |       |      |   |    |
  |:------|:-----|:--|:---|
  |**CSI**|**Ps**| ) | {  |
  |  9/11 |  3/? |2/9|7/11|

  @j4james points out in issue #12 that the manual incorrectly lists
  it as right curly brace, but does give the correct code point
  underneath. 

* DECSSDT (Select status line type) default should be 0, not 1.

  |       |      |   |    |
  |:------|:-----|:--|:---|
  |**CSI**|**Ps**| $ | ~  |
  |  9/11 |  3/? |2/4|7/14|

  If Ps is omitted, the default on a VT340 is Ps=0 ("No status line").

  The manual lists Ps=1 ("Indicator status line"), but that is
  incorrect. Perhaps they were thinking of the VT340's default
  configuration at power on?

* Page 202: DECXCPR (Extended Cursor Position Report) should include a
  `?` in the response.
  
  **DSR &mdash; Extended Cursor Position Report (DECXCPR)**<br/>
  The host asks the terminal for the current cursor position,
  including the current page number.

  Exchange | Sequence | Meaning
  -|-|-
  Request<br/>(Host to VT300) | <kbd>CSI</kbd><kbd>?</kbd><kbd>6</kbd><kbd>n</kbd> | The host asks for an extended<br/>cursor position report<br/>(DECXCPR).
  DECXCPR response<br/>(VT300 to host) | <span><kbd>CSI</kbd><kbd>?</kbd>**Pl**<kbd>;</kbd>**Pc**<kbd>;</kbd>**Pp**<kbd>R</kbd></span> | The terminal indicates that<br/>the cursor is currently at<br/>line **Pl**, column **Pc**, on page **Pp**.

  [Corrected by @j4james in issue #23).



### EK-VT3XX-HR-002

DEC VT340 Programmer's Quick Reference, 2nd edition.

* Page 41: DECSTGLT (Select Text/Graphics Look-up Table) is terminated
  with a left curly brace (`{`), not right.
  
  It should read:
  
  > **Select Text/Graphics Look-up Table**
  > **DECSTGLT**
  > **CSI Ps ) {**
  >
  > Ps = 0, monochrome color map look-up table.
  > Ps = 1, color-1 color map look-up table.
  > Ps = 2, color-2 color map look-up table.

* Page 43: Response to DECXCPR should have a `?` after CSI. 

  It should read:
  
  > **Report**
  > **DECXCPR**
  > **CSI ? Pl ; Pc ; Pp R**

* Page 53: DECRPSS response to DECRQSS query is inverted. It should
  say that 0 means invalid and 1 means valid.
  
* Page 99: DECSDM descriptions reversed. They should read:

	> **Set: CSI ? 8 0 h**
	> 
	> Disables the Sixel Scrolling feature on the Graphics Set-up
	> screen. Sixel drawing beings at the home position and does not
	> scroll. The text active position is not affected.

    > **Reset: CSI ? 8 0 l** †
	> 
	> Enables the Sixel Scrolling feature on the Graphics Set-up
	> screen. Sixel drawing begins at the text active position and can
	> scroll.
	>
	> † _The last character in the sequence is a lowercase L._

  (I would also add that Reset is the default on the VT340.)

* Page 100: DECLBD "Ky1" is merely the first Ky, not an identifier.
  All instances of Ky1 should be replaced with Ky except the very
  first which is used to indicate that multiple Ky from _Ky1_ to _Kyn_
  are allowed.



