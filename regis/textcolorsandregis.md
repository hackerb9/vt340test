# Regis's Effect on Text Colors

Unlike sixels, which have a confusing layer of indirection, ReGIS
makes modifying the colormap straight-forward. Just change the
colormap index you want and you're done. 

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
insufficient, color 8 (bold+blink foreground) is reasonably safe to
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

## Resetting the VT340 colormap

The VT340 has no single command to programmatically [reset the
colormap](../colormap/colorreset.md). While it is possible to do using
[**DECRSTS**](../colormap/resetpalette.sh), using ReGIS is clear and
simple. See [resetpalette.regis](resetpalette.regis) for a file you
can send to your VT340.






