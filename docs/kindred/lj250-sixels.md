# Extract from LJ-250/LJ-252 Printer Programmers Manual

# CHAPTER 6: SIXEL GRAPHIC MODE

This chapter describes how to send sixel graphic data, including color
data, to the Companion Color Printer set in the DEC mode.

## 6.1 OVERVIEW

To print graphics or color graphics, you must use sixel data. A sixel
is a column of six vertical pixels. Pixels are the smallest elements
of a picture 4 the individual dots on a video terminal screen or a dot
matrix printer. See Figure 6-1.

A sixel represents bit map data. Each pixel of a sixel represents one
bit of information. A bit value of 1 means to print a pixel, while a
bit value of 0 means to leave a space. The printer decodes the sixel
data into bits of information and maps them to the appropriate
printhead elements for printing.

Sixel data consists of characters each represented by a binary bit
pattern. To encode picture data into valid sixel data, first convert
each six-bit binary sixel to a hexadecimal value. In each sixel
column, the least significant bit corresponds to the top pixel, and
the most significant bit corresponds to the bottom pixel.

Because sixel column codes are restricted to characters in the range
from ? (3/15) through ~ (7/14), you must then add the hexadecimal
offset 3/15 (decimal 63) to each sixel column value. For example, the
binary value of 000000 is converted to hexadecimal 3/15, binary 110101
is converted to hexadecimal 7/4 (3/5 plus 3/15), and binary 111111 is
converted to hexadecimal 7/14 (3/15 plus 3/15).

After this binary to hexadecimal conversion, you can convert the
hexadecimal into the equivalent characters using the ASCII table.

## 6.2  SELECTING  GRAPHIC  MODE:  THE  SIXEL  PROTOCOL

You select sixel graphic mode by sending a special device control
string (DCS). You include all your sixel graphic data and formatting
information in the device control  string.

The formatting section of the device control string is called the
sixel protocol selector. The rest of this section describes the
features you can select within the sixel protocol selector.

The device control string starts with the DCS control code, called a
string introducer . Next comes the protocol selector, which contains
your formatting information. The protocol selector is followed by the
sixel graphic data. Finally, the string terminator (ST) control code
ends the string. The ST code also ends Graphic mode.

**Control String  (DCS)  Format**

| DCS          | Ps1   | ;    | Ps2   | ;          | Ps3         | ... | Ps?   | q   | sixel data | ST         |
|--------------|-------|------|-------|------------|-------------|-----|-------|-----|------------|------------|
| 9/0          | `***` | 3/11 | `***` | 3/11       | `***`       | ... | `***` | 7/1 | `******`   | 9/12       |
| ┃            | ┃     |      |       |            |             |     |       | ┃   | ┃          | ┃          |
| ┃            | ┃     |      |       |            |             |     |       | ┃   | ┃          | ┃          |
| ┃            | ┗━━   | ━━━━ | ━━━   | Protocol   | Selector    | ━━━ | ━━━   | ┛   | Picture    | ┃          |
| ┃            |       |      |       | (0 or more | characters) |     |       |     | Data       | ┃          |
| String       |       |      |       |            |             |     |       |     |            | String     |
| Introducer   |       |      |       |            |             |     |       |     |            | Terminator |
| <sup>†</sup> |       |      |       |            |             |     |       |     |            |            |

<sup>†</sup> In the 7 bit mode ESC P (1/11 5/0) is used as the String Introducer.


### 6.2.1 String Introducer

When you send the string introducer in text mode, you identify the
start of the device control string. In the Companion Color Printer
sixel graphic mode is one of the two valid uses of the device control
strings. You can use the 8-bit DCS (9/0) control code or the 7-bit ESC
P (1/11 5/0) escape sequence for the string introducer.


### 6.2.2 Protocol Selector

The protocol selector can contain a string of 0, 1, or more selective
parameters (Ps), each separated by a ; (3/11). A valid selective
parameter can have 0, 1, or more digits in the column/row range of 3/0
to 3/9. When you send any selective parameter with the final character
gq (7/1), the printer enters the graphic mode.

The  protocol  selector  has  the  following  format.

| Ps1   | ;    | Ps2   | ;    | Pn3   | ... | Ps    | q   |
|-------|------|-------|------|-------|-----|-------|-----|
| `***` | 3/11 | `***` | 3/11 | `***` | ... | `***` | 7/1 |

_NOTE: The ; (3/11) marks the end of the current parameter._

The results of receiving control characters within the protocol
selector sequence are shown in Table 6-1.

**Table  6-1:  Control  Characters  in  the  Protocol  Selector  Sequence**

| Control  Code                                             | Results                                                                                                                         |
|-----------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| SUB  (1/10)                                               | Terminates  protocol  selector  sequence, places  printer  in  text  mode,  and  then  processes  SUB.                          |
| CAN (1/8)                                                 | Terminates protocol selector sequence, places printer in text mode, and then processes CAN.                                     |
| ESC  (1/11)                                               | Terminates  protocol  selector  sequence, places  printer  in  text  mode,  and  then processes  ESC.                           |
| Other  CO  control  codes (other  than  SUB, CAN  &  ESC) | Honored  without  terminating  the protocol  selector  sequence.                                                                |
| C1 control  codes                                         | Terminates  protocol  selector  sequence  and causes  printer  to  enter  text  mode. C1  control  codes  are  then  processed. |

#### 6.2.2.1 Macro Parameter (Ps1)

The Ps1 parameter selects the fixed horizontal grid size (pixel width)
and aspect ratio. This parameter provides for backward compatibility
with existing software.

_NOTE: For new software, you should set Ps1 to 0, and explicitly define
the horizontal grid size (by using Pn3), and the aspect ratio
numerator and denominator. (Use Pn1 and Pn2 of the &lt;Set Raster
Attributes> control sequence in Section 6.3.2.2.)_

| Ps1              | Horizontal<br/>Grid  Size  (Inches) | Pixel  Aspect  Ratio<br/>(Vertical:Horizontal) |
|------------------|-------------------------------------|------------------------------------------------|
| 0  or  none      | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 1                | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 2,  default  to: | 1/180  (0.0056)                     | 250:100  (2.5:1)                               |
| 3,  default  to: | 1/180  (0.0056)                     | 250:100  (2.5:1)                               |
| 4                | 1/180  (0.0056)                     | 250:100  (2.5:1)                               |
| 5,  default  to: | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 6,  default  to: | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 7,  default  to: | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 8,  default  to: | 1/144  (0.0069)                     | 200:100  (2:1)                                 |
| 9                | 1/72   (0.0139)                     | 100:100  (1:1)                                 |

If Ps1 is greater than 9, default Ps1 = 0

#### 6.2.2.2 Background Select (Ps2)

This parameter is not used on the Companion Color Printer. The printer
ignores this parameter. _[Hackerb9 says, On the VT340 terminal, this
chooses whether the background is opaque or transparent]_

#### 6.2.2.3 Horizontal  Grid  Size  (Pn3) 

The Pn3 parameter defines the horizontal grid size (pixel width) in
decipoints. A decipoint is 1/720 inch. This parameter and the aspect
ratio define the grid size.

The printer has horizontal grid size defaults for some decipoint
values. The following shows the horizontal grid size specified for
each Pn3 value.

| Pn3  Decipoints<br/>(1/720  Inch  Units) | Horizontal  Grid  Size<br/>(Inches)            |
|------------------------------------------|------------------------------------------------|
| 0  or  none                              | No  change  to  grid  size  (defined  by  Ps1) |
| 1,2,  and  3†                            | 1/180  (0.0056)                                |
| 4                                        | 1/180  (0.0056)                                |
| 5                                        | 1/144  (0.0069)                                |
| 6†                                       | 1/144  (0.0069)                                |
| 7†                                       | 1/144  (0.0069)                                |
| 8                                        | 1/90  (0.0111)                                 |
| 9†                                       | 1/90  (0.0111)                                 |
| 10                                       | 1/72  (0.0139)                                 |
| 11 to 19†                                | 1/72  (0.0139)                                 |
| 20                                       | 1/36  (0.0278)                                 |
| 21 and up†                               | 1/36  (0.0278)                                 |

† Defaults  to  horizontal  grid  size  listed.


If Pn3 is 0 or not present, the horizontal grid size is determined by
the macro parameter (Ps1). Otherwise, Pn3 overrides the horizontal
grid size portion of the Ps1, while attempting to preserve the aspect
ratio (A/R) as follows.

* When  Ps1  selects  a  2:1  aspect  ratio

| Pn3<br/>Selection | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|-------------------|------------------------------------------------------------------------|
| 1/180 in          | 2:1  A/R  and  change  to  HGS  =  1/180  in                           |
| 1/144 in          | 2:1  A/R  and  HGS  =  1/144  in                                       |
| 1/90 in           | 2:1  A/R  and  HGS  =  1/90  in                                        |
| 1/72 in           | 2:1  A/R  and  change  to  HGS  =  1/72  in                            |
| 1/36 in           | 2:1  A/R  and  change  to  HGS  =  1/72  in                            |



* When  Ps1  selects  a  1:1  aspect  ratio

| Pn3<br/>Selection | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|-------------------|------------------------------------------------------------------------|
| 1/180  in         | 1.1  A/R  and  change  to  HGS  =  1/180  in                           |
| 1/144  in         | 1:1  A/R  and  change  to  HGS  =  1/180  in                           |
| 1/90  in          | 1:1  A/R  and  change  to  HGS  =  1/90  in                            |
| 1/72  in          | 1:1  A/R  and  HGS  of  1/72  in                                       |
| 1/36 in           | 1:1  A/R  and  change  to  HGS  =  1/36  in                            |

* When  Ps1  selects  a  2.5:1  aspect  ratio

| Pn3<br/>Selection | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|-------------------|------------------------------------------------------------------------|
| 1/180  in         | 2.5:1  A/R  and  HGS  =  1/180  in                                     |
| 1/144  in         | 2.5:1  A/R  and  HGS  =  1/180  in                                     |
| 1/90  in          | 2.5:1  A/R  and  change  to  HGS  =  1/90  in                          |
| 1/72  in          | 2.5:1  A/R  and  change  to  HGS  =  1/90  in                          |
| 1/36 in           | 2.5:1  A/R  and  change  to  HGS  =  1/90  in                          |


#### 6.2.2.4 Additional  Parameters  (Ps?)

Additional parameters may be supported in future products. The
Companion Color Printer ignores other parameters without affecting the
current sixel protocol sequence.

#### 6.2.2.5 Final Character (q) 

The final character q (7/1) identifies this sequence as a sixel
protocol selector and places the printer in Graphic mode.

### 6.2.3 Picture Data

Picture data includes sixel printable characters and sixel control
characters. All picture data is processed while in sixel graphics mode
instead of standard ASCII text mode. The printer processes picture
data as defined in Section 6.3. In sixel graphic mode, printing is
always performed unidirectionally.

### 6.2.4 String Terminator (ST)

The string terminator (ST) control code causes the printer to exit
sixel graphic mode and enter text mode. You can use the 8-bit control
code ST (9/12) or for the 7-bit escape sequence ESC \ (1/11, 5/12) for
the string terminator.


## 6.3  CHARACTER  PROCESSING  IN  SIXEL  GRAPHIC  MODE

In Sixel Graphic mode, printable character codes define specific
columns of dots to print.


### 6.3.1 Sixel  Printable  Characters

In sixel graphic mode, the printer interprets GL (graphic left)
characters in the column/row range of 3/15 to 7/14 as printable
characters. Each of these 64 values represents a code of 6 vertical
pixels (1 sixel) to print. The actual pixel size is defined by the
horizontal grid size (HGS) parameter and the aspect ratio (Section
6.2.2.3).

The printer subtracts a hexadecimal offset of 3F<sub>H</sub> (3/15)
from each graphic printable character received, resulting in a binary
value in the range of 0/0 to 3/15. The 6-bit binary value obtained
represents a sixel column definition.

For each bit set to 1, the printer activates a printhead element or
group of elements to print a dot. The least significant bit (bit 0) is
the top pixel of a sixel.

The printer processes GR (graphic right) characters in the 11/15 to
15/14 range as GL characters, by setting the eighth bit to 0 and
subtracting the 3F hexadecimal offset (3/15) from the graphic
printable character.

| Column/<br/>Row | ASCII<br/>Character | Binary<br/>Value | Pixels<br/>Activated | Action<br/>Performed          |
|-----------------|---------------------|------------------|----------------------|-------------------------------|
| 3/15            | ?                   | 000000           | None                 | Advances  by  a  sixel  space |
| 4/0             | @                   | 000001           | Top                  | Prints  top  pixel  only      |
| 5/15            | _                   | 100000           | Bottom               | Prints  bottom  pixel  only   |
| 7/14            | ~                   | 111111           | All                  | Prints  one  full  column     |

If you try to print past the right margin, the printer truncates all
remaining sixel data until it receives the next graphic carriage
return ($) or graphic new line (-) character.


### 6.3.2 Sixel  Control  Codes

Sixel control codes are GL characters in the 2/0 to 3/14 range. Note
that this range also includes the parameter separator (;) (3/11) and
parameter digits 0 to 9 (3/0 to 3/9).

The printer processes GR characters in the 10/0 to 11/14 range as GL
characters, by setting the eighth bit to 0.

The  following  sixel  control  characters  are  recognized.

| Column/<br/>Row | ASCII<br/>Character | <br/>Function             |
|:---------------:|:-------------------:|:--------------------------|
| 2/1             | !                   | Repeat  introducer        |
| 2/2             | .                   | Set  raster  attributes   |
| 2/3             | #                   | Color  introducer         |
| 2/4             | $                   | Graphic  carriage  return |
| 2/13            | 4                   | Graphic  new  line        |
| 3/0  to  3/9    | 0  to  9            | Numeric  parameters       |
| 3/11            | ;                   | Parameter  separator      |

A control sequence in Graphic mode begins with a sixel control
character (not including the 0 to 9 and ; characters) and ends with a
printable character or another sixel control character.

The printer ignores unassigned sixel control characters (along with
parameters or parameter separators) until receiving the next valid
sixel control character, printable character, or string terminator
(ST).

#### 6.3.2.1 Repeat  Introducer  (!)  and  Sequence 

You can use the following sequence to consecutively print the same
character a number of times.

| !   | Pn    | Printable  character |
|-----|-------|----------------------|
| 2/1 | `***` | `*`                  |

Pn specifies the number of times to print the character that follows.

The numeric parameter is a string of characters in the 3/0 to 3/9
range that the printer interprets as a decimal number, from 0 to
65,535. If you omit Pn or set Pn to 0, the printer uses 1. If you use
a Pn value larger than 65535, the printer uses the maximum value of
65535.

_NOTE: Sixel control characters received during a repeat sequence
cancel the repeat sequence. The printer then processes these control
characters._

The Companion Color Printer prints the printable character (in the
3/15 to 7/14 range) as many times as specified by Pn. The printable
character terminates the repeat sequence.

_EXAMPLES_

| Re- | peat | Seq- | uence | Function                      |
|-----|------|------|-------|-------------------------------|
| !   | 1    | 0    | ?     | Repeats 10 graphic spaces     |
| 2/1 | 3/1  | 3/0  | 3/15  |                               |
| !   | 6    | @    |       | Repeats 6 patterns of top dot |
| 2/1 | 3/6  | 4/0  |       |                               |


#### 6.3.2.2 Set  Raster  Attributes  Sequence

This sequence defines the pixel aspect ratio. This aspect ratio
applies to all sixel data that follow. After entering sixel graphic
mode, the printer must immediately receive this sequence before the
first sixel printable character.

If the printer receives the sequence after any other valid sixel data,
the printer recognizes this sequence but ignores its parameters. The
printer continues to process all following sixel data. 
_[Note from hackerb9: This is unlike the VT340 terminal which does not
ignore the parameters.]_

If the sequence is received before any other valid sixel data, the
printer processes the sequence.

The set raster attributes sequence format is as follows:

| "   | Pn1   | ;    | Pn2   | ;    | Pn3   | ;    | Pn4   |
|-----|-------|------|-------|------|-------|------|-------|
| 2/2 | `***` | 3/11 | `***` | 3/11 | `***` | 3/11 | `***` |


where:

|     |                                          |
|-----|------------------------------------------|
| "   | Set raster attributes control character. |
| Pn1 | Pixel  aspect  ratio  numerator.         |
| Pn2 | Pixel  aspect  ratio  denominator.       |

Pn1 and Pn2 are numeric parameters. A numeric parameter is a string of
characters in the 3/0 to 3/9 range, which the printer evaluates as
decimal numbers. If the parameter is a value larger than the maximum
65,535, the printer uses 65,535. If Pn1 or Pn2 is 0, missing, or set
to 0, a value of 1 is assumed.

Pn3, Pn4, and all other parameters received in this sequence are
ignored by the printer.

Pixel aspect ratio defines the shape of the pixel needed to reproduce
the picture without distortion. This ratio is defined by two numbers:
a numerator and a denominator. The pixel aspect ratio is the ratio of
the pixel's vertical size to its horizontal size.

For example, an aspect ratio of 2:1 represents a pixel twice as high
as it is wide. The pixel aspect ratio (A/R) multiplied by the
horizontal grid size (HGS) yields the ideal vertical grid size (VGS).

The LJ250/252 printer supports only the following three aspect ratios.

| Aspect<br/>Ratio | HGS<br/>(inch) | Horizontal<br/>Dots/Pixel | VGS<br/>(inch) | Vertical<br/>Dots/Pixel | #  of<br/>Colors |
|------------------|----------------|---------------------------|----------------|-------------------------|------------------|
| 1:1              | 1/180          | 1                         | 1/180          | 1                       | 8                |
|                  | 1/90           | 2                         | 1/90           | 2                       | 256<sup>†</sup>  |
|                  | 1/72           | 2 or 3                    | 1/72           | 2 or 3                  | 8                |
|                  | 1/36           | 5                         | 1/36           | 5                       | 8                |
|                  |                |                           |                |                         |                  |
| 2:1              | 1/180          | 1                         | 1/90           | 2                       | 8                |
|                  | 1/144          | 1  or 2                   | 1/72           | 2 or 3                  | 8                |
|                  | 1/90           | 2                         | 1/45           | 4                       | 256<sup>†</sup>  |
|                  | 1/72           | 2 or 3                    | 1/36           | 5                       | 8                |
|                  |                |                           |                |                         |                  |
| 2.5:1            | 1/180          | 1                         | 1/72           | 2 or 3                  | 8                |
|                  | 1/90           | 2                         | 1/36           | 5                       | 8                |

<sup>†</sup> When DECBCMM is set, color selection is by special 64 entry color map.

Other aspect ratios specified by Pn1 and Pn2 are processed as follows.

* If  the  aspect  ratio  is  less  than  1.5:1,  the  printer  uses  1:1.

* If the aspect ratio is greater than or equal to 1.5:1 and less than
  2.25:1, the printer uses 2:1.

* If the aspect ratio is greater than 2.25:1, the printer uses 2.5:1.

The printer attempts to preserve the specified aspect ratios at each
horizontal grid size as follows:

* When the selected aspect ratio is 2.5:1

| Horizontal<br/>Grid Size | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|--------------------------|------------------------------------------------------------------------|
| 1/180 in                 | 2.5:1  A/R  and  HGS  =  1/180  in                                     |
| 1/144 in                 | 2.5:1  A/R  and  change  to  HGS  =  1/180  in                         |
| 1/90 in                  | 2.5:1  A/R  and  HGS  =  1/90  in                                      |
| 1/72 in                  | 2.5:1  A/R  and  change  to  HGS  =  1/90  in                          |
| 1/36 in                  | 2.5:1  A/R  and  change  to  HGS  =  1/90  in                          |

* When  the  selected  aspect  ratio  is  2:1


| Horizontal<br/>Grid Size | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|--------------------------|------------------------------------------------------------------------|
| 1/180 in                 | 2:1  A/R  and  HGS  =  1/180  in                                       |
| 1/144 in                 | 2:1  A/R  and  HGS  =  1/144  in                                       |
| 1/90 in                  | 2:1  A/R  and  HGS  =  1/90  in                                        |
| 1/72 in                  | 2:1  A/R  and  HGS  =  1/72  in                                        |
| 1/36 in                  | 2:1  A/R  and  change  to  HGS  =  1/72  in                            |

* When  the  selected  aspect  ratio  is  1:1


| Horizontal<br/>Grid Size | Resulting  Aspect  Ratio  (A/R)<br/>And  Horizontal  Grid  Size  (HGS) |
|--------------------------|------------------------------------------------------------------------|
| 1/180 in                 | 1:1  A/R  and  HGS  of  1/180  in                                      |
| 1/144 in                 | 1:1  A/R  and  change  to  HGS  =  1/144  in                           |
| 1/90 in                  | 1:1  A/R  and  HGS  of  1/90  in                                       |
| 1/72 in                  | 1:1  A/R  and  HGS  of  1/72  in                                       |
| 1/36 in                  | 1:1  A/R  and  HGS  of  1/36  in                                       |

By following these rules, the only possible vertical grid sizes the
printer can use are 1/180, 1/90, 1/72, 1/45, or 1/36 of an inch.

| Vertical<br/>Grid Size | <br/>Sixel  Height | Pixel  Construction<br/>(Vertical  Dots  per  Pixel) |
|:----------------------:|:------------------:|------------------------------------------------------|
| 1/180  in              | 1/30  in           | 1  vertical  dot  per  pixel                         |
| 1/90  in               | 1/15  in           | 2  vertical  dots  per  pixel                        |
| †1/72  in              | 1/12  in           | Alternate  3  then  2  vertical  dots  per  pixel    |
| 1/45  in               | 2/15  in           | 4  vertical  dots  per  pixel                        |
| 1/36  in               | 1/6  in            | 5  vertical  dots  per  pixel                        |

† This is the standard vertical grid size (LA34, LA50, LA75 & LA210)


#### 6.3.2.3 Graphic Carriage Return ($)

The graphic carriage return (GCR) control code $ (2/4) returns the
carriage to the graphic left margin. The graphic left margin is the
active position where the printer enters the Graphic mode.

#### 6.3.2.4 Graphic New Line (-)

The graphic new line (GNL) control code (2/13) sets the active column
to the left margin and advances the paper by the current sixel height.
This is the logical function of the GNL command.

However, to optimize throughput the physical vertical advance may not
be performed immediately. Depending on the current vertical grid size,
multiple sixel lines may be stored before printing actually occurs.
The printer stores enough data to support all printhead elements
before data is printed.

After printing the data and returning to the graphic left margin, the
vertical active position is incremented by the number of pixels just
printed.

If enough data is not received at the end of the sixel file to cause
printing, the (ST) command must be sent to complete printing of sixel
file.


#### 6.3.2.5 Numeric  Parameters  (0  to  9)

Some graphic control codes must be a decimal number that is followed
by a numeric value. The numeric value is coded by using the ASCII
digits 0 to 9 (8/0 to 3/9). A numeric value is ended by any nondigit,
specifically another control code or a graphic printable character.
The default value for any numeric parameter is 0.

#### 6.3.2.6 Parameter  Separator  (;)

The parameter separator, which is a semicolon (;) (3/11), separates a
series of numeric parameters. If there is no number before the
separator, the preceding parameter value defaults to 0. If a number
does not follow the separator, the following parameter value defaults
to 0.

### 6.3.3 Color  Introducer  (#)

The color introducer begins either a color selection sequence or a
color specification sequence. The color specified parameter Pc must
always follow the color introducer control code (#). This printer
supports up to 256 Pc parameters with values 0 to 255.

In a color selection sequence, the Pc parameter determines the color
to be applied to the following sixel data. On entering sixel mode, all
Pc values (0 to 255) are assigned to black. Therefore, application
software must first specify the colors of each Pc value it intends to
use in one of two coordinate systems: HLS or RGB. _[Note from
hackerb9: This is unlike the VT340 terminal which starts with a
default colormap and retains changes to it. Additionally, this
paragraph seems at odds with Appendix D which lists 256 colors.]_

To specify a color for a specific Pc parameter, Pc must be immediately
followed by:

| ; | Pu | ; | Px | ; | Py | ; | Pz |
|---|----|---|----|---|----|---|----|
|   |    |   |    |   |    |   |    |

Sections 6.3.3.1 and 6.3.3.2 give details on specifying colors in the
HLS and RGB coordinate systems.

#### 6.3.3.1 HLS  (Hue/Lightness/Saturation)  Sequence

| #   | Pc    | ;    | Pu  | ;    | Px    | ;    | Py    | ;    | Pz    |
|-----|-------|------|-----|------|-------|------|-------|------|-------|
| 2/3 | `***` | 3/11 | `*` | 3/11 | `***` | 3/11 | `***` | 3/11 | `***` |

* Pz: Saturation

  Range  =  0  -  100%

  (If  missing,  O  is   assumed.)

* ; Parameter  Separator

* Py: Lightness

  Range  =  0  -  100%

  (If  missing,  0 is  assumed.)

* Px: Hue Angle

  Range  =  0  -  360

  (If  missing,  0  is  assumed.)

* Pu: Coordinate Definer

  | Pu          | Meaning                         |
  |-------------|---------------------------------|
  | 0  or  none | Sequence  ignored               |
  | 1           | HLS  (hue/lightness/saturation) |
  | 2           | RGB  (red/green/blue)           |
  | 3  and  up  | Sequence  ignored               |

  _[Note from hackerb9: This is unlike the VT340 terminal which
  presumes HLS when Pu is 0 or missing.]_

* Pc: Color Specifier

  Range = 0  -  255

  Select  one  of  256  colors.

* #: Color  Introducer  Graphics  Control  Character

_NOTE: If Pc, Px, Py, or Pz is beyond maximum, sequence is ignored._

#### 6.3.3.2 RGB  (Red/Green/Blue)  Sequence

| #   | Pc    | ;    | Pu  | ;    | Px    | ;    | Py    | ;    | Pz    |
|-----|-------|------|-----|------|-------|------|-------|------|-------|
| 2/3 | `***` | 3/11 | `*` | 3/11 | `***` | 3/11 | `***` | 3/11 | `***` |


* Pz: Blue

  Range  =  0  -  100%

  (If  missing,  O  is assumed.)

* ; Parameter  Separator

* Py: Green

  Range  =  0  -  100%

  (If  missing,  O  is assumed.)

; Px: Red

  Range  =  0  -  100%

  (If  missing,  O  is assumed.)

* Pu: Coordinate Definer

  | Pu          | Meaning                         |
  |-------------|---------------------------------|
  | 0  or  none | Sequence  ignored               |
  | 1           | HLS  (hue/lightness/saturation) |
  | 2           | RGB  (red/green/blue)           |
  | 3  and  up  | Sequence  ignored               |

  _[Note from hackerb9: This is unlike the VT340 terminal which
  presumes HLS when Pu is 0 or missing.]_

* Pc: Color Specifier

  Range = 0  -  255

  Select  one  of  256  colors.

* #: Color  Introducer  Graphics  Control  Character

_NOTE: If Pc, Px, Py, or Pz is beyond maximum, sequence is ignored._


### 6.3.4 Graphic  CO  Control  Characters

In sixel graphic mode, the printer ignores all CO control characters
except CAN, SUB, and ESC. When these control characters are received,
the printer performs the following actions.

| CO  Control  Character | Printer  Action                           |
|------------------------|-------------------------------------------|
| CAN                    | Terminates  sixel  graphic  mode,         |
|                        | enters  text  mode, then  processes  CAN. |
|                        |                                           |
| SUB                    | Processes SUB as  a sixel  space  (3/15)  |
|                        | to limit  communication  line  errors.    |
|                        |                                           |
| ESC                    | Terminates  sixel  graphic  mode,         |
|                        | enters  text  mode, then  processes  ESC. |


_NOTE: When the printer receives any C1 control code in sixel graphic
mode, the printer leaves graphic mode and enters text mode. The
printer then processes the C1 control codes, if applicable._

### 6.3.5 Graphic  Substitute  (SUB)  Character

The printer interprets the substitute character SUB (1/10) as being in
place of a character or characters received in error. In graphic mode,
the printer processes SUB as a sixel space character (3/15).

If the printer is processing a repeat sequence, the sequence is
terminated. The printer then prints a number of sixel spaces equal to
the repeat number specified in the repeat sequence. The printer
remains in graphic mode.

### 6.3.6 Leaving  Sixel  Graphic  Mode

The following control characters cause the printer to leave graphic
mode and perform the following actions.

| Control Character | Printer  Action                                                   |
|-------------------|-------------------------------------------------------------------|
| CAN               | Enters text  mode, and  processes  the CAN character.             |
|                   |                                                                   |
| ESC               | Enters text mode and begins processesing another escape sequence. |
|                   |                                                                   |
| ST                | Enters text mode.                                                 |

_NOTE: The printer prints all stored sixel data before entering text mode._


### 6.3.7 Printer State After Leaving Graphic Mode

After leaving sixel graphic mode, the printer is in the following
state.

* Horizontal position returns to the last active position before
  entering sixel graphic mode.

* Horizontal pitch returns to the last value used before entering
  sixel graphic mode.

* Vertical position has been modified by the vertical control
  characters received in sixel graphic mode. However, the first text
  mode motion command (for example, LF, VT, or FF) advances the
  vertical position to the next text line grid before executing the
  command.

* Vertical pitch returns to the last value used before entering sixel
  graphic mode.

* All SGR attributes return to the last state before entering sixel
  graphic mode.

----------------------------------------------------------------------

# More info on the LJ 250 from other sections

### Color Mapping

Color mapping achieves the best possible color matching to the Digital
Equipment Corporation's existing color products. The Companion Color
Printer can print color images from a palette of 256 colors in both
DEC and PCL mode. See Section 2.3.2.4 to get a color palette display.

The color maps provide a 256 color mode and a 64 color mode. The 64
color maps are identical to the VT241 terminal9s HLS and RGB color
maps.

NOTE: While the Companion Color Printer prints color images, it is
primarily intended for the business color graphics market.

See Appendix D for the complete Companion Color Printer color maps.

## Color  mode

### LJ 250 sixel graphics modes

| Resolution       |  Num colors | Colors available                         |
|:----------------:|------------:|------------------------------------------|
| 180  x  180  dpi |   8  colors | Black Yellow Magenta Cyan Red Green Blue |
| 90  x  45  dpi   |  64  colors | DECBCMM: Business Color Matching Mode    |
| 90  x  90  dpi   |  64  colors | (DECBCMM has same colormap as VT241)     |
| 90  x  90  dpi   | 256  colors | (See appendix D)                         |

### LJ 250 Aspect  ratios
* 1  to 1
* 2  to 1
* 2.5  to 1


### LJ 250 Color Palette Display

This self-test prints all 256 colors that the Companion Color Printer
is capable of printing. The palette can be used for verifying the
colors and as a reference to the color numbers. The number on the side
and top of the display indicate the color numbers. See Appendix D for
more details on using the color palette to choose colors.

Procedure:

1. Insert  the  paper.

2. With the power OFF, press the READY and DEC/PCL switches while
   momentarily pressing the POWER switch.

3. Release the READY and DEC/PCL switches.

## 64-Color "Business  Color  Matching  Mode"  (DECBCMM)

The business color matching mode is a DEC private selectable mode and
is used to provide color compatibility with the DIGITAL VT241 terminal
in sixel graphics mode. This map is only available at 90 x 90 and 90 x
45 grid sizes. See Section 6.3.2.2 for more details.

When DECBCMM is reset, the printer uses a 256-color map. See Table D-3
in Appendix D.

| Name           | Mnemonic | Sequence               | Function                             |
|----------------|----------|------------------------|--------------------------------------|
| Business Color | DECBCMM  | CSI    ?   6    5   h  | SET - Limits internal color          |
| Matching Mode  |          | 9/11 3/15 3/6  3/5 6/8 | generation by 64 colors for          |
|                |          |                        | compatibility with the               |
|                |          |                        | Digital VT241 terminal.              |
|----------------|----------|------------------------|--------------------------------------|
|                |          | CSI    ?   6    5   l  | RESET - Enables internal color       |
|                |          | 9/11 3/15 3/6  3/5 3/1 | generation. The number of colors     |
|                |          |                        | supported is device dependent; the   |
|                |          |                        | LJ250/LJ252 printer can generate 256 |
|                |          |                        | colors. (See Appendix D.)            |

Default  =  Reset
