# Physical sixels 

The dot density of sixel images can be specified in realworld
dimensions. Unlike the DPI (dots per inch) common nowadays, sixels
work on the "point" system inherited from typesetting. 

### Definitions

* A **"point"** on a computer is 1/72nds of an inch. 
* The **default unit** in sixels is "decipoints" (1/720th of an inch).
* The **"grid"** size is the distance between pixels. 
* The **"aspect ratio"** is the _vertical_ divided by the _horizontal_
  grid sizes. (While the VT340 has the square pixels we are familiar
  with, back in the day that wasn't a given!)
* The horizontal grid size is set by **Pn3**'s numeric value
  using the realworld units selected by **SSU**.
* **Pn3** is third parameter of the sixel protocol selector.
* ANSI **SSU** is the _Select Size Unit_ escape sequence.
* The **vertical grid size** is implicitly set as the horizontal grid
  size times the aspect ratio.
* **DECGRA** ("Raster Attributes) is the primary method for setting
  the aspect ratio in sixel images using a numerator and denominator
  (**Pn4** and **Pn5**).
* The **Ps1 Macro parameter** is an alternative, less flexible way of
  setting the aspect ratio by choosing from a lookup table. It is
  overridden by **DECGRA**.

The sixel control strings are sent as follows:

``` math
\Large
\underbrace{
 \underbrace{\textbf{Esc}\ \textbf{P}}_\textbf{DCS} \quad
 \underbrace{Ps_1 \ \textbf{;}\ Ps_2\ \textbf{;}\ Pn_3\ \textbf{q}
   }_\textbf{Protocol Selector}
}_{
  \textbf{DCS Introducer Sequence}
} \quad
\underbrace{
  \underbrace{
      \texttt{"}\ Pn_4 \ \textbf{;}\ Pn_5\ \textbf{;}\ Pn_6\ \textbf{;}\ Pn_7
    }_{
      \textbf{Raster Attributes} 
	}
    \quad
      \underbrace{******}_\textbf{Picture data}
  }_\textbf{sixel data}
  \quad
  \underbrace{\textbf{Esc \\}}_\textbf{ST}
```

    ESC P  Ps1 ; Ps2 ; Pn3 q " Pn4 ; Pn5 ; Pn6 ; Pn7  ******  ESC \

    \___/  \_______________/ \_____________________/  \____/  \___/
     DCS   Protocol Selector    Raster Attributes     Picture  ST
                                                       data
    \______________________/ \_____________________________/ 
     DCS Introducer Sequence     sixel data




## About the VT340 physical sixel size

* The CRT of the VT340 has a fixed horizontal grid of 1/72nd of an
  inch (0.0195 cm). 
* The CRT's pixel height to width aspect ratio is 1:1.
* With exactly one typographer's point per pixel, the VT340 screen can
  handle sixel images precisely, but only at the lowest resolution.
* The VT340 ignores any requests by a sixel file to change the
  horizontal grid. This may be because all the other possible grid
  sizes are higher resolution than the screen.
* The VT340 _does_ honor changes to the aspect ratio, including the
  implicit request made by Ps1 with no **DECGRA**. If Ps1 is not _9_,
  the VT340 will no longer be showing images at their true (printed)
  size.
* The VT340's aspect ratio change is done by multiplying pixels
  vertically for each "rectangular pixel". It can only handle whole
  numbers of pixels, so aspect ratios will be rounded.

## DECGRA and ANSI Set Size Unit (SSU)

The primary way to set a physical size of an image is to send ANSI SSU
to pick a real-world unit for the grid measurements and use the
**DECGRA** sixel control code to set the Raster Attributes. (The
alternative is to use the Macro parameter, discussed later.)

### SSU - Select Size Unit

SSU is defined in
[ECMA-48](https://www.ecma-international.org/publications-and-standards/standards/ecma-48/)
as setting the unit of measurement for all numeric parameters. 

> **8.3.139 SSU - SELECT SIZE UNIT** <br/>
> Notation: (Ps) <br/>
> Representation: CSI Ps 02/00 04/09 <br/>
> Parameter default value: Ps = 0 <br/>
> <br/>
> SSU is used to establish the unit in which the numeric parameters of
> certain control functions are expressed. The established unit
> remains in effect until the next occurrence of SSU in the data
> stream.<br/>
> <br/>
> The parameter values are <br/>
> 0 CHARACTER  - The dimensions of this unit are device-dependent <br/>
> 1 MILLIMETRE     <br/>
> 2 COMPUTER DECIPOINT - 0,035 28 mm (1/720 of 25,4 mm)   <br/>
> 3 DECIDIDOT - 0,037 59 mm (10/266 mm)   <br/>
> 4 MIL - 0,025 4 mm (1/1 000 of 25,4 mm)   <br/>
> 5 BASIC MEASURING UNIT (BMU) - 0,021 17 mm (1/1 200 of 25,4 mm)   <br/>
> 6 MICROMETRE - 0,001 mm   <br/>
> 7 PIXEL - The smallest increment that can be specified in a device   <br/>
> 8 DECIPOINT - 0,035 14 mm (35/996 mm)  

While any value is valid for a sixel image, the VT340 happens to
always send the following SSU when [printing](mediacopy/README.md)
hardcopy of graphics,

```
Esc [ 2 Space I
```

The parameter value of _2_, "computer decipoint", refers specifically
to the "horizontal grid" (space between pixels) of the sixel image.
For example, the VT340 screen's horizontal grid screen is about .012
inches. When making WYSIWYG printouts, the VT340 specifies a
horizontal grid size of _9_, as $9/720 = 0.0125"$, and 

Sidenote: if you wish your image to be shown on whatever the display
device happens to consider its native resolution, then ANSI SSU can
set units to be "pixels" using `Esc [ 7 Space I`. 

### DECGRA

`"` _Pn1_ `;`  _Pn2_ `;`  _Pn3_ `;`  _Pn4_ 

* Pn1: Pixel aspect ratio numerator
* Pn2: Pixel aspect ratio denominator
* Pn3: Horizontal extent
* Pn4: Vertical extent

Pn1 and Pn2 override the older style Macro parameter (see below) given
in the sixel's DCS string protocol selector as Ps1.

<!-- XXX give a clear example -->


### Extent: Pn3, Pn4: nominal Width and Height

This is often taken to mean the size of an image in pixels, but that
is not what the Sixel standard says.

1. On a screen, it is merely the size of the rectangle that is cleared
to the text background color before drawing. 
  
  <details> 
  
  One might wonder, what is the point is of an "extent", if not to
  specify the image boundary size. It may be helpful to consider what
  would happen if it was _not_ specified. On the VT340, any opaque
  sixel image, upon receive the first sixel bit pattern, clears the
  screen from the cursor location all the way to the bottom right
  corner. This can be a bit slow when sending a lot of tiny images.
  (For example, a [soft-font previewer](../charset/softfonts/drcspreview.sh).

</details>

2. The size is not necessarily specified in pixels. This is the crux
   of how sixels can have a physical size. The actual units are
   specified by the ANSI **SSU** sequence.

## The Macro parameter _Ps1_: _x_/660"

An older, less capable method to set the horizontal grid size is to
specify the "Macro" (Ps1 parameter from the protocol selector of the
sixel DCS string.)

`Esc` `P` _Ps1_ `q`

_Ps1_ is (supposedly) measured in units of 1/660ths of an inch, from
2/660ths to 9/660ths. Anything other than a single digit from 2 to 9
is the same as '0', which means five _decipoints_ (5/720 in).

All the documentation from DEC treats 9/660ths as equivalent to
10/720ths of an inch, which it is to three decimal places, so a
setting of `9` is a 1:1 aspect ratio. 

  <details>

  | Ps1 | V. Grid | H. Grid | Aspect Ratio | VT340 V. pixels |
  |-----|---------|---------|:------------:|-----------------|
  | 0   | 10/720  | 5/720   | 2:1          | 2               |
  | 1   | "       | "       | "            | "               |
  | 2   | "       | 2/648   | 4.5:1        | 5               |
  | 3   | "       | 3/648   | 3:1          | 3               |
  | 4   | "       | 4/720   | 2.5:1        | 3               |
  | 5   | "       | 5/660   | 1.83:1       | 2               |
  | 6   | "       | 6/648   | 1.5:1        | 2               |
  | 7   | "       | 7/648   | 1.3:1        | 1               |
  | 8   | "       | 8/648   | 1.12:1       | 1               |
  | 9   | 10/720  | 9/648   | 1:1          | 1               |

  Note: Horizontal grid size in this table is an educated guess by
  Hackerb9 given self-contradicting documentation. 

  </details>

<ul>

**TIP**

_For VT340 compatibility, a sixel image can specify "9" to mean square
pixels at 72 dots per inch._

</ul>

Note that Macro parameter specifies both the horizontal resolution and
the aspect ratio with a single number. That is because using it
presumes a vertical grid size fixed at ten decipoints (10/720 in). To
change the vertical resolution, one must instead use DECGRA and ANSI
SSU (see above).

### Why 1/660? 

It is not yet clear why DEC specified **660** as the denominator for
the horizontal grid size.

[DEC's Portable Printing Language v2 documentation][pplv2]
treats Ps1 = 9 as being exactly one point (1/72), giving a one-to-one
aspect ratio. But that is odd, because one point is 9/648ths, not
9/660ths. In fact, looking at the aspect ratios in PPLv2's Table 5-1,
Macro Parameter Selections, we can see that the aspect ratio listed 
actually implies that the true denominator should be 648 in nearly
every case.

[pplv2]: https://hackerb9.github.io/vt340test/docs/EK-PPLV2-PM.B01_Level_2_Sixel_Programming_Reference.pdf "Level 2 Sixel Programming Manual (1994)"

<details><summary>Comparing Aspect Ratios for different denominators</summary>

Since the vertical grid size is fixed at 100 centipoints, we can
calculate the numerator of the aspect ratio as $\frac{(1 / 72)}{(Ps1 /
Hgrid)}$. 

| _Ps1_ | From table 5-1 | For Ps1/648 | For Ps1/660 |
|-------|----------------|-------------|-------------|
| 2     | 450:100        | **450:100** | 458:100     |
| 3     | 300:100        | **300:100** | 306:100     |
| 4     | 250:100        | 225:100     | 229:100     |
| 5     | 183:100        | 180:100     | **183:100** |
| 6     | 150:100        | **150:100** | 153:100     |
| 7     | 130:100        | **129:100** | **131:100** |
| 8     | 112:100        | **113:100** | 115:100     |
| 9     | 100:100        | **100:100** | 102:100     |

Most of the ratios match a denominator of 648. The aspect ratio of
183:100 given for 5, the default _Ps1_, is interesting because it is
the only one that is correct for 660, the denominator given in the
documentation. ($(1/72) / (5/660) = 183.333$). It also suggests that
all the digits in table 5-1 are significant.

The aspect ratio for 4 (250:100), on the other hand, is not correct
for either 660 or 648. It could be 4/720 or possibly a typo for
225:100 ($(1/72) / (4/648) = 225$). However the VT340 rounds it up
to 300:100.

</details>

### VT340's aspect ratio stretching

Perhaps useless trivia: the multiplier used by the VT340 to stretch
pixels vertically can be calculated instead of held in a table; it is
equal to $round(10 / Ps1)$ for values 2 through 9. For all other
values, it is $2$.

$$
\text{Vertical stretch multiplier}= \begin {cases} 
round(10/Ps1)&\text{if}&2\leq PS1 \leq 9\\
2 & \text{otherwise} \end {cases}
$$
