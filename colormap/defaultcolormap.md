# VT340 Default Color Map

```
Index	 H    L   S		 R   G   B
0      	 0    0   0		 0   0   0	Background
1      	 0   49  59		20  20  79 
2      	120  46  71		79  13  13 
3      	240  49  59		20  79  20			
4      	 60  49  59		79  20  79			
5      	300  49  59		20  79  79
6      	180  49  59		79  79  20
7      	 0   46   0		46  46  46	Foreground Text
8      	 0   26   0		26  26  26	Bold+Blink FG
9      	 0   46  28		33  33  59
10     	120  42  38		59  26  26
11     	240  46  28		33  59  33
12     	 60  46  28		59  33  59
13     	300  46  28		33  59  59
14     	180  46  28		59  59  33
15     	 0   79   0		79  79  79	Bold FG
```

<img src="showcolortable.png"/>

Unlike modern systems, on the VT340, R, G, B range from 0 to 100
percent in decimal. Another difference is that a Hue angle of 0
degrees is blue on the VT340, not red.

## Documentation differs

Note that the above table contains the _actual_ values retrieved from a
VT340+ after doing a factory reset of the settings. Almost all values
have slightly lower lightness or saturation than what is printed in
the manual. Most significantly, the foreground color (7) in the manual
is listed as 53% (#878787) in the manual, but in reality it is 46%
(#757575). Perhaps in an earlier firmware revision it did match the
manual. At some point, it seems it was decided, for every color except
the foreground, to subtract 1 from the percent saturation and subtract
0 or 1 from the lightness. 

Here is the HLS side of table 2-3 VT340 Default Color Map from the
VT340 Graphics Programming manual (2nd ed.), with the delta of how it
changed in the actual hardware.

```
Index	 H   	  L	    S
0      	 0   	  0         0
1      	 0   	 50 -1     60 -1
2      	120  	 46        70 -1
3      	240  	 50 -1     60 -1
4      	 60  	 50 -1     60 -1
5      	300  	 50 -1     60 -1
6      	180  	 50 -1     60 -1
7      	 0   	 53 -6      0
8      	 0   	 26         0
9      	 0   	 46        29 -1
10     	120  	 43 -1     39 -1
11     	240  	 46        29 -1
12     	 60  	 46        29 -1
13     	300  	 46        29 -1
14     	180  	 46        29 -1
15     	 0   	 80 -1      0
```

## Connection between text attributes

Although the VT340 supports text colors, it is not "ANSI color".
Instead, it represents some text attributes by using four specific
colors in the colormap: 0, 7, 8, and 15. Sending the escape sequence
to show **bold** text (`Esc``[``1``m`), for example, would use color
number 15 as the foreground instead of 7.

| Style                    | Foreground | Background | Escape Sequence |
|--------------------------|------------|------------|-----------------|
| Normal                   | 7          | 0          | `\e[0m`         |
| Bold                     | 15         | 0          | `\e[1m`         |
| Reverse                  | 0          | 7          | `\e[7m`         |
| Blink (when off)         | 7          | 0          | `\e[5m`         |
| Blink (when on)          | 0          | 7          |                 |
| Bold Blink (off)         | 15         | 0          | `\e[1;5m`       |
| Bold Blink (on)          | 8          | 7          |                 |
| Reverse Bold Blink (off) | 0          | 15         | `\e[1;5m`       |
| Reverse Bold Blink (on)  | 7          | 8          | `\e[1;5;7m`     |
| Reverse Bold             | 0          | 15         | `\e[1;7m`       |

See the RGB script [../vms/rgb.sh](rgb.sh) for interactively choosing
those four colors. This is a handy script as it can also be used with
arguments to quickly reset the terminal to a favorite setting after
viewing an image. (`rgb.sh 12 14 55 41`)

Are there any VT340 emulators which can run rgb.sh? Emulators
typically do not use the colormap to represent text attributes.
Additionally, they would need to support ReGIS graphics for setting
individual colors in the palette.

<img src="../vms/RGB.png" align="center"/>

## Inverse colors

<img src="cursorblink.png" align="center"/>

The VT340 has a concept of "inverse" colors in another sense: when the
cursor is on top of sixel data, it flashes between normal and some
other color picked from the palette. To find the inverse index number,
xor the normal index number with 7. That flips the low three bits but
keeps the high bit of the nybble.

```
INVERSE COLOR PAIRS: XOR 7
	0--7		 8--15
	1--6		 9--14
	2--5		10--13
	3--4		11--12
```

Note that this mapping works somewhat like the way that text
attributes are already inverted during blink and reverse (as above).
Both Blink and Reverse swap foreground text color 7 with background
color 0. When blinking, **bold** text color 15 is switched with
blinking-bold color 8. However, there is at least one exception: When
reversed, bold text color 15 is swapped with background color 0.

### When using the default VT340 colormap

One benefit of keeping the high bit is that inverting a color will not
change the saturation when using the default colormap. Colors 8 to 15
are lower saturation versions of colors 0 to 7.

The default colormap also makes the relationship between a color and
its inverse simple to describe in terms of Hue, Saturation, and
Lightness:

* If Saturation is 0 (gray), then the Lightness Percent is offset by
  around 50 percentile points.

* If Saturation is >0 (color), then the Hue Angle is rotated by 180
  degrees.





