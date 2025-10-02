# Notes on Unicode's conversion table from APL (IR-68)

This document refers to [IR-68-to-Unicode.txt](IR-68-to-Unicode.txt),
b9's modification of [Unicode's file of the same name][Uni68], dated:
2020-07-17 22:58:00 GMT.

[Uni68]: https://www.unicode.org/Public/MAPPINGS/VENDORS/MISC/APL-ISO-IR-68.TXT "Unicode's old IR-68 mapping, circa 2020"

Hackerb9 notes that there appear to be some mistakes in Unicode's
chart. It is missing some of the characters composed by backspace,
even ones that are specifically listed in the IR-68 standard as
examples of composition. (In particular, underscore, 0x46, with the
capital letters, 0x61 to 0x7A, are valid characters and should map to
_something_ in Unicode.)

Even worse, it lists a few of the IR-68 characters twice, which can't
be right. While there should be duplicates of the Unicode characters
-- composition occurred by backspace overprinting, which can happen in
either order -- every IR-68 sequence should map to a single Unicode
character.


## QUAD DOWNWARDS ARROW

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

## QUAD EQUAL

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


