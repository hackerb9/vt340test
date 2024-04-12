# WordPerfect for UNIX Character Terminals
<img align=right width=40% src="wp80-about.jpg">

Thanks to the work of Tavis Ormandy
([taviso](https://github.com/taviso)), one can now easily run the
32-bit binaries of a word processor from the turn of the century which
outputs sixel graphics specifically for the VT340. See Tavis's
[wpunix](https://github.com/taviso/wpunix) project which includes
easily installable packages for Debian and other popular GNU/Linux
flavors.

<br clear="all">


## Getting it to work on a VT340

	wp -t vt220 -g vt340_sixelhi

For some reason wp (WordPerfect) does not pay attention to the TERM
settings and always states that its termtype is "xterm". This results
in garbled screens, for example this equation editor which has an odd
purple double image. The solution is to run wp with the argument `-t
vt220` [sic] and set the graphics type to `vt340_sixelhi`. As you can
see, that gives much better results:


<img alt="termtype xterm on a vt340" align=left width=40% src="eqn-defaulttypeisxterm-thumb.jpg">
<img alt="termtype vt220m graphics vt340_sixelhi" align=right width=40% src="eqn-t=vt220-g=vt340_sixelhi-thumb.jpg">
<br clear="all">



## Keys

WordPerfect uses all the functions keys and the application keypad. 

It also uses PF1 (the "GOLD KEY"), PF2, and PF3 as "dead keys" which
do a single shift to select alternate functions. One nice things about
WordPerfect is that one can hit the Help key at any time for context
sensitive help. Hit it a second time to get a list of the keyboard
layout. Here are some photos of the help screens. 
[_Sorry, I don't have this in text format yet. --b9_]

<img width=80% src="wp80-dectermcolor-help1-thumb.jpg">
<img width=80% src="wp80-dectermcolor-help2-thumb.jpg">
<img width=80% src="wp80-dectermcolor-help3-thumb.jpg">
<img width=80% src="wp80-dectermcolor-help4-thumb.jpg">

[XXX: Replace images with correct screenshots].

[XXX: Add text version]. 

<ul>

_Caveat:_ These keyboard shortcut photos are from when I mistakenly
thought the correct terminal type was "dectermcol", which is probably
identical to the "vt220" keyboard map. 

WordPerfect's DECTerm Color terminal type cannot be used with the
VT340 because it does not include sixel graphics, although it does
seem to have better character support which perhaps should be
investigated. It may be possible to modify it to allow sixel graphics
and create a better driver for the VT340.

</uL>

### **IMPORTANT**: Do not hit the F5 key. 

F5 causes WordPerfect to immediately die on my terminal. I believe it
sends a 'break', which should be ignored. It may be misbehaving
because of the way I am running it in a specially created account,
using 'su'. 

### Even more keys, documentation not yet found

Although not listed in the online help, certain control keys work,
such as ^P to print. [XXX: Surely there is a list somewhere?]

The VT340's builtin <kbd>Compose</kbd> key works as normal to insert
characters like æ, ü, é.

### Menu key mystery

When the terminal type is set to xterm, <kbd>Esc</kbd><kbd>=</kbd>
opens the **File** menu without requiring a mouse. That menu key
sequence is supposed to be listed in the upper right hand corner of
the screen, but when the terminal is set to "vt220", it just shows
empty parentheses `()`.

<kbd>Esc</kbd><kbd>F</kbd> also (sometimes) works for "xterm" to open
the File menu, but does not ever work for "vt220", instead complaining
about some missing file.

## LK201 Gold Key Editing Keyboard for document processing

[XXX: Add photo here]

The biggest problem with WordPerfect is the difficulty remembering all
the different key strokes. Yes, one can hit Help twice to see a list,
but it is still cumbersome because of the weird use of PF1, PF2, and
PF3 giving some function keys four different meanings. If you have a
keyboard which has wordprocessing commands written in gold on the
front of the letters and in other colors on top of the keypad, you'll
find that WordPerfect does not correspond at all. It should be
possible, however, to create a keyboard mapping. [XXX: has someone
already done this?]

## WordPerfect's sixel output

WordPerfect has a very peculiar output for sixel graphics, no doubt
influenced by device limitations of the day, for example the VT240
which required each sixel image to start at the top of the screen.

* Each image is made up of about twenty DCS strings. 
* Each DCS string starts with a string of `-` (graphic newlines) to
  skip to the place the previous string left off.
* The DCS strings that contain image data do _not_ define the colors
  they use.
* In at least one example (for Kermit's sixel graphics) the colormap
  was sent as [a separate DCS string](../../kermitdemos/DEMO.SIX). 
* [XXX: Check actual wp "kermit" output] 
* Each row of sixels starts with `~$`, which would seem to do nothing.
  What was the purpose of this? 
* The data sent is redundant, with the screen being sent twice. (At
  least for the "xterm" output, but it is likely the same for vt220 as
  they both use the "vt340_sixelhi" graphics drivers.)

## To do

* WordPerfect may use the VT340's "locator" (mouse) for its menus, so
  I should find one and see if it works.
  
* Does WordPerfect support the built-in TCS font for large symbols,
  like summation?
  
* Can one convince WordPerfect to use a VT340 soft-font with
  additional characters? It already shows mathematical symbols as
  sixels in the equation editor (hit the LIST (F11) key and use Page
  Down). But, when set to "dectermcol", those show up as @ signs.
  
* Why does the xterm driver have so many segmentation faults? 

