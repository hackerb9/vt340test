# Regis's Effect on Text Colors

Unlike sixels, which have a confusing layer of indirection, to change
the text color, ReGIS can edit the colormap directly. Just change the
colormap index you want (usually 7) and all text on the screen will be
shown in the new color.


## Colormap entries

Important [colormap](../colormap/colormap.md) entries for text and
their defaults at power on.

| Index |   H |  L |  S |   |  R |  G |  B | Text attribute    |
|-------|----:|---:|---:|---|---:|---:|---:|-------------------|
| 0     |   0 |  0 |  0 |   |  0 |  0 |  0 | Screen Background |
| 7     |   0 | 46 |  0 |   | 46 | 46 | 46 | Foreground Text   |
| 8     |   0 | 26 |  0 |   | 26 | 26 | 26 | Bold+Blink FG     |
| 15    |   0 | 79 |  0 |   | 79 | 79 | 79 | Bold Foreground   |


If you don't want to make text unreadable, The two most important
colors to _not_ change are colors number 0 and 7 (bg and fg). Instead,
use colors 1 to 6 and 9 to 14 for graphics. If twelve colors is
insufficient, color 8 (bold+blink fg) is reasonably safe to
commandeer. Color 15 (bold fg) can also be used in a pinch.

## Intentionally changing the text color

To change the text foreground and background:

    echo "${DCS}p;S(M  7(H60 L80 S60)  0(H150 L50 S60))';${ST}"

ReGIS on the VT340 specifies colors in the
[Hue-Lightness-Saturation](hls.md) color space, not RGB. 

<details><summary>Sidenote</summary>

<sub> Technically, there is a way to specify two-bit RGB colors, but
it is not worth even mentioning.</sub>

</details>

## Escape sequences for text attributes

From [colormap.md](../colormap/colormap.md), q.v.:

|               Attributes | Foreground | Background | Escape Sequence |
|-------------------------:|------------|------------|-----------------|
|                   Normal | 7          | 0          | `␛[0m`          |
|                     Bold | 15         | 0          | `␛[1m`          |
|                  Reverse | 0          | 7          | `␛[7m`          |
|             Reverse Bold | 0          | 15         | `␛[1;7m`        |
|              Blink (off) | 7          | 0          | `␛[5m`          |
|                   " (on) | 0          | 7          | "               |
|         Bold Blink (off) | 15         | 0          | `␛[1;5m`        |
|                   " (on) | 8          | 7          | "               |
| Reverse Bold Blink (off) | 0          | 15         | `␛[1;5;7m`      |
|                   " (on) | 7          | 8          | "               |

## Resetting the VT340 colormap

The VT340 has no single command to programmatically [reset the
colormap](../colormap/colorreset.md). While it is possible to do so
using [**DECRSTS**](../colormap/resetpalette.sh), using ReGIS is clear
and simple. See [resetpalette.regis](resetpalette.regis) for a file
you can send to your VT340.

## Multicolor text

As you can see, all text shares the same colormap entry so it is
always all the same color on the screen. 

It *is* possible to use ReGIS to fake multicolor text on the screen,
but it is not what the VT340 was designed for. Please see hackerb9's
discussion on [fake text color](faketextcolor.md).


