# Creating automatic Unicode VT340 translation

Should be possible using charmap, genlocale, gconv, etc.

These notes are a bit scattered as I learn more.

## VT340 settings

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

## charmap

A charmap file can be used to convert characters in a Unicode file to
something that can be shown on the VT340. However, it does not seem
that one can use the same file for interactive use; one must instead
compile a gconv module.

### Example charmap file: decapl

Here is an example [charmap file](decapl.charmap)
which converts APL symbols, like ⍋, into a byte, such as 0xE6. It
presumes the VT340 has the APL softfont loaded into Graphic Right,
which is what happens when an 
[APL font file](../vms/apl/aplfontb9/APL_VT340.FNT) is `cat`ed to the
screen. 

<details>

	<code_set_name> DECAPL
	<comment_char> %
	<escape_char> /

	% decapl.charmap: Hackerb9's charmap(5) for APL on the VT340. 
	% alias DEC Vax APL

	CHARMAP
	<U0000>     /x00         NULL
	<U0001>     /x01         START OF HEADING
	<U0002>     /x02         START OF TEXT
	⋱
	<U007C>     /x7c         VERTICAL LINE
	<U007D>     /x7d         RIGHT CURLY BRACKET
	<U007E>     /x7e         TILDE
	<U007F>     /x7f         DELETE
	<U0080>     /x80         PADDING CHARACTER (PAD)
	<U0081>     /x81         HIGH OCTET PRESET (HOP)
	<U0082>     /x82         BREAK PERMITTED HERE (BPH)
	<U0083>     /x83         NO BREAK HERE (NBH)
	⋱
	<U009B>     /x9b         CONTROL SEQUENCE INTRODUCER (CSI)
	<U009C>     /x9c         STRING TERMINATOR (ST)
	<U009D>     /x9d         OPERATING SYSTEM COMMAND (OSC)
	<U009E>     /x9e         PRIVACY MESSAGE (PM)
	<U009F>     /x9f         APPLICATION PROGRAM COMMAND (APC)
	<UFFFD>     /xa0         (Undefined)
	<U00A8>     /xa1         Diaeresis
	<U2264>     /xa2         Less than or Equal to
	<U2228>     /xa3         Or
	<U2227>     /xa4         And
	<U2260>     /xa5         Not Equal To
	<U00F7>     /xa6         Divide
	<U00D7>     /xa7         Times
	<U00AF>     /xa8         High Minus
	<U237A>     /xa9         Alpha
	<U22A5>     /xaa         Up Tack
	<U2229>     /xab         Intersection
	<U230A>     /xac         Downstile
	<U220A>     /xad         Epsilon
	⋱
	<U2404>     /xfd         OUT
	<U2337>     /xfe         Squad
	<UFFFD>     /xff         (Undefined)
	END CHARMAP

</details>

### Charmap Usage

A charmap file can be used by iconv(1) to convert files from one
character set to another as long as it is specified with at least one
slash to indicate it is a filename. (E.g., `./decapl.charmap`).

* Example: converting from DEC's APL to Unicode UTF16

        # NB: the slash is important to iconv to know this is a charmap file!
        echo -n $'\xe1' | iconv -f ./decapl.charmap -t UTF16BE | hd

    (Output shows U+2339 is correctly emitted when input is 0xE1).

* Example: converting from UTF-8 to DEC's APL

        echo -n $'\xe2\x8c\xb9' | iconv -f utf-8 -t ./decapl.charmap | hd

    (Output shows that 0xE1 is correctly emitted).

* Example: Transforming a file which is in the DEC APL codeset into
something visible on modern machines.

        iconv -f ./decapl.charmap <SOMEANCIENTVAXFILE.APL >freshnewfile.apl

## "Compiling" charmap using localedef

Note: One _could_ compile this into the system locale definitions
and set LANG=en_US.DECAPL, but there is no point until the matching
gconv module exists. Many programs would abort, with errors like,
"iconv: conversion to APL//TRANSLIT is not supported". Some versions
of Python will even dump core.

Nevertheless, for future reference, here is how it is done:

<details>

  mkdir -p foo/usr/lib/locale/
  localedef -f decapl.charmap -i en_US --no-archive --prefix=foo en_US.decapl

Test it out, by setting the LOCPATH and LANG/LC_ALL environment variables:

   LOCPATH=`pwd`/foo/usr/lib/locale/ LC_ALL=en_US.decapl  locale  charmap

To install in the system directory, remove the --prefix option.

</details>
