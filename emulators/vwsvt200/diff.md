# Comparison of VWS ReGIS VT200 to the VT340

VWS was one of the early graphical interfaces for VAXen. It came with
a terminal emulator called "ReGIS VT200 Series Terminal" which appears
to have been a predecessor to the VT340. 

## Features they share

Particularly focusing on features that were not in the VT240 or that
have not been replicated in modern terminal emulators. 

* Colormap is shared between ReGIS, Sixel, and terminal text.
  * Colormap can be changed by ReGIS or Sixel
  * Color 0 is background, 7 is foreground (check this)
* Sixel graphics
* ReGIS graphics
  * Locator (mouse) input

## Features which are slightly different

* The VT340 can display 16 simultaneous colors from a palette of 4096,
  whereas the VWS VT200 can display 256 colors from a palette of
  either 2, 16, or 256 colors.
* The VT340's default [[colormap]] is quite a bit easier on the eyes
  as it takes advantage of its 12-bit color depth. The VWS VT200 uses
  the classic "angry fruit salad" colors of older computers (VT240?).
* The VT340 displays bold text using color index 15 in its colormap.
  The VWS VT200 uses a bold font with color index 7, the same color
  used for normal text. 

## Features unique to the VT340

There seem to be many features which the VT340 added. These are just
the ones hackerb9 considers notable.

### VT Level 3 
* Status line
* ISO Latin1 character set
* MediaCopy (sixel screenshot to host)
* "Terminal state interrogation (describes what state your terminal is in)"

### ReGIS commands
* S(H) - Hard Copy Control 

## Features unique to VWS VT200

* DEC Locator 
* VWS has a menu to let one print a portion of the screen by selecting
  a rectangle with the mouse.


## Yet to check

* Blink text looks to be the same colormap index as on VT340. Yes?
