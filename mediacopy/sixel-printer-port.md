# Sixel Printer Port Extension

<blockquote>

### Note from hackerb9

The following was extracted and converted to Markdown for
[vt340test](https://github.com/hackerb9/vt340test) from section 7.8 (Graphics Printing) of 
[DEC STD 070](../docs/kindred/EL-SM070-00-DEC_STD_070_Video_Systems_Reference_Manual_Dec91.pdf#page=737).
It describes the sixel graphics format from the point of view of
printing from a terminal to an attached printer. 

The DEC VT340 supports the Level 2 sixel protocol, so I suggest
skipping all the confusing information about Level 1. The primary
flaw in Level 1 is that it is unable to print 1:1 aspect ratio.
Additionally, due to a bug in the VT340 firmware, at least on
hackerb9's VT340+ (G2), Level 1 is unusable for
[MediaCopy](../mediacopy/README.md). The only reason to use Level
1 sixels is if you are using an older terminal, such as a VT241.

</blockquote><br/>

<small>

**VSRM - Printer Port Extension EL-00010-07**<br/>
_\*\*\* COMPANY CONF - DEC Internal Use Only_ 28-Apr-1987
</small>

This section describes graphics printing  and is intended to apply
to devices which  support graphic displays and  the Sixel Graphics
Extension.

| Graphics Print Operations | Description |
|---------------------------|-------------|
| Graphics Print Screen     | The complete graphics bit map  is transferred to the printer. This can be invoked  by the host through the ReGIS  hardcopy command or by the user under local control.                                                          |
| Graphics Print Region     | An image of a portion of the  screen bit map is transferred to the printer.  This  can be  invoked  by  the  host through  the  ReGIS hardcopy command. Refer  to the ReGIS chapter  for determining how to define this region. |

## 7.8.2 Sixel Printing

A Sixel  is a group  of 6 vertical  pixels represented by  6 bits
within a character  code. A one value for a  bit indicates that a
pixel-spot will be  placed at the corresponding  grid position, a
zero will cause  the corresponding grid position  to be unchanged
(not written).

Sixel printing consists of setting  context and attributes for the
pixels   and   then   printing  each   Sixel   in   left-to-right,
top-to-bottom  order. Wherever  possible,  run-length encoding  is
used to reduce the number of  characters transmitted for a line of
Sixels.

See the [Sixel Graphics Extension](sixel-graphics-extension.md)
chapter for further details on the Sixel format.

**Guideline**: When a Sixel dump is  initiated by the user under local
control (Print  Key), the terminal  first transmits a CR  to reset
the ANSI text  position on the printer to the  left margin. If the
Sixel dump  is initiated by  the host, the CR  is not sent  so the
host can initialize the starting sixel position.


**Guideline**: The  VT240 sends  the following characters  out the
printer port (or host port) when  transmitting a sixel dump of the
screen.


    ESC   \     <CR>   ESC	 P    1    q    <sixel-data>  ESC   \
    1/11  5/12	0/13   1/11  5/0  3/1  7/1				  1/11	5/12

    \________/         \_______/	                      \________/
       ST			      DCS     						      ST

### 7.8.2.1 Color And Monochrome Sixels

On  devices which  support a  color display,  the user  may select
monochrome or  color sixel printing. Monochrome  Sixels are formed
from the multiple plane image by  a logical OR of all pixels which
are selected  for any  color. If color  printing is  selected, the
terminal will send  out color specifiers at the  beginning of each
Sixel dump to reflect the contents of the terminal's color map.

If PRINT  BACKGROUND is selected, all  pixels with no bits  set in
any plane are printed in the color value selected for index 0.

### 7.8.2.2 Expanded Print


Graphics  expanded  print  mode determines  whether  the  terminal
generates a small (compressed) or large (expanded) graphics image.
The small image fits on 8-1/2  inch wide paper and expanded images
on 13 inch wide paper in portrait mode. This mode is selectable by
the DEC-private mode DECGEPM or by the user under local control.

### 7.8.2.3 Rotated Print

Graphics rotated  print mode  rotates the image  by 90  degrees so
that an  expanded image can fit  on a single 8-1/2  inch wide page
(rotated images are  always expanded). This mode  is selectable by
the DEC-private mode DECGRPM or by the user under local control.

**Guideline**: the VT240 rotates the  image counter clockwise, so that
the left  side of  the paper  (as it  comes out  of a  typical dot
matrix  printer)  corresponds to  the  top  of  the image  on  the
terminal screen. This scanning order  was chosen to allow punching
holes for a looseleaf notebook on the  left side of the page as it
comes out of the printer.

## 7.8.2.4 Sixel Graphics Level (Guideline)

As  the  Sixel  graphics  protocol  has  become  more  general  to
accommodate  a  range  of  pixel aspect  ratios  and  grid  sizes,
Terminals have begun  supporting two levels of  the Sixel graphics
protocol  to match  the capabilities  of the  printer being  used.
Level 1 provides backward compatibility with older printers, while
Level  2 allows  the  terminal  to take  full  advantage of  newer
printer capabilities to improve print quality.

The _Sixel Graphics Level_ determines how the terminal matches the
printer's  Sixel Aspect  Ratio, Horizontal  Grid Size,  Background
Printing, and Color Printing capabilities.

The Sixel  Graphics Level  is selectable by  the user  under local
control.

<details><summary><b>Click to see information on Level 1 Sixel Devices</b></summary>

## Level 1 Sixel Devices -

ASSUMPTIONS: Level 1  sixel devices do not support  the Set Raster
Attribute  command, Background  Select, Horizontal  Grid Size,  or
Macro Parameter  commands. The aspect  ratio is fixed at  2:1, and
the horizontal grid  size is approximately 7.5 x  .001 inches (800
pixels require 6 inches). Level 1 is the factory default.

Sixel Control Strings will be sent to the printer as follows:

    ESC  P  1  q  S...S  ESC  \       (always 7-bit controls)

### COMPRESSED Level 1 Sixel Print Option -

A terminal with a 1:1 pixel aspect ratio will combine each pair of
horizontally adjacent pixels (from two successive scan lines) into
a single pixel. The value of the combined pixel will be the
LOGICAL OR of the values of the individual pixels.

        1:1 Aspect Ratio       Level 1 Printer

		+---+                     +---+
		| a |					  |   |
		+---+    LOGICAL OR ->	  |a+b|
		+---+					  |   |
		| b |					  |   |
		+---+					  +---+


This will produce images of the same size and aspect ratio
as the VT240 (2:1 Aspect Ratio).
ReGIS images will appear normal, but ANSI text
may be distorted.

### EXPANDED Level 1 Sixel Print Option -

Terminals with pixel aspect ratios of 1:1 will transmit each Sixel
twice (in immediate horizontal succession).

           1:1 Aspect Ratio         Level 1 Printer

           +---+                     +---+ +---+
           | a |                     |   | |   |
           +---+    PRINT TWICE ->   | a | | a |
           +---+                     |   | |   |
           | b |                     |   | |   |
           +---+                     +---+ +---+
            .                        +---+ +---+
            .                        |   | |   |
            .                        | a | | a |
                                     |   | |   |
                                     |   | |   |
                                     +---+ +---+
                                      .
                                      .
                                      .

This will produce images of the same size and aspect ratio as the
VT240 (2:1 Aspect Ratio), but with twice the vertical resolution.

### ROTATED Level 1 Sixel Print Option -

Terminals with 1:1 pixel aspect  ratios will transmit the selected
portion of the  display bitmap in vertical strips  six pixels wide
from top to bottom, and right to left.

               display              paper
            +--------------+     +-----------+
			|          2 1 |     | 1-------> |
			|		   | | |     | 2-------> |
			|		   | | |     |			 |
			|		   V V |     |			 |
			+--------------+     |			 |
                                 |			 |
                                 |			 |
                                 +-----------+


Each Sixel is sent twice in immediate horizontal succession (with
respect to the printer).

          1:1 Aspect Ratio              Level 1 Printer
          +---+ +---+ +---+              +---+ +---+
    . . . |   | | b | | a |              |   | |   | . . .
          +---+ +---+ +---+    ROTATE    | a | | a |
                +---+ +---+     AND      |   | |   |
                |   | |   |    PRINT     |   | |   |
                +---+ +---+    TWICE ->  +---+ +---+
                      +---+              +---+ +---+
                      |   |              |   | |   |
                      +---+              | b | | b |
                         .               |   | |   |
                         .               |   | |   |
                         .               +---+ +---+
                                          .
                                          .
                                          .

This will produce images of the  same size and aspect ratio as the
VT240 (2:1 Aspect  Ratio), but with twice  the vertical resolution
(with respect to the image displayed on the screen).

</details>


## Level 2 Sixel Devices -

ASSUMPTIONS:  Level  2  sixel   devices  support  the  Set  Raster
Attribute  command, Background  Select, Horizontal  Grid Size  and
Macro Parameter commands.

Sixel control strings are sent as follows:

    ESC P  Ps1 ; Ps2 ; Pn3 q " Pn4 ; Pn5 ; Pn6 ; Pn7  ******  ESC \

    \___/  \_______________/ \_____________________/  \____/  \___/
     DCS   Protocol Selector    Raster Attributes     Picture  ST
                                                       data
    \______________________/ \_____________________________/ 
     DCS Introducer Sequence     sixel data


Where:

* **Ps1** Is the Macro Parameter and is always ZERO.

* **Ps2** Background Select
    * **1** if Background Printing is disabled in Set-Up
    * **2** if Background Printing is enabled in Set-Up

* **Pn3** Horizontal Grid Size, given in units specified
  by ANSI SSU (default is decipoints, 1/720 inch).
  For default size units, the grid size should be
  **6** for COMPRESSED and **9** for EXPANDED or ROTATED print.<br/><br/>
  _Since the host can change the printer between accesses,
  SSU should be sent once before each sixel dump._

          ESC  [    2    SP   I       (Set Size Unit
          1/11 5/11 3/2  2/0  4/9      to Decipoints)

* **Pn4** Pixel aspect ratio numerator, 1

* **Pn5** Pixel aspect ratio denominator, 1

* **Pn6** Horizontal extent
  (number of pixels in image horizontally)

* **Pn7** Vertical extent
  (number of pixels in image vertically)


### COMPRESSED Level 2 Sixel Print Option -

When  Level  2  sixel  graphics is  selected,  the  terminal  will
transmit the selected portion of the display bitmap as sixels from
left to right, and top to  bottom. No translation of screen pixels
is required  since the printer  directly supports 1:1  sixels with
the desired grid size. The horizontal grid size is set to 6 in the
Set Raster Attributes command.

### EXPANDED Level 2 Sixel Print Option -

When  Level  2  sixel  graphics is  selected,  the  terminal  will
transmit the selected portion of the display bitmap as sixels from
left to right, and top to  bottom. No translation of screen pixels
is required  since the printer  directly supports 1:1  sixels with
the desired grid size. The horizontal grid size is set to 9 in the
Set Raster Attributes command.

### ROTATED Level 2 Sixel Print Option -

When  Level  2 sixel  graphics  is  selected, the  terminal  will
transmit the selected  portion of the display  bitmap in vertical
strips six  pixels wide from  top to  bottom, and right  to left.
Each sixel  is sent once  using the  same sixel initiator  as for
expanded print above (horizontal grid size set to 9).
