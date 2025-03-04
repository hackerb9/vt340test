The best introductory book to ReGIS is probably the 
[GIGI/ReGIS Handbook][GIGIREGIS] despite it being rather out of date
(1981) compared to the release of the VT340.

  [GIGIREGIS]: https://hackerb9.github.io/vt340test/docs/kindred/AA-K336A-TK_GIGI_ReGIS_Handbook_Jun81.pdf "GIGI/ReGIS Handbook, 1981"

VT340 graphics can be in the form of Sixel bitmaps or ReGIS commands.
While I tend to use Sixels more often these days, ReGIS graphics are
surprisingly fun due to the interactive interpreter mode. Just do
`printf "\eP3p"` and start experimenting. Use `Ctrl-[ \` to exit ReGIS.

ReGIS offers a way to draw text at any color, size, or angle. Here's a
color text example which uses the colormap index numbers:

```
DCS=$'\eP'
ST=$'\e\\'
echo "${DCS}3p;P[27,285];T(W(I3))' Key:    Good   ';T(W(I2))'Fair   ';T(W(I1))'Poor';${ST}"
```


The ReGIS Text command is `T` and it has multiple suboptions, such as
`S`_n_ for size and `W(I`_n_`)` to pick the color index for writing:

```
echo "${DCS}p;P[27,200];T(S16,W(I4))' Great';${ST}"
```

Another useful ReGIS command is `S` (Screen) which (among many other
things) changes the colors in the colormap with the suboption `M`.

Note that what the manual calls the "RGB system" is not like modern
RGB colors. Instead, it uses a single letter to specify one of eight
colors: **R**ed, **G**reen, **B**lue, **C**yan, **M**agenta,
**Y**ellow, **D**ark, **W**hite.

To access all 4096 different colors the VT340 offers, use the
Hue-Lightness-Saturation color space. HLS has much to recommend it as
a more natural way for humans to express colors.

```
echo "${DCS}p;S(M 1(H60 L80 S60) 2(H150 L50 S60))';${ST}"
```


-----

While slower than using the built-in fonts, you could use the Hershey
vector fonts. Here is an example you can send to your screen which is
the output from running plotutils hersheydemo -T regis --rotation 90.

Speaking of ReGIS demos, there are some nice ones written in ODE
(ordinary differential equation solver) which, due to the slow speed
of drawing, have a nice animated effect. You can find the files here:
https://github.com/hackerb9/vt340test/tree/main/regis/ode

