The Compose key on the DEC LK-201, LK-401 keyboards is pressed
sequentially with two other keys to input Latin-1 characters such as £
(<kbd>Compose</kbd><kbd>L</kbd><kbd>-</kbd>) and ¶(<kbd>Compose</kbd><kbd>P</kbd><kbd>!</kbd>).

It *cannot* be used while held down as <kbd>Meta</kbd>.

======================================================================

Newsgroups: comp.sys.dec
Path: cs.utk.edu!stc06.CTD.ORNL.GOV!fnnews.fnal.gov!uwm.edu
      !math.ohio-state.edu!howland.reston.ans.net!agate!news.Stanford.EDU
      !unixhub!sldb6.slac.stanford.edu!fairfield
Message-ID: <1995Feb19.230712.1@sldb6.slac.stanford.edu>
Sender: news@unixhub.SLAC.Stanford.EDU
Organization: Stanford Linear Accelerator Center
References: <3i2qnj$83p@cpcw16.uea.ac.uk>
Date: Mon, 20 Feb 1995 07:07:12 GMT
From: fairfield@sldb6.slac.stanford.edu
Subject: Re: Compose key on DEC LK401 keyboard on an Alpha 3000

In article <3i2qnj$83p@cpcw16.uea.ac.uk>,
   zebra@cpcw16.uea.ac.uk (Julii Brainard#) writes:
>
> I know that people have posted messages about this before, and I have
> even saved a few, but there seems to be no authoritative guide for
> how to use the compose key on an Alpha 3000 with an LK401 keyboard
> to create all of those weird and wacky symbols and characters --
> just a few of which may be useful in my work.
[...]

        I haven't seen this topic come up very often and it's not in any
    FAQ (that I know of).  The fact  is, it seems very difficult to find
    this  information; usually, I expect, it's in the User's manual that
    _may_ have come with the hardware (terminal), but it's  not  in  the
    VMS user's manuals, or even the I/O Reference Guide, etc.  Note that
    the  compose  sequences  are  common  to  all  VTxxx  terminals (and
    DECterms) from the VT200_Series on  up.   [I  guess that means LK201
    and LK401 keyboards, etc.]

        I _finally_ found the  compose  sequences in the Bookreader docs
    for  VXT1200  X-terminals, Table 15-4.  I've reformatted the  table,
    and omitted some  of  the  compose  sequences  for  characters  that
    normally appear on a US keyboard (e.g., <COMPOSE> + + for the number
    sign,  #).   Also,  I've omitted the dozen or so characters that you
    can only access if you're using  the  ISO Latin 1 character set; the
    sequences  I've listed are for the DEC Multinational character  set,
    although most of these are also available in ISO Latin 1.

        -Ken
--
 Kenneth H. Fairfield       |  Internet: Fairfield@Slac.Stanford.Edu
 SLAC, P.O.Box 4349, MS 98  |  DECnet:   45537::FAIRFIELD (45537=SLACVX)
 Stanford, CA   94309       |  Voice:    415-926-2924    FAX: 415-926-4335
 -------------------------------------------------------------------------
 These opinions are mine, not SLAC's, Stanford's, nor the DOE's...

===============================================================================
Note: Most sequences can also typed in reverse order, but a few must
      be typed in the order given.

| Character | Name                   | Compose Sequence                                     |        | Character | Name                  | Compose Sequence          |
|----------:|------------------------|------------------------------------------------------|--------|----------:|-----------------------|---------------------------|
|         « | opening angle brackets | <kbd>&lt;</kbd><kbd>&lt;</kbd>                       |        |         » | closing angle brakets | <kbd>></kbd><kbd>></kbd>  |
|         ¡ | inverted !             | <kbd>!</kbd><kbd>!</kbd>                             |        |         ° | degree sign           | <kbd>0</kbd><kbd>^</kbd>  |
|         ¿ | inverted ?             | <kbd>?</kbd><kbd>?</kbd>                             |        |         ¹ | superscript 1         | <kbd>1</kbd><kbd>^</kbd>  |
|         ¢ | cent sign              | <kbd>C</kbd><kbd>/</kbd> or <kbd>C</kbd><kbd>\       | </kbd> |         ² | superscript 2         | <kbd>2</kbd><kbd>^</kbd>  |
|         £ | pound sterling sign    | <kbd>L</kbd><kbd>-</kbd> or <kbd>L</kbd><kbd>=</kbd> |        |         ³ | superscript 3         | <kbd>3</kbd><kbd>^</kbd>  |
|         ¥ | yen sign               | <kbd>Y</kbd><kbd>-</kbd> or <kbd>Y</kbd><kbd>=</kbd> |        |         · | middle dot            | <kbd>.</kbd><kbd>^</kbd>  |
|         § | section sign           | <kbd>S</kbd><kbd>O</kbd> or <kbd>S</kbd><kbd>!</kbd> |        |         ¼ | fraction one-quarter  | <kbd>1</kbd><kbd>4</kbd>  |
|         ¤ | currency sign**        | <kbd>X</kbd><kbd>O</kbd>                             |        |         ½ | fraction one-half     | <kbd>1</kbd><kbd>2</kbd>  |
|         © | copyright sign         | <kbd>C</kbd><kbd>O</kbd>                             |        |         ± | plus or minus sign    | <kbd>+</kbd><kbd>-</kbd>  |
|         ª | feminine ordinal       | <kbd>A</kbd><kbd>_</kbd>                             |        |         µ | micro sign            | <kbd>/</kbd><kbd>u</kbd>  |
|         º | masculine ordinal      | <kbd>O</kbd><kbd>_</kbd>                             |        |         ¶ | paragraph sign        | <kbd>P</kbd><kbd>!</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|           |                        |                                                      |        |         ß | German small sharp s  | <kbd>s</kbd><kbd>s</kbd>  |
|         À | A grave                | <kbd>\`</kbd><kbd>A</kbd>                            |        |         à | a grave               | <kbd>\`</kbd><kbd>a</kbd> |
|         Á | A acute                | <kbd>'</kbd><kbd>A</kbd>                             |        |         á | a acute               | <kbd>'</kbd><kbd>a</kbd>  |
|         Â | A circumflex           | <kbd>^</kbd><kbd>A</kbd>                             |        |         â | a circumflex          | <kbd>^</kbd><kbd>a</kbd>  |
|         Ã | A tilde                | <kbd>~</kbd><kbd>A</kbd>                             |        |         ã | a tilde               | <kbd>~</kbd><kbd>a</kbd>  |
|         Ä | A umlaut               | <kbd>"</kbd><kbd>A</kbd>                             |        |         ä | a umlaut              | <kbd>"</kbd><kbd>a</kbd>  |
|         Å | A ring                 | <kbd>*</kbd><kbd>A</kbd>                             |        |         å | a ring                | <kbd>*</kbd><kbd>a</kbd>  |
|         Æ | A E diphthong          | <kbd>A</kbd><kbd>E</kbd>                             |        |         æ | a e diphthong         | <kbd>a</kbd><kbd>e</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Ç | C cedilla              | <kbd>C</kbd><kbd>,</kbd>                             |        |         ç | c cedilla             | <kbd>c</kbd><kbd>,</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         È | E grave                | <kbd>\`</kbd><kbd>E</kbd>                            |        |         è | e grave               | <kbd>\`</kbd><kbd>e</kbd> |
|         É | E acute                | <kbd>'</kbd><kbd>E</kbd>                             |        |         é | e acute               | <kbd>'</kbd><kbd>e</kbd>  |
|         Ê | E circumflex           | <kbd>^</kbd><kbd>E</kbd>                             |        |         ê | e circumflex          | <kbd>^</kbd><kbd>e</kbd>  |
|         Ë | E umlaut               | <kbd>"</kbd><kbd>E</kbd>                             |        |         ë | e umlaut              | <kbd>"</kbd><kbd>e</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Ì | I grave                | <kbd>\`</kbd><kbd>I</kbd>                            |        |         ì | i grave               | <kbd>\`</kbd><kbd>i</kbd> |
|         Í | I acute                | <kbd>'</kbd><kbd>I</kbd>                             |        |         í | i acute               | <kbd>'</kbd><kbd>i</kbd>  |
|         Î | I circumflex           | <kbd>^</kbd><kbd>I</kbd>                             |        |         î | i circumflex          | <kbd>^</kbd><kbd>i</kbd>  |
|         Ï | I umlaut               | <kbd>"</kbd><kbd>I</kbd>                             |        |         ï | i umlaut              | <kbd>"</kbd><kbd>i</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Ñ | N tilde                | <kbd>~</kbd><kbd>N</kbd>                             |        |         ñ | n tilde               | <kbd>~</kbd><kbd>n</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Ò | O grave                | <kbd>\`</kbd><kbd>O</kbd>                            |        |         ò | o grave               | <kbd>\`</kbd><kbd>o</kbd> |
|         Ó | O acute                | <kbd>'</kbd><kbd>O</kbd>                             |        |         ó | o acute               | <kbd>'</kbd><kbd>o</kbd>  |
|         Ô | O circumflex           | <kbd>^</kbd><kbd>O</kbd>                             |        |         ô | o circumflex          | <kbd>^</kbd><kbd>o</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Õ | O tilde                | <kbd>~</kbd><kbd>O</kbd>                             |        |         õ | o tilde               | <kbd>~</kbd><kbd>o</kbd>  |
|         Ö | O umlaut               | <kbd>"</kbd><kbd>O</kbd>                             |        |         ö | o umlaut              | <kbd>"</kbd><kbd>o</kbd>  |
|         Œ | O E diphthong*         | <kbd>O</kbd><kbd>E</kbd>                             |        |         œ | o e diphthong*        | <kbd>o</kbd><kbd>e</kbd>  |
|         Ø | O slash                | <kbd>O</kbd><kbd>/</kbd>                             |        |         ø | o slash               | <kbd>o</kbd><kbd>/</kbd>  |
|           |                        |                                                      |        |           |                       |                           |
|         Ù | U grave                | <kbd>\`</kbd><kbd>U</kbd>                            |        |         ù | u grave               | <kbd>\`</kbd><kbd>u</kbd> |
|         Ú | U acute                | <kbd>'</kbd><kbd>U</kbd>                             |        |         ú | u acute               | <kbd>'</kbd><kbd>u</kbd>  |
|         Û | U circumflex           | <kbd>^</kbd><kbd>U</kbd>                             |        |         û | u circumflex          | <kbd>^</kbd><kbd>u</kbd>  |
|         Ü | U umlaut               | <kbd>"</kbd><kbd>U</kbd>                             |        |         ü | u umlaut              | <kbd>"</kbd><kbd>u</kbd>  |
|         Ÿ | Y umlaut*              | <kbd>"</kbd><kbd>Y</kbd>                             |        |  ý      ÿ | y umlat**             | <kbd>"</kbd><kbd>y</kbd>  |

* **\*** Only available in DEC-MCS
* **\*\*** Available in Latin-1 at a different codepoint

## Does Capital Y Umlaut actually work?

The FAQ lists some glyphs which are not Latin-1 characters. Do they
work on a VT340 in Latin-1 mode? No. They share the same code-point as
Latin-1 glyphs, so they only work in DEC-MCS mode. (Set Up Key ->
General -> User Pref Charset). Hackerb9 recommends using Latin-1 mode
for modern VT340 usage.

### Table of conflicting characters between MCS and Latin-1

The two characters in each row have the same code point. 

| Code | DEC-MCS | Name          | Compose Sequence         |   | Latin-1 | Name           | Compose Sequence         |
|------|--------:|---------------|--------------------------|---|---------|----------------|--------------------------|
| 0xD7 |       Œ | O E diphthong | <kbd>O</kbd><kbd>E</kbd> |   | ×       | Multiplication | <kbd>x</kbd><kbd>x</kbd> |
| 0xF7 |       œ | o e diphthong | <kbd>o</kbd><kbd>e</kbd> |   | ÷       | Division       | <kbd>-</kbd><kbd>:</kbd> |
| 0xDD |       Ÿ | Y umlaut      | <kbd>"</kbd><kbd>Y</kbd> |   | Ý       | Y acute        | <kbd>'</kbd><kbd>Y</kbd> |
| 0xDD |       ÿ | y umlaut      | <kbd>"</kbd><kbd>y</kbd> |   | ý       | y acute        | <kbd>'</kbd><kbd>y</kbd> |
| 0xFF |         | Invalid       |                          |   | ÿ       | y umlaut       | <kbd>"</kbd><kbd>y</kbd> |
| 0xA8 |       ¤ | Currency sign | <kbd>X</kbd><kbd>O</kbd> |   | ¨       | Diaeresis      | <kbd>"</kbd><kbd>"</kbd> |
| 0xA4 |         | Undefined     |                          |   | ¤       | Currency sign  | <kbd>X</kbd><kbd>O</kbd> |

Sidenote: Character 0xFF (y umlaut) is invalid when the VT340 is set
to MCS and the glyph will be omitted instead of being substituted with
the backwards question mark (DEC replacement character).


## Latin-1 VT340 compose keys not found in Shufford's DEC FAQ

| Code | Character | Name            | Compose Sequence                 |
|------|----------:|-----------------|----------------------------------|
| a0   |       " " | No-break space  | <kbd>Space</kbd><kbd>Space</kbd> |
| a6   |         ¦ | Broken pipe     | <kbd>Pipe</kbd><kbd>Pipe</kbd>   |
| a8   |         ¨ | Diaeresis       | <kbd>"</kbd><kbd>"</kbd>         |
| ac   |         ¬ | Not             | <kbd>-</kbd><kbd>,</kbd>         |
| ad   |         ­ | Soft hyphen     | <kbd>-</kbd><kbd>-</kbd>         |
| ae   |         ® | Registered      | <kbd>R</kbd><kbd>O</kbd>         |
| af   |         ¯ | Macron          | <kbd>^</kbd><kbd>-</kbd>         |
| b4   |         ´ | Acute accent    | <kbd>'</kbd><kbd>'</kbd>         |
| b8   |         ¸ | Cedilla         | <kbd>,</kbd><kbd>,</kbd>         |
| be   |         ¾ | Three quarters  | <kbd>3</kbd><kbd>4</kbd>         |
| d0   |         Ð | Icelandic Eth   | <kbd>-</kbd><kbd>D</kbd>         |
| d7   |         × | Multiplication  | <kbd>x</kbd><kbd>x</kbd>         |
| dd   |         Ý | Y acute         | <kbd>'</kbd><kbd>Y</kbd>         |
| de   |         Þ | Icelandic Thorn | <kbd>T</kbd><kbd>H</kbd>         |
| f0   |         ð | Icelandic eth   | <kbd>-</kbd><kbd>d</kbd>         |
| f7   |         ÷ | Division        | <kbd>-</kbd><kbd>:</kbd>         |
| fd   |         ý | y acute         | <kbd>'</kbd><kbd>y</kbd>         |
| fe   |         þ | Icelandic thorn | <kbd>t</kbd><kbd>h</kbd>         |
| ff   |         ÿ | y umlaut        | <kbd>"</kbd><kbd>y</kbd>         |

## X11 compose is very similar

X11 uses a near superset of the compose key sequences on the VT340. To
use it, one just needs to assign a key to be "Compose" (e.g.,
`setxkbmap -option compose:rctrl`). See the file
[/usr/share/X11/locale/en_US.UTF-8/Compose](compose-x11-utf-8.txt) for
all possible compose sequences. Also see
[/usr/share/X11/locale/iso8859-1/Compose](compose-x11-latin-1.txt) for
a much shorter list of keys which more closely fits with the VT340.

### Compose keys from X11 Compose

| DEC | HEX | OCT | CHAR | NAME                | X11 Compose                       |                                        |
|-----|-----|-----|:----:|---------------------|-----------------------------------|----------------------------------------|
| 160 | a0  | 240 |      | Non-breakable space | <kbd>space</kbd><kbd>space</kbd>  |                                        |
| 166 | a6  | 246 | ¦    | Broken bar          | <kbd>!</kbd><kbd>^</kbd>          |                                        |
| 168 | a8  | 250 | ¨    | Diaeresis           | <kbd>"</kbd><kbd>"</kbd>          |                                        |
| 172 | ac  | 254 | ¬    | Not                 | <kbd>-</kbd><kbd>,</kbd>          |                                        |
| 173 | ad  | 255 | ­    | Soft hyphen         | <kbd>-</kbd><kbd>-</kbd>          |                                        |
| 175 | af  | 257 | ¯    | Macron              | <kbd>^</kbd><kbd>-</kbd>          | X11 adds a <kbd>space</kbd> at the end |
| 180 | b4  | 264 | ´    | Acute accent        | <kbd>'</kbd><kbd>'</kbd>          |                                        |
| 208 | d0  | 320 | Ð    | Icelandic Eth       | <kbd>-</kbd><kbd>D</kbd>          | X11 specifies ~ instead of -           |
| 215 | d7  | 327 | ×    | Multiply            | <kbd>x</kbd><kbd>x</kbd>          |                                        |
| 221 | dd  | 335 | Ý    | Y-acute             | <kbd>'</kbd><kbd>Y</kbd>          |                                        |
| 222 | de  | 336 | Þ    | Icelandic Thorn     | <kbd>T</kbd><kbd>H</kbd>          | X11 uses ~ T                           |
| 240 | f0  | 360 | ð    | Icelandic eth       | <kbd>-</kbd><kbd>d</kbd>          | X11 uses ~ instead of -                |
| 247 | f7  | 367 | ÷    | Divide              | <kbd>-</kbd><kbd>:</kbd>          |                                        |
| 253 | fd  | 375 | ý    | y-acute             | <kbd>'</kbd><kbd>y</kbd>          |                                        |
| 254 | fe  | 376 | þ    | Icelandic thorn     | <kbd>t</kbd><kbd>h</kbd>          | X11 uses ~ t                           |


### Redundant ASCII

The Compose key on the VT340 (and in X11) allows one to type some
ASCII characters that may be difficult to access on some keyboards.
Since they merely replace keys that exist on the US keyboard, they
were not listed in Shufford's DEC keyboard FAQ.

| Character | Name                 | Compose Sequence         |
|----------:|----------------------|--------------------------|
|         { | Left curly brace     | <kbd>-</kbd><kbd>(</kbd> |
|         } | Right curly brace    | <kbd>)</kbd><kbd>-</kbd> |
|         [ | Left square bracket  | <kbd>(</kbd><kbd>(</kbd> |
|         ] | Right square bracket | <kbd>)</kbd><kbd>)</kbd> |
|         # | Number sign          | <kbd>+</kbd><kbd>+</kbd> |
|        \\ | Backslash            | <kbd>/</kbd><kbd>/</kbd> |
|      Pipe | Pipe symbol          | <kbd>/</kbd><kbd>^</kbd> |

## Aliases available in X11, missing on VT340

These additional sequences are listed as aliasses in X11. Do they also
work on the VT340? Nope. Just use the standard sequences.

| character | Name   | X11 Compose Alias        | Standard Compose         |
|----------:|--------|--------------------------|--------------------------|
|         ° | Degree | <kbd>o</kbd><kbd>o</kbd> | <kbd>0</kbd><kbd>^</kbd> |
|         µ | Micro  | <kbd>m</kbd><kbd>u</kbd> | <kbd>/</kbd><kbd>u</kbd> |

### X11 UTF-8 Compose

X11 changes the meaning of some compose sequences when
LANG=en_US.utf-8 (versus LANG=en_US.iso8859-1).

#### feminine and masculine ordinals

In X11's UTF-8 encoding, \_a is ā (a with macron) and \_o is ō (o with
macron). Instead X11 requires ^\_a and ^\_o for ª and º

#### Degree and superscript zero
In X11, ^0 is ⁰ (superscript zero), use oo for degree.<br/>

#### Many Unicode Characters not possible on VT340

With a Unicode locale, the Compose key in X11 has a much wider
repertoire. Do not expect the VT340 to be able to do sequences like:

| Char | Name  | Compose sequence            |
|------|-------|-----------------------------|
| ⌣    | Smile | <kbd>:</kbd><kbd>)</kbd>    |
| ♥    | Heart | <kbd>&lt;</kbd><kbd>)3/kbd> |

However, DEC APL does somehow allow redefining the compose keys so as
to make unusal glyphs. This has been tested with the VWS terminal
emulator, but needs to be tested with a VT340.
