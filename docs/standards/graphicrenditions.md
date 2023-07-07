# Table of "ANSI" SGR Graphic Renditions

This table is adapted from section 8.3.117 of the
[ECMA-48](docs/standards/ECMA-48_1991.pdf) (1991) standard
(colloquially known as "The ANSI Standard") , with notes on whether
the VT340 supports each mode or not. As a bonus, [ISO
8613-6](ITU-T.416-1993.pdf)'s direct color setting is discussed at the
end.

See also: [VT340 Text Coding Standards](README.md).

## SGR - SELECT GRAPHIC RENDITION

SGR is used to establish one or more graphic rendition aspects for
subsequent text. The established aspects remain in effect until the
next occurrence of SGR in the data stream. Each graphic rendition
aspect is specified by a parameter value: 0 default rendition
(implementation-defined), cancels the effect of any preceding
occurrence of SGR in the data stream.

NOTE: The usable combinations of parameter values are determined by
the implementation.


| CSI  | Ps  | ;    | Ps  | ... | m    |
|------|-----|------|-----|-----|------|
| 9/11 | 3/? | 3/11 | 3/? | ... | 6/13 |

Parameter default value: Ps = 0

| Ps | Attribute                                                                                                                                         | VT100? | VT340? | XTerm(383)    | Ps |
|----|---------------------------------------------------------------------------------------------------------------------------------------------------|--------|--------|---------------|----|
| 0  | all attributes off                                                                                                                                | y      | Y      | y             | 0  |
| 1  | bold or increased intensity                                                                                                                       | y      | Y      | y             | 1  |
| 2  | faint, decreased intensity or second colour                                                                                                       |        |        | y             | 2  |
| 3  | italicized                                                                                                                                        |        |        | y             | 3  |
| 4  | singly underlined                                                                                                                                 | y      | Y      | y             | 4  |
| 5  | slowly blinking (less then 150 per minute)                                                                                                        | y      | Y      | y             | 5  |
| 6  | rapidly blinking (150 per minute or more)                                                                                                         |        |        | (slow blink)  | 6  |
| 7  | negative image                                                                                                                                    | y      | Y      | y             | 7  |
| 8  | concealed characters                                                                                                                              |        | Y      | y             | 8  |
| 9  | crossed-out (characters still legible but marked as to be deleted)                                                                                |        |        | y             | 9  |
| 10 | primary (default) font                                                                                                                            |        |        |               | 10 |
| 11 | first alternative font                                                                                                                            |        |        |               | 11 |
| 12 | second alternative font                                                                                                                           |        |        |               | 12 |
| 13 | third alternative font                                                                                                                            |        |        |               | 13 |
| 14 | fourth alternative font                                                                                                                           |        |        |               | 14 |
| 15 | fifth alternative font                                                                                                                            |        |        |               | 15 |
| 16 | sixth alternative font                                                                                                                            |        |        |               | 16 |
| 17 | seventh alternative font                                                                                                                          |        |        |               | 17 |
| 18 | eighth alternative font                                                                                                                           |        |        |               | 18 |
| 19 | ninth alternative font                                                                                                                            |        |        |               | 19 |
| 20 | Fraktur (Gothic)                                                                                                                                  |        |        |               | 20 |
| 21 | doubly underlined                                                                                                                                 |        |        | y (thicker)   | 21 |
| 22 | normal colour or normal intensity (neither bold nor faint)                                                                                        |        |        | y             | 22 |
| 23 | not italicized, not fraktur                                                                                                                       |        | Y      | y             | 23 |
| 24 | not underlined (neither singly nor doubly)                                                                                                        |        |        | y             | 24 |
| 25 | steady (not blinking)                                                                                                                             |        | Y      | y             | 25 |
| 26 | (reserved for proportional spacing as specified in CCITT Recommendation T.61)                                                                     |        | Y      |               | 26 |
| 27 | positive image (negative image off)                                                                                                               |        |        | y             | 27 |
| 28 | revealed characters (invisible off)                                                                                                               |        | Y      | y             | 28 |
| 29 | not crossed out                                                                                                                                   |        | Y      | y             | 29 |
| 30 | black display                                                                                                                                     |        |        | y             | 30 |
| 31 | red display                                                                                                                                       |        |        | y             | 31 |
| 32 | green display                                                                                                                                     |        |        | y             | 32 |
| 33 | yellow display                                                                                                                                    |        |        | y             | 33 |
| 34 | blue display                                                                                                                                      |        |        | y             | 34 |
| 35 | magenta display                                                                                                                                   |        |        | y             | 35 |
| 36 | cyan display                                                                                                                                      |        |        | y             | 36 |
| 37 | white display                                                                                                                                     |        |        | y             | 37 |
| 38 | _(reserved for future standardization; intended for setting character foreground colour as specified in ISO 8613-6 [CCITT Recommendation T.416])<sup>†</sup>_ |        |        | y | 38 |
| 39 | default display colour (implementation-defined)                                                                                                   |        |        | y             | 39 |
| 40 | black background                                                                                                                                  |        |        | y             | 40 |
| 41 | red background                                                                                                                                    |        |        | y             | 41 |
| 42 | green background                                                                                                                                  |        |        | y             | 42 |
| 43 | yellow background                                                                                                                                 |        |        | y             | 43 |
| 44 | blue background                                                                                                                                   |        |        | y             | 44 |
| 45 | magenta background                                                                                                                                |        |        | y             | 45 |
| 46 | cyan background                                                                                                                                   |        |        | y             | 46 |
| 47 | white background                                                                                                                                  |        |        | y             | 47 |
| 48 | _(reserved for future standardization; intended for setting character background colour as specified in ISO 8613-6 [CCITT Recommendation T.416])<sup>†</sup>_ |        |        | y | 48 |
| 49 | default background colour (implementation-defined)                                                                                                |        |        | y             | 49 |
| 50 | (reserved for cancelling the effect of the rendering aspect established by parameter value 26)                                                    |        |        |               | 50 |
| 51 | framed                                                                                                                                            |        |        |               | 51 |
| 52 | encircled                                                                                                                                         |        |        |               | 52 |
| 53 | overlined                                                                                                                                         |        |        |               | 53 |
| 54 | not framed, not encircled                                                                                                                         |        |        |               | 54 |
| 55 | not overlined                                                                                                                                     |        |        |               | 55 |
| 56 | (reserved for future standardization)                                                                                                             |        |        |               | 56 |
| 57 | (reserved for future standardization)                                                                                                             |        |        |               | 57 |
| 58 | (reserved for future standardization)                                                                                                             |        |        |               | 58 |
| 59 | (reserved for future standardization)                                                                                                             |        |        |               | 59 |
| 60 | ideogram underline or right side line                                                                                                             |        |        |               | 60 |
| 61 | ideogram double underline or double line on the right side                                                                                        |        |        |               | 61 |
| 62 | ideogram overline or left side line                                                                                                               |        |        |               | 62 |
| 63 | ideogram double overline or double line on the left side                                                                                          |        |        |               | 63 |
| 64 | ideogram stress marking                                                                                                                           |        |        |               | 64 |
| 65 | cancels the effect of the rendition aspects established by parameter values 60 to 64                                                              |        |        |               | 65 |

<sup>† See the next section for 8613-6 Direct Color.</sup>

______________________________________________________________________

# ISO 8613-6: Direct Color Selection

Although the VT340 does not support ISO 8613-6 Direct Color -- until
someone hacks the firmware, anyhow -- it is interesting to see how it
was envisioned to work. The ISO 8613-6 document which is referenced by
ECMA-48 is behind a paywall, so instead I used the exactly identical
(but no cost) [ITU-T Rec T.416](ITU-T.416-1993.pdf). It is actually
quite an interesting read. First published in 1988, at the heyday of
the VT340, it gives a glimpse of the possibility for text terminals,
using ANSI escape sequences, to break out of their rigid "character
cells" and move into properly typeset text. It even had a special
control code for parallel text, like Kanji and Kana, a feature which,
35 years later, is still difficult to do in an interchangeable way.

The 1993 update is the version which added the Direct Color support
mentioned in ECMA-48's discussion of SGR. Here is what it has to say:


</blockquote>

The parameter values 38 and 48 are followed by a parameter substring
used to select either the character foreground “colour value” or the
character background “colour value”.

A parameter substring for values 38 or 48 may be divided by one or
more separators (03/10) into parameter elements, denoted as Pe. The
format of such a parameter sub-string is indicated as:

| Pe        | :     | P2            | :     | P3            | :     | P4            | :     | P5            | :     | P6            | :     | P7         |
|-----------|-------|---------------|-------|---------------|-------|---------------|-------|---------------|-------|---------------|-------|------------|
| 3/0 - 3/5 | 3/10  | 3/0 - 3/9 ... | 3/10  | 3/0 - 3/9 ... | 3/10  | 3/0 - 3/9 ... | 3/10  | 3/0 - 3/9 ... | 3/10  | 3/0 - 3/9 ... | 3/10  | 3/0 or 3/1 |
| **0**     |       |               |       |               |       |               |       |               |       |               |       |            |
| **1**     |       |               |       |               |       |               |       |               |       |               |       |            |
| **2**     | **:** | Colour Space  | **:** | Red           | **:** | Green         | **:** | Blue          | **:** |               | **:** | Tolerance  |
| **3**     | **:** | Colour Space  | **:** | Cyan          | **:** | Magenta       | **:** | Yellow        | **:** |               | **:** | Tolerance  |
| **4**     | **:** | Colour Space  | **:** | Cyan          | **:** | Magenta       | **:** | Yellow        | **:** | Black         | **:** | Tolerance  |
| **5**     |       | Colour Index  |       |               |       |               |       |               |       |               |       |            |

Each parameter element consists of zero, one or more bit combinations
from 03/00 to 03/09, representing the digits 0 to 9. An empty
parameter element represents a default value for this parameter
element. Empty parameter elements at the end of the parameter
substring need not be included.

The first parameter element indicates a choice between:

| Pe | Meaning                                                                      |
|----|------------------------------------------------------------------------------|
| 0  | implementation defined (only applicable for the character foreground colour) |
| 1  | transparent;                                                                 |
| 2  | direct colour in RGB space;                                                  |
| 3  | direct colour in CMY space;                                                  |
| 4  | direct colour in CMYK space;                                                 |
| 5  | indexed colour.                                                              |

If the first parameter has the value 0 or 1, there are no additional
parameter elements.

If the first parameter element has the value 5, then there is a second
parameter element specifying the index into the colour table given by
the attribute “content colour table” applying to the object with which
the content is associated.

If the first parameter element has the value 2, 3, or 4, the second
parameter element specifies a colour space identifier referring to a
colour space definition in the document profile.

If the first parameter element has the value 2 [RGB], the parameter elements
3, 4, and 5, are three integers for red, green, and blue colour
components. Parameter 6 has no meaning.

If the first parameter has the value 3 [CMY], the parameter elements
3, 4, and 5 and three integers for cyan, magenta, and yellow colour
components. Parameter 6 has no meaning.

If the first parameter has the value 4 [CMYK], the parameter elements
3, 4, 5, and 6, are four integers for cyan, magenta, yellow, and black
colour components.

If the first parameter element has the value 2, 3, or 4, the parameter
element 7 may be used to specify a tolerance value (an integer) and
the parameter element 8 may be used to specify a colour space
associated with the tolerance (0 for CIELUV, 1 for CIELAB).

<sub>_NOTE 3 – The “colour space id” component will refer to the applicable
colour space description in the document profile which may contain
colour scaling data that describe the scale and offset to be applied
to the specified colour components in the character content.
Appropriate use of scaling and offsets may be required to map all
colour values required into the integer encoding space provided. This
may be particularly important if concatenated content requires the
insertion of such SGR sequences by the content layout process._</sub>
</blockquote>
















