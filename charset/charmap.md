# Creating automatic Unicode VT340 translation

Should be possible using charmap, genlocale, gconv, etc.

These notes are a bit scattered as I learn more.

* The VT340 has four slots G0 to G3, to make it easy to swap between
  four different character sets. 
  
* Setting the User Preferred Character Set to "Latin 1" on the VT340
  causes Latin-1 to be loaded into G2.
  
* Using Latin-1 and setting `LANG` to en_US.iso8859-1 gets most of
  what I want.
  
* There appear to be only four useful character sets builtin on my
  North American VT340+G2:

  1. US-ASCII
  2. Latin-1
  3. DEC Special Graphics (AKA VT100 box drawing)
  4. DEC Technical Character Set

* Of those, US-ASCII and Latin-1 are already used well by setting the
  `LANG` environment variable. So, the questions are:
  1. what would be the benefit of enabling the other two?
  2. how would output (UTF8->VT340)  work? charmap? luit? screen?
  3. how would input work? Can the VT340 input more than just Latin-1?
  4. how do I ensure the correct charsets are loaded before shifting them?

* Also, my VT340 reports having two "Alternate Fonts" that are exactly
  the same as the standard ASCII. Are these the "soft fonts" or can I
  replace them in firmware?
  
* Each login session can have a different soft font (AKA "DRCS",
  "downloadable replacement character set") which can define 96 new
  characters. For example, see the [APL font](../vms/apl/aplfont/README.md).
  If DEC's APL font is representative, then the soft font will be
  loaded into G1. 
