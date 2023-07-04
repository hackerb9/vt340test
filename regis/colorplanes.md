# VT340 Color Planes
The VT340 has four 1-bit color planes. Each pixel makes up a four-bit
number that is looked up in a colormap table to find the actual color.
However, the bit planes can be written to individually, as well, by
using the ReGIS "Field" bitmask which is `AND`ed against any graphical
write.

## Example of Using Bitplanes

    registest field

## Default VT340 colors, seen as bit planes

| Index | F8 | F4 | F2 | F1 | Color name        |   H |  L |  S |
|-------|----|----|----|----|-------------------|----:|---:|---:|
| 0     | 0  | 0  | 0  | 0  | Black             |   0 |  0 |  0 |
| 1     | 0  | 0  | 0  | 1  | Blue              |   0 | 49 | 59 |
| 2     | 0  | 0  | 1  | 0  | Red               | 120 | 46 | 71 |
| 3     | 0  | 0  | 1  | 1  | Green             | 240 | 49 | 59 |
| 4     | 0  | 1  | 0  | 0  | Magenta           |  60 | 49 | 59 |
| 5     | 0  | 1  | 0  | 1  | Cyan              | 300 | 49 | 59 |
| 6     | 0  | 1  | 1  | 0  | Yellow            | 180 | 49 | 59 |
| 7     | 0  | 1  | 1  | 1  | Medium Gray (50%) |   0 | 46 |  0 |
| 8     | 1  | 0  | 0  | 0  | Dark Gray (25%)   |   0 | 26 |  0 |
| 9     | 1  | 0  | 0  | 1  | Desat Blue        |   0 | 46 | 28 |
| 10    | 1  | 0  | 1  | 0  | Desat Red         | 120 | 42 | 38 |
| 11    | 1  | 0  | 1  | 1  | Desat Green       | 240 | 46 | 28 |
| 12    | 1  | 1  | 0  | 0  | Desat Magenta     |  60 | 46 | 28 |
| 13    | 1  | 1  | 0  | 1  | Desat Cyan        | 300 | 46 | 28 |
| 14    | 1  | 1  | 1  | 0  | Desat Yellow      | 180 | 46 | 28 |
| 15    | 1  | 1  | 1  | 1  | White (Gray 75%)  |   0 | 79 |  0 |

### Colormap affects text rendering

As mentioned in the [colormap notes](../colormap/colormap.md), some of
the locations in the color map affect the screen text. Briefly: 0 Screen
Background, 7 Foreground Text, 8 Bold+Blink FG, 15 Bold Foreground. 

If you need to reset the colormap to the VT340 defaults, you can `cat`
the file [resetpalette.regis](resetpalette.regis).

<details><summary>Click to see data</summary>

```
Esc P0p
S(
M 0 	(H  0 L  0 S  0)
M 1 	(H  0 L 49 S 59)
M 2 	(H120 L 46 S 71)
M 3 	(H240 L 49 S 59)
M 4 	(H 60 L 49 S 59)
M 5 	(H300 L 49 S 59)
M 6 	(H180 L 49 S 59)
M 7 	(H  0 L 46 S  0)
M 8 	(H  0 L 26 S  0)
M 9 	(H  0 L 46 S 28)
M 10	(H120 L 42 S 38)
M 11	(H240 L 46 S 28)
M 12	(H 60 L 46 S 28)
M 13	(H300 L 46 S 28)
M 14	(H180 L 46 S 28)
M 15	(H  0 L 79 S  0)
)
Esc \
```
</details>

## Color mixing peculiarities

Color mixing using the planes doesn't quite make sense, for example,
BLUE (0001) and RED (0010) make GREEN (0011). However, hackerb9 has
found that the table is close to correct, with only three changes, if
colormixing is desired. Swap green with magenta, do the same for low
saturation green and magenta, and swap medium and bright gray.

```regis
	Esc P0p
	S(
	M 4 	(H 60 L 49 S 59)	M 3 	(H240 L 49 S 59)
	M 12	(H240 L 46 S 28)	M 11	(H 60 L 46 S 28)
	M 15 	(H  0 L 46 S  0)	M  7	(H  0 L 79 S  0)
	)
	Esc \
```
