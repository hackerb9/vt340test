# Notes on Unicode's mapping table from APL

This document refers to b9's [IR-68-to-Unicode.txt](IR-68-to-Unicode.txt)
(2025), a fixed copy of [Unicode's file of the same name][Uni68] (2020).

[Uni68]: https://www.unicode.org/Public/MAPPINGS/VENDORS/MISC/APL-ISO-IR-68.TXT "Unicode's old IR-68 mapping, 2020-07-17 22:58:00 GMT."

Hackerb9 notes that there appear to be some mistakes in Unicode's
chart. 

1. Note 7 of the [IR-68][IR68] standard gives examples of characters
   composed using backspace (0x08) that should be "imaged so as to be
   clearly recognizable". One of those, underscored alphabetics, is
   completely missing from the mapping.

     * 0x460861 to 0x46087A: `_` + `𝐴` to `_` + `𝑍`.

   The modern [consensus][consensus] of the APL community is that
   underscored letters were merely a way to differentiate lower and
   uppercase alphabets given the mechanical limitations of the IBM
   selectric type ball. The IR-68-to-Unicode.txt file already maps
   0x61 to 0x41 (CAPITAL LETTER A), therefore, when composed with
   underscore the alphabet should be rendered as lowercase.

[IR68]: https://github.com/hackerb9/vt340test/blob/main/docs/standards/IR068-APL.pdf "APL Character Set encoding standard, 1983-06-01"
[consensus]: https://www.math.uwaterloo.ca/~ljdickey/apl-rep/tables "Working Draft of an unpublished standard for APL, 2000"

2. The IR-68-to-Unicode file also lists a couple IR-68 characters
twice, which can't be right. While there should be duplicates of the
Unicode characters — composition by backspace overprinting can happen
in either order — every IR-68 sequence should map to a single Unicode
character. The duplicated characters are as follows:

### QUAD DOWNWARDS ARROW

```
IR-68       UNICODE
-----       -------
0x46084B	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW (incorrect)
0x46084B	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
0x4B0846	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW (incorrect)
0x4B0846	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
```

In IR-68 UNDERBAR is 46 and SINGLE QUOTE is 4B, so the mapping to Quad
Downwards Arrow is mistaken. That character would be composed in IR-68
of QUAD (4C) and DOWN ARROW (55), but the chart is missing that entry
(0x4C0855, 0x55084C). Corrected, it would be:

```
0x4C0855	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW
0x46084B	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
0x55084C	0x2357	#	APL FUNCTIONAL SYMBOL QUAD DOWNWARDS ARROW
0x4B0846	0x2358	#	APL FUNCTIONAL SYMBOL QUOTE UNDERBAR
```

### QUAD EQUAL

```
    IR-68 	UNICODE
    -----	-------
#   0x4C082A	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL (incorrect)
    0x4C082A	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
#   0x2A084C	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL (incorrect)
    0x2A084C	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
```

IR-68 character 2A is NOT EQUALS, the correct entry should be 25 for EQUALS.

```
    0x4C0825	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL
    0x4C082A	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
    0x25084C	0x2338	#	APL FUNCTIONAL SYMBOL QUAD EQUAL
    0x2A084C	0x236F	#	APL FUNCTIONAL SYMBOL QUAD NOT EQUAL
```

## Download fixed version

Hackerb9's version of [IR-68-to-Unicode.txt](IR-68-to-Unicode.txt)
contains the fixes mentioned above.
