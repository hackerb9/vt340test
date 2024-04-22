# The VWS VT200 emulator

<img src="vwsvt200.png" width=80% >

Apparently, before [DECterm](decterm.md) running on DECwindows, DEC
released a VT200 emulator on a peculiar windowing system called _VWS_
("Vax Workstation Software Windowing System"). There are a few things
interesting about this emulator, from a VT340 perspective.

## Portable Font

The VWS VT200 font is 10x20 which makes it a reasonable — if not quite
as aesthetically pleasing — drop in replacement for the VT340's font.
Especially since DEC released it in a [bitmap format](fonts/vwsvtfont)
that can be used on other machines. The bitmaps include double-wide
and double-size versions, the DEC Special Graphics, and Technical
Character Set. 

## 256 Colors

This terminal is
[documented](http://www.bitsavers.org/pdf/dec/vax/vms/vms_workstation/AA-MI67A-TE_A_Guide_to_Migrating_VWS_Applications_to_DECwindows_Sep1989.pdf)
as supporting 256 color graphics, which is more colors than any other
terminal from DEC (that I know of).

<ul>
<details>

| Terminal        | # colors | palette | sixel | ReGIS | Resolution  | year  |
|-----------------|----------|---------|-------|-------|-------------|-------|
| GIGI/VK100      | 8        | -       | -     | Y     | 768 x 240   | 1980  |
| VT125           | 4        | -       |       | Y     | 768 x 240   | 1981  |
| DECwriter IV    | 2        | -       | Y     | -     | 72 dpi      | 1981  |
| Rainbow Med Res | 16       | 4096    | -     | Y     | 384 x 240   | 1982  |
| Rainbow Hi Res  | 4        | 4096    | -     | Y     | 800 x 240   | 1982  |
| VT241           | 4        | 64      | Y     | Y     | 800 x 240   | 1984  |
| VWS VT200       | 256      | ?       | y¹    | y¹    | 1024 x 620² | 1987? |
| VT340           | 16       | 4096    | Y     | Y     | 800 x 480   | 1988  |
| DECterm         | 16       | ?       | Y     | Y     | 800 x 480   | 1989  |

1. The VWS VT200 could display both sixel and ReGIS graphics, sort of.

    <ul>
	<details>

	<img src="WorkstationOptions.png" align="right">

   There seem to actually have been two different programs: "VT200
   window" (with a white background) and "ReGIS VT200 window" (with a
   black background). The normal "VT200 window" claims to support
   sixel (when enquired with `write sys$output
   f$getdvi(f$getjpi("","terminal"),"tt_sixel")`), but not ReGIS. This
   = is correct. The ReGIS version claims to support both, but it
   doesn't actually display sixels in my tests. (I am running VWS in
   simulation using `simh`, so that may be part of the problem.)
   
   </details> </ul>
   <br clear=all>

2. VWS's vertical resolution for ReGIS seems lower than the 864 pixels
   claimed online. 

    <ul>
	<details>
   
   To come up with the number "620 pixels", I did some experiments
   with remapping the coordinate system using `S(A[0,0][1024,864])`.
   By using the 'V' (Vector) command and pressing the number keys, I
   was able to move the graphics cursor and notice how often the
   centerline didn't actually shift. By multiplying the ratio to the
   previous guess, I got progressively closer estimates.

   </details>
   </ul>

</details>
</ul>

## Strangenesses

These are oddities I've found about the VT200 terminal that are
perhaps bugs or perhaps just an error in my method of testing. 

*  Using the argument 2 or 3 in the DCS string for ReGIS opens up a
   separate command display window instead of prompting at the bottom
   of the terminal as the VT340 does. One can see the command and even
   type in ReGIS commands in the "interactive" window (after clicking
   in it), but anything typed is still interpreted by VMS! That nearly
   made it useless for me, but I could work around it by typing on a
   single line and then hitting <kbd>Ctrl</kbd><kbd>U</kbd> to clear
   the line and return to typing in the VT200 window. The trick is to
   not hit the <kbd>Enter</kbd> key as anything VMS prints as an error
   message will _also_ be interpreted as ReGIS commands.

* ReGIS cannot seem to write to horizontal line 0. As far as I can
  tell, the default grid actually goes from [0,1] to [799,479].

* Regis vertical line 300 is weird. Sometimes it shows up just fine,
  but other times it disappears, is solid when it should be dashed, or
  negative. 

<br/>
<hr>
<ul><sup><i>

“The red, green and blue data areas in the Color Map should be loaded
with all F's to reduce any unnecessary radio frequency emissions.”

</i>

---Rainbow Color Graphics Option Programmers Reference Guide, Jun 1984

</sup></ul>
