It appears much of the earlier DEC documentation was printed using a
font which is tough for OCR. It would be good to get the actual font
to train tesseract on. Hackerb9's current guess is that it was created
by a Diablo Courier 72 Print Wheel.

Wikipedia's Diablo Print Wheel entry says:

> One notable user was Digital Equipment Corporation, who resold the printer as the LQP01 (with a parallel interface) and the LQPSE (with an RS-232 serial interface), supported by Digital's WPS-8 word processing software. 

The characters which make Diablo Courier 72 distinct from other
Courier fonts are `G`, `r`, `i`, `d`, `L`, `I`, `1`, and `·`. Perhaps
most notable are the extremely large dots used for bullet points, ·.
Look for the base of the 'i' being not too wide and its dot above
being rounded, not square. The serif at the top the 'd' should be
rather prominent. The serif on the G should stick in much further than
it sticks out. The base of the I and r should not be wide.

* TeX Gyre Cursor Bold is perhaps the closest font because it has
rounded the edges and dots. However, the dots are too small, the 'i'
is too wide, the stem of the lowercase 'd' is too tall and its serif
too short. 

* Apple's Courier (based on Bitstream) is also quite close. The center
dot is bigger than in Cursor, which is good, but it is still not big
enough. The serif on the 'G' sticks out too far. Both capital and
lowercase 'i' are too wide. The base of the lowercase 'r' extends out
too far.


Characters which are on the Courier 72 Print Wheel that are non
standard:

* Cents ¢
* Negation ¬
* Degree °
* Copyright ©

Characters which are on the Courier 10 Print Wheel that are
non-standard:

* £
* ¬
* ½
* ¼
* Ø (slash through zero!)

Characters which are on the Courier Legal 10 Print Wheel that are
non-standard:

* ¢
* ½
* ¼
* †
* ‗ (double underline)
* §
* °
* ¶
* ©
* ®




