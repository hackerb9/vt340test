-------- CUT HERE -------- 8< ------ README.TXT -------- 8< -----------------

This distribution includes five files: this one (README.TXT) and four
others. These files will enable you to display Christmas greetings, etc.,
on many types of DEC terminals. The following describes these files, what
you have to do to display them, and the terminal capabilities required to
view them.

This distribution contains two images in DEC "Sixel" graphics format:
"MERRY_XMAS," showing the words "Happy Holidays" with Santa's face;
and "CHRISTMASBILL," showing "Bill The Cat" from "Bloom County" wearing
a Santa suit.

These images were created for the VT240 terminal, and are best displayed on
that device, but should be viewable on nearly ANY terminal capable of
interpreting sixel data in at least four colors. Note that, although the
sixel format incorporates "color setup" syntax, I perform color setup
separately, in DEC "ReGIS" graphics language. This is because I've found
that early releases of VT240 firmware IGNORE the color-setup portion of
the sixel format! The "generality" of the images' viewability is much
improved by performing color setup separately, although you can of course
merge the "image" and "color" files into one, if you desire. This has the
perhaps-irritating side effect of requiring a terminal to have ReGIS as
well as Sixel capability but, as I said, they were developed for the VT240.
The shrewd hacker should find it fairly simple to "convert" the color
information to Sixel format if desired.

Just in case you didn't follow that, here are directions for viewing the
three separate items you've received:

1) Merry Christmas picture:

TYPE MERRY_XMAS.CLR
TYPE MERRY_XMAS.SIX

2) Bill The Cat picture:

TYPE CHRISTMASBILL.CLR
TYPE CHRISTMASBILL.SIX

3) Train picture/animation:

TYPE TRAIN.PIC

That's it -- Merry Christmas!

Chris Chiesa, Light Valve Technology, Rochester, NY 12/16/89

