## Documentation Errata

This is a page for accruing the errors I've found in the manuals.

### EK-VT3XX-GP-002

DEC VT330/340 Graphics Programming, second edition

* DECSDM reversed regarding sixel scrolling.

  On hackerb9's vt340, when DECSDM is set (`Esc` `[?80h`), sixel scrolling is
  disabled. When DECSDM is reset (`Esc` `[?80l`), sixel scrolling is enabled.

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
  $ printf '\eP$qm\e\\'; read -rd '/'; echo
  ^[P1$r0m^[\
  ```

  An invalid query returns 0:
  ```
  $ printf '\eP$qx\e\\'; read -rd '/'; echo
  ^[P0$r^[\
  ```

* DECSTGLT should be left curly brace, not right.

  The escape sequence for DECSTGLT that works on a VT340 is:

  |       |      |   |    |
  |:------|:-----|:--|:---|
  |**CSI**|**Ps**| ) | {  |
  |  9/11 |  3/? |2/9|7/11|

  @j4james points out in issue #12 that the manual incorrectly lists
  it as right curly brace, but does give the correct code point
  underneath. A right curly brace is ignored by the VT340.

### EK-VT3XX-TP-001

First edition of text programming. There is a newer version of this
manual which may not have these errors, but it has not yet been
checked.

* DECSSDT: Select Status Line Type incorrectly uses a hyphen as the
  terminating character instead of a tilde. The manual should read:

>> |       |      |   |    |
>> |:------|:-----|:--|:---|
>> |**CSI**|**Ps**| $ | ~  |
>> |  9/11 |  3/? |2/4|7/14|

> Also the default if Ps is omitted is **0** (no status line), not
> **1** (indicator status line).



  