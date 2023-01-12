# Creating automatic Unicode VT340 translation

Should be possible using charmap, genlocale, gconv, etc.

These notes are a bit scattered as I learn more.

* Settings the VT340 to Latin1 and `LANG` to en_US.iso8859-1 gets most
  of what I want.
  
* A few documents suggest that Latin-1 should be loaded into G2, but
  it appears that the VT340 puts it in G1. Is that right?
  
* The VT340 has four slots G0 to G3, to make it easy to swap between
  four different character sets. 
  
* There appear to be only four useful character sets builtin on my
  North American VT340+G2:

  1. US-ASCII
  2. Latin-1
  3. DEC Special Graphics (AKA VT100 box drawing)
  4. DEC Technical Character Set

* Of those, US-ASCII and Latin-1 are already used well by setting the
  LANG environment variable. So, the questions are:
  1. what would be the benefit of enabling the other two?
  2. how would output (UTF8->VT340)  work? charmap? luit? 
  3. how would input work? Can the VT340 input more than just Latin-1?
  4. how do I ensure the correct charsets are loaded before shifting them?

* Also, my VT340 reports having two "Alternate Fonts" that are exactly
  the same as the standard ASCII. Are these the "soft fonts"? Do I
  replace them in firmware?
  
* Each login session can have a different soft font (AKA "DRCS",
  "downloadable replacement character set") which can define 96 new
  characters.
  
