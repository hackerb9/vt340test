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

% This is useful with iconv to convert to and from the DEC's peculiar
% 8-bit encoding for the APL character set. Does not (yet) work
% interactively. See bottom of file for comments.

CHARMAP
<U0000>     /x00         NULL
<U0001>     /x01         START OF HEADING
<U0002>     /x02         START OF TEXT
<U0003>     /x03         END OF TEXT
<U0004>     /x04         END OF TRANSMISSION
<U0005>     /x05         ENQUIRY
<U0006>     /x06         ACKNOWLEDGE
<U0007>     /x07         BELL
<U0008>     /x08         BACKSPACE
<U0009>     /x09         HORIZONTAL TABULATION
<U000A>     /x0a         LINE FEED
<U000B>     /x0b         VERTICAL TABULATION
<U000C>     /x0c         FORM FEED
<U000D>     /x0d         CARRIAGE RETURN
<U000E>     /x0e         SHIFT OUT
<U000F>     /x0f         SHIFT IN
<U0010>     /x10         DATA LINK ESCAPE
<U0011>     /x11         DEVICE CONTROL ONE
<U0012>     /x12         DEVICE CONTROL TWO
<U0013>     /x13         DEVICE CONTROL THREE
<U0014>     /x14         DEVICE CONTROL FOUR
<U0015>     /x15         NEGATIVE ACKNOWLEDGE
<U0016>     /x16         SYNCHRONOUS IDLE
<U0017>     /x17         END OF TRANSMISSION BLOCK
<U0018>     /x18         CANCEL
<U0019>     /x19         END OF MEDIUM
<U001A>     /x1a         SUBSTITUTE
<U001B>     /x1b         ESCAPE
<U001C>     /x1c         FILE SEPARATOR
<U001D>     /x1d         GROUP SEPARATOR
<U001E>     /x1e         RECORD SEPARATOR
<U001F>     /x1f         UNIT SEPARATOR
<U0020>     /x20         SPACE
<U0021>     /x21         Shriek
<U0022>     /x22         QUOTATION MARK
<U0023>     /x23         NUMBER SIGN
<U0024>     /x24         DOLLAR SIGN
<U0025>     /x25         PERCENT SIGN
<U0026>     /x26         AMPERSAND
<U0027>     /x27         APOSTROPHE
<U0028>     /x28         LEFT PARENTHESIS
<U0029>     /x29         RIGHT PARENTHESIS
<U002A>     /x2a         Star
<U002B>     /x2b         Plus
<U002C>     /x2c         COMMA
<U002D>     /x2d         Minus
<U002E>     /x2e         Dot
<U002F>     /x2f         Slash
<U0030>     /x30         DIGIT ZERO
<U0031>     /x31         DIGIT ONE
<U0032>     /x32         DIGIT TWO
<U0033>     /x33         DIGIT THREE
<U0034>     /x34         DIGIT FOUR
<U0035>     /x35         DIGIT FIVE
<U0036>     /x36         DIGIT SIX
<U0037>     /x37         DIGIT SEVEN
<U0038>     /x38         DIGIT EIGHT
<U0039>     /x39         DIGIT NINE
<U003A>     /x3a         COLON
<U003B>     /x3b         SEMICOLON
<U003C>     /x3c         LESS-THAN SIGN
<U003D>     /x3d         EQUALS SIGN
<U003E>     /x3e         GREATER-THAN SIGN
<U003F>     /x3f         Question MARK
<U0040>     /x40         At
<U0041>     /x41         LATIN CAPITAL LETTER A
<U0042>     /x42         LATIN CAPITAL LETTER B
<U0043>     /x43         LATIN CAPITAL LETTER C
<U0044>     /x44         LATIN CAPITAL LETTER D
<U0045>     /x45         LATIN CAPITAL LETTER E
<U0046>     /x46         LATIN CAPITAL LETTER F
<U0047>     /x47         LATIN CAPITAL LETTER G
<U0048>     /x48         LATIN CAPITAL LETTER H
<U0049>     /x49         LATIN CAPITAL LETTER I
<U004A>     /x4a         LATIN CAPITAL LETTER J
<U004B>     /x4b         LATIN CAPITAL LETTER K
<U004C>     /x4c         LATIN CAPITAL LETTER L
<U004D>     /x4d         LATIN CAPITAL LETTER M
<U004E>     /x4e         LATIN CAPITAL LETTER N
<U004F>     /x4f         LATIN CAPITAL LETTER O
<U0050>     /x50         LATIN CAPITAL LETTER P
<U0051>     /x51         LATIN CAPITAL LETTER Q
<U0052>     /x52         LATIN CAPITAL LETTER R
<U0053>     /x53         LATIN CAPITAL LETTER S
<U0054>     /x54         LATIN CAPITAL LETTER T
<U0055>     /x55         LATIN CAPITAL LETTER U
<U0056>     /x56         LATIN CAPITAL LETTER V
<U0057>     /x57         LATIN CAPITAL LETTER W
<U0058>     /x58         LATIN CAPITAL LETTER X
<U0059>     /x59         LATIN CAPITAL LETTER Y
<U005A>     /x5a         LATIN CAPITAL LETTER Z
<U005B>     /x5b         LEFT SQUARE BRACKET
<U005C>     /x5c         Slope
<U005D>     /x5d         RIGHT SQUARE BRACKET
<U005E>     /x5e         CIRCUMFLEX ACCENT
<U005F>     /x5f         LOW LINE
<U0060>     /x60         GRAVE ACCENT
<U0061>     /x61         LATIN SMALL LETTER A
<U0062>     /x62         LATIN SMALL LETTER B
<U0063>     /x63         LATIN SMALL LETTER C
<U0064>     /x64         LATIN SMALL LETTER D
<U0065>     /x65         LATIN SMALL LETTER E
<U0066>     /x66         LATIN SMALL LETTER F
<U0067>     /x67         LATIN SMALL LETTER G
<U0068>     /x68         LATIN SMALL LETTER H
<U0069>     /x69         LATIN SMALL LETTER I
<U006A>     /x6a         LATIN SMALL LETTER J
<U006B>     /x6b         LATIN SMALL LETTER K
<U006C>     /x6c         LATIN SMALL LETTER L
<U006D>     /x6d         LATIN SMALL LETTER M
<U006E>     /x6e         LATIN SMALL LETTER N
<U006F>     /x6f         LATIN SMALL LETTER O
<U0070>     /x70         LATIN SMALL LETTER P
<U0071>     /x71         LATIN SMALL LETTER Q
<U0072>     /x72         LATIN SMALL LETTER R
<U0073>     /x73         LATIN SMALL LETTER S
<U0074>     /x74         LATIN SMALL LETTER T
<U0075>     /x75         LATIN SMALL LETTER U
<U0076>     /x76         LATIN SMALL LETTER V
<U0077>     /x77         LATIN SMALL LETTER W
<U0078>     /x78         LATIN SMALL LETTER X
<U0079>     /x79         LATIN SMALL LETTER Y
<U007A>     /x7a         LATIN SMALL LETTER Z
<U007B>     /x7b         LEFT CURLY BRACKET
<U007C>     /x7c         VERTICAL LINE
<U007D>     /x7d         RIGHT CURLY BRACKET
<U007E>     /x7e         TILDE
<U007F>     /x7f         DELETE
<U0080>     /x80         PADDING CHARACTER (PAD)
<U0081>     /x81         HIGH OCTET PRESET (HOP)
<U0082>     /x82         BREAK PERMITTED HERE (BPH)
<U0083>     /x83         NO BREAK HERE (NBH)
<U0084>     /x84         INDEX (IND)
<U0085>     /x85         NEXT LINE (NEL)
<U0086>     /x86         START OF SELECTED AREA (SSA)
<U0087>     /x87         END OF SELECTED AREA (ESA)
<U0088>     /x88         CHARACTER TABULATION SET (HTS)
<U0089>     /x89         CHARACTER TABULATION WITH JUSTIFICATION (HTJ)
<U008A>     /x8a         LINE TABULATION SET (VTS)
<U008B>     /x8b         PARTIAL LINE FORWARD (PLD)
<U008C>     /x8c         PARTIAL LINE BACKWARD (PLU)
<U008D>     /x8d         REVERSE LINE FEED (RI)
<U008E>     /x8e         SINGLE-SHIFT TWO (SS2)
<U008F>     /x8f         SINGLE-SHIFT THREE (SS3)
<U0090>     /x90         DEVICE CONTROL STRING (DCS)
<U0091>     /x91         PRIVATE USE ONE (PU1)
<U0092>     /x92         PRIVATE USE TWO (PU2)
<U0093>     /x93         SET TRANSMIT STATE (STS)
<U0094>     /x94         CANCEL CHARACTER (CCH)
<U0095>     /x95         MESSAGE WAITING (MW)
<U0096>     /x96         START OF GUARDED AREA (SPA)
<U0097>     /x97         END OF GUARDED AREA (EPA)
<U0098>     /x98         START OF STRING (SOS)
<U0099>     /x99         SINGLE GRAPHIC CHARACTER INTRODUCER (SGCI)
<U009A>     /x9a         SINGLE CHARACTER INTRODUCER (SCI)
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
<U2207>     /xae         Del
<U2206>     /xaf         Delta
<U2373>     /xb0         Iota
<U2218>     /xb1         Jot
<U2395>     /xb2         Quad
<U22A4>     /xb3         Down Tack
<U25CB>     /xb4         Circle
<U2374>     /xb5         Rho
<U2308>     /xb6         Upstile
<U2193>     /xb7         Down Arrow
<U222A>     /xb8         Union
<U2375>     /xb9         Omega
<U2283>     /xba         Right shoe
<U2282>     /xbb         Left shoe
<U2190>     /xbc         Gets
<U22A2>     /xbd         Right Tack
<U2192>     /xbe         Goto
<U2265>     /xbf         Greater than or Equal to
<U22C4>     /xc0         Diamond
<U22A3>     /xc1         Left Tack
<U2359>     /xc2         Delta Underbar
% Is this how modern APL emits the underscore characters?
% Mathematical Italic Capital letters (+ combining low line (U+0332))?
<U1D434>    /xc3         A - Alphabet is not right, should have underscore
<U1D435>    /xc4         B
<U1D436>    /xc5         C
<U1D437>    /xc6         D
<U1D438>    /xc7         E
<U1D439>    /xc8         F
<U1D43A>    /xc9         G
<U1D43B>    /xca         H
<U1D43C>    /xcb         I
<U1D43D>    /xcc         J
<U1D43E>    /xcd         K
<U1D43F>    /xce         L
<U1D440>    /xcf         M
<U1D441>    /xd0         N
<U1D442>    /xd1         O
<U1D443>    /xd2         P
<U1D444>    /xd3         Q
<U1D445>    /xd4         R
<U1D446>    /xd5         S
<U1D447>    /xd6         T
<U1D448>    /xd7         U
<U1D449>    /xd8         V
<U1D44A>    /xd9         W
<U1D44B>    /xda         X
<U1D44C>    /xdb         Y
<U1D44D>    /xdc         Z
<U235D>     /xdd         Lamp
<U2336>     /xde         I-Beam
<U234E>     /xdf         Hydrant
<U2355>     /xe0         Thorn
<U2339>     /xe1         Domino
<U2347>     /xe2         Quad Left Arrow
<U2348>     /xe3         Quad Right Arrow
<U235E>     /xe4         Quote Quad
<U234C>     /xe5         Quad Down Caret
<U234B>     /xe6         Grade Up
<U2352>     /xe7         Grade Down
<U236B>     /xe8         Del Tilde
<U2371>     /xe9         Nor
<U2372>     /xea         Nand
<U235F>     /xeb         Log
<U2296>     /xec         Circle Bar
<U2349>     /xed         Transpose
<U233D>     /xee         Circle Stile
<U236A>     /xef         Comma Bar
<U233F>     /xf0         Slash Bar
<U2340>     /xf1         Slope Bar
<U2286>     /xf2         Left Shoe Underbar
<U2287>     /xf3         Right Shoe Underbar
<U2261>     /xf4         Equal Underbar
<U2191>     /xf5         Up Arrow
<U2337>     /xf6         Squad
<U2337>     /xf7         Squad
<U2337>     /xf8         Squad
<U2337>     /xf9         Squad
<U2337>     /xfa         Squad
<U2337>     /xfb         Squad
<U2337>     /xfc         Squad
% Did /xfd, the APL OUT character, never get added to Unicode? It is
% specified in IBM's APL Codepage, so this isn't just some random
% thing DEC added.
<U2404>     /xfd         OUT - no matching unicode, substituting EOT
<U2337>     /xfe         Squad
<UFFFD>     /xff         (Undefined)
END CHARMAP

% Characters mentioned in Dyalog's help manual but not
% available in DEC's VT340 font.
%   ≢    U+2262  Equal Underbar Slash (NOT IDENTICAL TO)
%   ⍷    U+2377  Epsilon Underbar
%   ⍸    U+2378  Iota Underbar
%   ⍬    U+236C  Zilde
%   ⍨    U+2368  Tilde Diaeresis
%   ⍣    U+2363  Star Diaeresis
%   ⍠    U+2360  Variant
%   ⌸	U+2338	Quad Equal
%   ⌺	U+233A	Quad Diamond
%   ⍤	U+2364	Jot Diaeresis
%   ⍥	U+2365  Circle Diaeresis

% See:
% http://help.dyalog.com/latest/index.htm#Language/Introduction/Language%20Elements.htm


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Example: converting from DEC's APL to Unicode UTF16
%
%     # NB: the slash is important to iconv to know this is a charmap file!
%     echo -n $'\xe1' | iconv -f ./charmap.apl -t UTF16BE | hd
%
%     (Output shows U+2339 is correctly emitted when input is 0xE1).
%
% Example: converting from UTF-8 to DEC's APL
%
%     echo -n $'\xe2\x8c\xb9' | iconv -f utf-8 -t ./charmap.apl | hd
%
%     (Output shows that 0xE1 is correctly emitted).
% 
% Example: Transforming a file which is in the DEC APL codeset into
% something visible on modern machines.
%
%     iconv -f ./charmap.apl <SOMEANCIENTVAXFILE.APL >freshnewfile.apl
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reminder to self from hackerb9: 
% charmap files do not do what I think they ought to do.
% 
% They can be used to convert files, but a charmap file is NOT what is
% needed to show APL on a VT340 when running a version of apl that
% outputs Unicode. For that, I'll need to build a gconv module, which
% is much ickier.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: One _could_ compile this into the system locale definitions
% and set LANG=en_US.APL, but there is no point until the matching
% gconv module exists. Many programs would abort, with errors like,
% "iconv: conversion to APL//TRANSLIT is not supported". Some versions
% of Python will even dump core.

% Nevertheless, for future reference, here is how it is done:
%
%   mkdir -p foo/usr/lib/locale/
%   localedef -f decapl.charmap -i en_US --no-archive --prefix=foo en_US.decapl
% 
% Test it out, by setting the LOCPATH and LANG/LC_ALL environment variables:
%
%    LOCPATH=`pwd`/foo/usr/lib/locale/ LC_ALL=en_US.decapl  locale  charmap
%
% To install in the system directory, remove the --prefix option.

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

The benefit of compiling with localedef is that (theoretically) the
charmap can be used interactively (by setting LANG) instead of having
to run `iconv`.

Note: Whie one _could_ compile this into the system locale definitions
and set LANG=en_US.DECAPL, there is no point until the matching gconv
module exists. Many programs would abort, with errors like, "iconv:
conversion to APL//TRANSLIT is not supported". Some versions of Python
will even dump core. 

This page does not document how to create a gconv module.
Nevertheless, for future reference, here is how it is done:

<details>

  mkdir -p foo/usr/lib/locale/
  localedef -f decapl.charmap -i en_US --no-archive --prefix=foo en_US.decapl

Test it out, by setting the LOCPATH and LANG/LC_ALL environment variables:

   LOCPATH=`pwd`/foo/usr/lib/locale/ LC_ALL=en_US.decapl  locale  charmap

To install in the system directory, remove the --prefix option.

</details>
