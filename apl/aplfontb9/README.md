# Hackerb9's modification to DEC's APL soft fonts

These are modifications of [the VAX APL fonts](../../vms/apl/aplfont) which
currently have only one change: they use 7-bit escape sequences so
they do not conflict with UTF-8.

| Terminal | 8O-column                                            | 132-column                                                  |
|----------|------------------------------------------------------|-------------------------------------------------------------|
| VT220    | [APL$VT220_FONT](APL$VT220_FONT.FNT)                 | [APL$VT220_FONT](APL$VT220_FONT) (same as 80-column)        |
| VT240    | [APL$VT240_FONT](APL$VT240_FONT.FNT) (same as VT220) | [APL$VT240_FONT_132](APL$VT240_FONT_132.FNT)                |
| VT320    | [APL$VT32O_FONT](APL$VT32O_FONT.FNT)                 | [APL$VT320_FONT_132](APL$VT320_FONT_132.FNT)                |
| VT330    | [APL$VT330_FONT](APL$VT330_FONT.FNT) (same as VT340) | [APL$VT330_FONT_132](APL$VT330_FONT_132.FNT) (same as VT340) |
| VT340    | [APL$VT340_FONT](APL$VT340_FONT.FNT)                 | [APL$VT340_FONT_132](APL$VT340_FONT_132.FNT)                |

Usage is identical to the [original fonts](../../vms/apl/aplfont), except that
these files should also work on modern terminals which support UTF-8
(and VT font loading, of course).

----------------------------------------------------------------------

## Squished fonts on VT340

_Possibly something to fix in the future._

The official fonts from DEC have some suboptimal characters for the
VT340. Apparently, the font designer did not have access to a VT340:
many of the characters would look right on a VT220, which has pixels
that are twice as tall as they are wide. The VT340 has square pixels,
so circles designed for the VT220 appear squashed. Consider, for
example, the logarithm operator, Circled Star at 0x6B.

![Montage of DEC's VT340 APL characters][montage]

In a twist, using the actual VT**2**20 font on a VT340 does not
exhibit that problem. The VT340 knows to double the height of VT220
fonts, so the circles actually are circular. Of course, the tradeoff
in resolution is not worth it; the VT340's matrix is 10x20, while the
VT220's is only 7x10.

At some point, it would be good if someone edited the VT340 APL font
and doubled the height of all glyphs which appear squashed. Hackerb9
has compiled a table with the actual glyph size to help identify which
ones can be simply doubled in height to fix them.

<details><summary>Click to see table of characters with glyph dimensions</summary>

`for f in char-apl-10x20-??.png; do convert $f +trim info:-; done  | column -t -o" | "`
| Hex | Glyph                                        | WxH   | Offset<br/>in 10x20 |
|-----|----------------------------------------------|-------|---------------------|
| 21  | <img src="chars-orig/char-apl-10x20-21.png" width="200%"> | 7x2   | +2+4                |
| 22  | <img src="chars-orig/char-apl-10x20-22.png" width="200%"> | 8x11  | +1+5                |
| 23  | <img src="chars-orig/char-apl-10x20-23.png" width="200%"> | 7x7   | +2+7                |
| 24  | <img src="chars-orig/char-apl-10x20-24.png" width="200%"> | 7x7   | +2+7                |
| 25  | <img src="chars-orig/char-apl-10x20-25.png" width="200%"> | 8x14  | +1+3                |
| 26  | <img src="chars-orig/char-apl-10x20-26.png" width="200%"> | 6x8   | +2+6                |
| 27  | <img src="chars-orig/char-apl-10x20-27.png" width="200%"> | 7x6   | +2+7                |
| 28  | <img src="chars-orig/char-apl-10x20-28.png" width="200%"> | 8x1   | +1+4                |
| 29  | <img src="chars-orig/char-apl-10x20-29.png" width="200%"> | 9x7   | +1+7                |
| 2A  | <img src="chars-orig/char-apl-10x20-2A.png" width="200%"> | 8x8   | +1+7                |
| 2B  | <img src="chars-orig/char-apl-10x20-2B.png" width="200%"> | 7x7   | +2+8                |
| 2C  | <img src="chars-orig/char-apl-10x20-2C.png" width="200%"> | 5x11  | +3+4                |
| 2D  | <img src="chars-orig/char-apl-10x20-2D.png" width="200%"> | 8x7   | +1+7                |
| 2E  | <img src="chars-orig/char-apl-10x20-2E.png" width="200%"> | 9x11  | +1+4                |
| 2F  | <img src="chars-orig/char-apl-10x20-2F.png" width="200%"> | 9x11  | +1+4                |
| 30  | <img src="chars-orig/char-apl-10x20-30.png" width="200%"> | 6x7   | +2+7                |
| 31  | <img src="chars-orig/char-apl-10x20-31.png" width="200%"> | 6x4   | +2+8                |
| 32  | <img src="chars-orig/char-apl-10x20-32.png" width="200%"> | 9x11  | +1+4                |
| 33  | <img src="chars-orig/char-apl-10x20-33.png" width="200%"> | 8x8   | +1+7                |
| 34  | <img src="chars-orig/char-apl-10x20-34.png" width="200%"> | 8x6   | +1+7                |
| 35  | <img src="chars-orig/char-apl-10x20-35.png" width="200%"> | 7x10  | +1+7                |
| 36  | <img src="chars-orig/char-apl-10x20-36.png" width="200%"> | 5x11  | +3+4                |
| 37  | <img src="chars-orig/char-apl-10x20-37.png" width="200%"> | 8x10  | +1+5                |
| 38  | <img src="chars-orig/char-apl-10x20-38.png" width="200%"> | 7x7   | +2+8                |
| 39  | <img src="chars-orig/char-apl-10x20-39.png" width="200%"> | 8x7   | +1+7                |
| 3A  | <img src="chars-orig/char-apl-10x20-3A.png" width="200%"> | 8x5   | +1+9                |
| 3B  | <img src="chars-orig/char-apl-10x20-3B.png" width="200%"> | 8x5   | +1+9                |
| 3C  | <img src="chars-orig/char-apl-10x20-3C.png" width="200%"> | 9x7   | +1+7                |
| 3D  | <img src="chars-orig/char-apl-10x20-3D.png" width="200%"> | 9x9   | +1+6                |
| 3E  | <img src="chars-orig/char-apl-10x20-3E.png" width="200%"> | 9x7   | +1+7                |
| 3F  | <img src="chars-orig/char-apl-10x20-3F.png" width="200%"> | 8x11  | +1+5                |
| 40  | <img src="chars-orig/char-apl-10x20-40.png" width="200%"> | 9x9   | +1+6                |
| 41  | <img src="chars-orig/char-apl-10x20-41.png" width="200%"> | 9x9   | +1+6                |
| 42  | <img src="chars-orig/char-apl-10x20-42.png" width="200%"> | 9x13  | +1+3                |
| 43  | <img src="chars-orig/char-apl-10x20-43.png" width="200%"> | 9x13  | +1+3                |
| 44  | <img src="chars-orig/char-apl-10x20-44.png" width="200%"> | 8x13  | +1+3                |
| 45  | <img src="chars-orig/char-apl-10x20-45.png" width="200%"> | 8x13  | +1+3                |
| 46  | <img src="chars-orig/char-apl-10x20-46.png" width="200%"> | 8x13  | +1+3                |
| 47  | <img src="chars-orig/char-apl-10x20-47.png" width="200%"> | 8x13  | +1+3                |
| 48  | <img src="chars-orig/char-apl-10x20-48.png" width="200%"> | 8x13  | +1+3                |
| 49  | <img src="chars-orig/char-apl-10x20-49.png" width="200%"> | 8x13  | +1+3                |
| 4A  | <img src="chars-orig/char-apl-10x20-4A.png" width="200%"> | 8x13  | +1+3                |
| 4B  | <img src="chars-orig/char-apl-10x20-4B.png" width="200%"> | 8x13  | +1+3                |
| 4C  | <img src="chars-orig/char-apl-10x20-4C.png" width="200%"> | 8x13  | +1+3                |
| 4D  | <img src="chars-orig/char-apl-10x20-4D.png" width="200%"> | 9x13  | +1+3                |
| 4E  | <img src="chars-orig/char-apl-10x20-4E.png" width="200%"> | 8x13  | +1+3                |
| 4F  | <img src="chars-orig/char-apl-10x20-4F.png" width="200%"> | 9x13  | +1+3                |
| 50  | <img src="chars-orig/char-apl-10x20-50.png" width="200%"> | 8x13  | +1+3                |
| 51  | <img src="chars-orig/char-apl-10x20-51.png" width="200%"> | 8x13  | +1+3                |
| 52  | <img src="chars-orig/char-apl-10x20-52.png" width="200%"> | 8x13  | +1+3                |
| 53  | <img src="chars-orig/char-apl-10x20-53.png" width="200%"> | 8x13  | +1+3                |
| 54  | <img src="chars-orig/char-apl-10x20-54.png" width="200%"> | 9x13  | +1+3                |
| 55  | <img src="chars-orig/char-apl-10x20-55.png" width="200%"> | 8x13  | +1+3                |
| 56  | <img src="chars-orig/char-apl-10x20-56.png" width="200%"> | 8x13  | +1+3                |
| 57  | <img src="chars-orig/char-apl-10x20-57.png" width="200%"> | 8x13  | +1+3                |
| 58  | <img src="chars-orig/char-apl-10x20-58.png" width="200%"> | 8x13  | +1+3                |
| 59  | <img src="chars-orig/char-apl-10x20-59.png" width="200%"> | 9x13  | +1+3                |
| 5A  | <img src="chars-orig/char-apl-10x20-5A.png" width="200%"> | 8x13  | +1+3                |
| 5B  | <img src="chars-orig/char-apl-10x20-5B.png" width="200%"> | 8x13  | +1+3                |
| 5C  | <img src="chars-orig/char-apl-10x20-5C.png" width="200%"> | 8x13  | +1+3                |
| 5D  | <img src="chars-orig/char-apl-10x20-5D.png" width="200%"> | 7x7   | +2+8                |
| 5E  | <img src="chars-orig/char-apl-10x20-5E.png" width="200%"> | 8x8   | +1+7                |
| 5F  | <img src="chars-orig/char-apl-10x20-5F.png" width="200%"> | 8x8   | +1+7                |
| 60  | <img src="chars-orig/char-apl-10x20-60.png" width="200%"> | 8x8   | +1+7                |
| 61  | <img src="chars-orig/char-apl-10x20-61.png" width="200%"> | 8x11  | +1+4                |
| 62  | <img src="chars-orig/char-apl-10x20-62.png" width="200%"> | 9x11  | +1+4                |
| 63  | <img src="chars-orig/char-apl-10x20-63.png" width="200%"> | 9x11  | +1+4                |
| 64  | <img src="chars-orig/char-apl-10x20-64.png" width="200%"> | 9x11  | +1+4                |
| 65  | <img src="chars-orig/char-apl-10x20-65.png" width="200%"> | 9x11  | +1+4                |
| 66  | <img src="chars-orig/char-apl-10x20-66.png" width="200%"> | 8x17  | +1+1                |
| 67  | <img src="chars-orig/char-apl-10x20-67.png" width="200%"> | 8x17  | +1+1                |
| 68  | <img src="chars-orig/char-apl-10x20-68.png" width="200%"> | 9x13  | +1+2                |
| 69  | <img src="chars-orig/char-apl-10x20-69.png" width="200%"> | 8x11  | +1+3                |
| 6A  | <img src="chars-orig/char-apl-10x20-6A.png" width="200%"> | 8x11  | +1+3                |
| 6B  | <img src="chars-orig/char-apl-10x20-6B.png" width="200%"> | 9x6   | +1+7                |
| 6C  | <img src="chars-orig/char-apl-10x20-6C.png" width="200%"> | 8x17  | +1+1                |
| 6D  | <img src="chars-orig/char-apl-10x20-6D.png" width="200%"> | 8x14  | +1+3                |
| 6E  | <img src="chars-orig/char-apl-10x20-6E.png" width="200%"> | 8x6   | +1+7                |
| 6F  | <img src="chars-orig/char-apl-10x20-6F.png" width="200%"> | 8x8   | +1+9                |
| 70  | <img src="chars-orig/char-apl-10x20-70.png" width="200%"> | 8x14  | +1+3                |
| 71  | <img src="chars-orig/char-apl-10x20-71.png" width="200%"> | 8x14  | +1+3                |
| 72  | <img src="chars-orig/char-apl-10x20-72.png" width="200%"> | 8x7   | +1+9                |
| 73  | <img src="chars-orig/char-apl-10x20-73.png" width="200%"> | 8x7   | +1+9                |
| 74  | <img src="chars-orig/char-apl-10x20-74.png" width="200%"> | 6x10  | +2+7                |
| 75  | <img src="chars-orig/char-apl-10x20-75.png" width="200%"> | 8x10  | +1+5                |
| 76  | <img src="chars-orig/char-apl-10x20-76.png" width="200%"> | 5x14  | +3+3                |
| 77  | <img src="chars-orig/char-apl-10x20-77.png" width="200%"> | 5x14  | +3+3                |
| 78  | <img src="chars-orig/char-apl-10x20-78.png" width="200%"> | 5x14  | +3+3                |
| 79  | <img src="chars-orig/char-apl-10x20-79.png" width="200%"> | 5x14  | +3+3                |
| 7A  | <img src="chars-orig/char-apl-10x20-7A.png" width="200%"> | 5x14  | +3+3                |
| 7B  | <img src="chars-orig/char-apl-10x20-7B.png" width="200%"> | 5x14  | +3+3                |
| 7C  | <img src="chars-orig/char-apl-10x20-7C.png" width="200%"> | 5x14  | +3+3                |
| 7D  | <img src="chars-orig/char-apl-10x20-7D.png" width="200%"> | 10x14 | +0+3                |
| 7E  | <img src="chars-orig/char-apl-10x20-7E.png" width="200%"> | 5x14  | +3+3                |

</details>

Other than the alphabet, which was copied from the VT340's actual
font, every glyph should be re-examined. However, the work can be
narrowed down to these typographical sins crying out to heaven for
justice:

* Worst offenders:

  | 5F                                                        | 60                                                        | 6B                                                        | 6C                                                        | 6D                                                        | 6E                                                        | 34                                                        |
  |-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|
  | <img src="chars-orig/char-apl-10x20-5F.png" width="50px"> | <img src="chars-orig/char-apl-10x20-60.png" width="50px"> | <img src="chars-orig/char-apl-10x20-6B.png" width="50px"> | <img src="chars-orig/char-apl-10x20-6C.png" width="50px"> | <img src="chars-orig/char-apl-10x20-6D.png" width="50px"> | <img src="chars-orig/char-apl-10x20-6E.png" width="50px"> | <img src="chars-orig/char-apl-10x20-34.png" width="50px"> |

* Could be better: 

  | 5D                                                        | 5E                                                        | 30                                                        | 72                                                        | 73                                                        | 3A                                                        | 3B                                                        |
  |-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|
  | <img src="chars-orig/char-apl-10x20-5D.png" width="200%"> | <img src="chars-orig/char-apl-10x20-5E.png" width="200%"> | <img src="chars-orig/char-apl-10x20-30.png" width="200%"> | <img src="chars-orig/char-apl-10x20-72.png" width="200%"> | <img src="chars-orig/char-apl-10x20-73.png" width="200%"> | <img src="chars-orig/char-apl-10x20-3A.png" width="200%"> | <img src="chars-orig/char-apl-10x20-3B.png" width="200%"> |

  | 61                                                        | 62                                                      | 63                                                      | 64                                                      | 65                                                      |
  |-----------------------------------------------------------|---------------------------------------------------------|---------------------------------------------------------|---------------------------------------------------------|---------------------------------------------------------|
  | <img src="chars-orig/char-apl-10x20-61.png" width="200%"> | <img src="chars-orig/char-apl-10x20-62.png" width="200%"> | <img src="chars-orig/char-apl-10x20-63.png" width="200%"> | <img src="chars-orig/char-apl-10x20-64.png" width="200%"> | <img src="chars-orig/char-apl-10x20-65.png" width="200%"> |

  | 32                                                        | 31                                                        | 3C                                                        | 3E                                                        | 40                                                        |
  |-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|
  | <img src="chars-orig/char-apl-10x20-32.png" width="200%"> | <img src="chars-orig/char-apl-10x20-31.png" width="200%"> | <img src="chars-orig/char-apl-10x20-3C.png" width="200%"> | <img src="chars-orig/char-apl-10x20-3E.png" width="200%"> | <img src="chars-orig/char-apl-10x20-40.png" width="200%"> |




[montage]: ../../charset/uplineload/apl-montage.png "Note how symbols such as 6B are squashed"
