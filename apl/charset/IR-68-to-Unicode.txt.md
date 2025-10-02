# Notes on Unicode's mapping table from APL

This document refers to [Unicode's IR-68-to-Unicode.txt][Uni68]
mapping table, last changed in 2020. [IR-68][IR68] is the pre-Unicode
standard for encoding of APL characters.

[Uni68]: https://www.unicode.org/Public/MAPPINGS/VENDORS/MISC/APL-ISO-IR-68.TXT "Unicode's old IR-68 mapping, 2020-07-17 22:58:00 GMT."

There appear to be some mistakes in Unicode's chart.

## 1. `_` + `A`  = ?

The [IR-68][IR68] standard gives examples of characters composed
using backspace (0x08) that should be "imaged so as to be clearly
recognizable". One of those is underscored alphabetics:

<ul>

0x460861: `_` + `𝐴` → `𝐴̲`<br/>
&nbsp;&nbsp;to<br/>
0x46087A: `_` + `𝑍` → `𝑍̲`.

</ul>

Those IR-68 codes are notably missing from Unicode's IR-68 mapping
file. This may be because of uncertainty about what it should map to.
Unicode, of course, does not contain underscored letters as separate
characters.

The modern [consensus][consensus] of the APL community is that
underscored letters were merely a way to differentiate lower and
uppercase alphabets given the mechanical limitations of the IBM
selectric type ball. But, should an underscore indicate a letter is
small or capital?

The IR-68-to-Unicode.txt file maps non-underscored to capital letters:
APL's `𝐴` at IR-68 0x61 → Unicode U+0041 `A`.

```
0x61    	0x0041	#	LATIN CAPITAL LETTER A
```

Therefore, underscored letters must be lowercase: `_` + `𝐴` → U+0061 `a`.

```
0x460861	0x0061	#	LATIN SMALL LETTER A
0x610846	0x0061	#	LATIN SMALL LETTER A
```

[IR68]: https://github.com/hackerb9/vt340test/blob/main/docs/standards/IR068-APL.pdf "APL Character Set encoding standard, 1983-06-01"
[consensus]: https://www.math.uwaterloo.ca/~ljdickey/apl-rep/tables "Working Draft of an unpublished standard for APL, 2000"

## 2. Incorrect IR-68 sequences

The IR-68-to-Unicode file also lists incorrect IR-68 sequences for
some characters:

### QUAD DOWNWARDS ARROW

#### Original
```
IR-68       UNICODE
-----       -------
0x46084B	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW (incorrect)
0x4B0846	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW (incorrect)
0x46084B	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
0x4B0846	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
```

In IR-68 UNDERBAR is 46 and SINGLE QUOTE is 4B, so the mapping to Quad
Downwards Arrow is mistaken. That character would be composed in IR-68
of QUAD (4C) and DOWN ARROW (55), but that sequence (0x4C0855,
0x55084C) is missing. Corrected, it would be:

#### Fixed
```
0x4C0855	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW
0x55084C	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW
0x46084B	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
0x4B0846	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
```

### QUAD EQUAL

#### Original
```
    IR-68 	UNICODE
    -----	-------
    0x4C082A	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL (incorrect)
    0x2A084C	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL (incorrect)
    0x4C082A	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
    0x2A084C	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
```

IR-68 character 2A is NOT EQUALS, the correct entry should be 25 for EQUALS.

#### Fixed
```
    0x4C0825	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL
    0x25084C	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL
    0x4C082A	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
    0x2A084C	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
```

## Download fixed version

Hackerb9's version of [IR-68-to-Unicode.txt](IR-68-to-Unicode.txt)
contains the fixes mentioned above.
