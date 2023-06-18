# Sixel image comments

While comments cannot be embedded with the Device Control String (DCS)
envelope which contains the sixel bitmap data, sixel images are not
limited to a single DCS string. Since any unknown type of DCS string
will be ignored by a terminal, it is an ideal way to add comments.

After discussing the problem with @j4james, hackerb9 proposes the
following method of embedding comments in sixel image files. Prepend
to the file a DCS string with the comment embedded in it:

* **SIXCOM**: `Esc` `P` `/` `/` `~` _comment_ `Esc` `\`

* The _comment_ itself can be any arbitrary text, but since we don't
  want to add more DCS strings in the future, it would be best if it
  was structured to allow for different metadata tags. It is suggested
  that an identifier starting from the beginning of a line until an
  equals sign be used for marking tags. (This is similar to the
  commenting style in Vorbis files.) For example:
      Esc P//~COMMENT=This is a comment Esc \
  
* For ease of reading the comments on a terminal, adding newlines at
  the beginning and end of _comment_ is encouraged, but not required.
  Note that one cannot add whitespace outside of the DCS string as it
  would affect how the sixel image is rendered. 
  
      Esc P//~
	  COMMENT=Wow! Look at that beautiful whitespace. 
	  Esc \

* Example file with embedded comments: [comment.six](comment.six).

# Discussion

## What's a Device Control String?

DEC says that “device control strings, like control sequences, use two
or more bytes to define specific functions. However, a DCS also
includes a data string.”

The ANSI definition of a device control string is quite loose, only
specifying that it must be terminated by ST (String Terminator). DEC
uses a stricter definition which specifies escape-sequence-like
Parameters, Intermediates, and a Final character before the Data
String.

| DCS   | Parameters (optional)            | Intermediates (optional)          | Final       | Data String                   | ST     |
|-------|----------------------------------|-----------------------------------|-------------|-------------------------------|--------|
| 0x90  | 0x30..0x3F                       | 0x20..0x2F                        | 0x40..0x7E  | Arbitrary data separated by ; | 0x9C   |
| Esc P | 0 1 2 3 4 5 6 7 8 9 : ; \< = > ? | Sp ! " # $ % & ' ( ) \* + , - . / | @ A B C D   | \*\*\*\*\*\*\*\*              | Esc \\ |
|       |                                  |                                   | E F G H I   |                               |        |
|       |                                  |                                   | J K L M N   |                               |        |
|       |                                  |                                   | O P Q R S   |                               |        |
|       |                                  |                                   | T U V W X   |                               |        |
|       |                                  |                                   | Y Z [ \\ ]  |                               |        |
|       |                                  |                                   | ^ \_ \` a b |                               |        |
|       |                                  |                                   | c d e f g   |                               |        |
|       |                                  |                                   | h i j k l   |                               |        |
|       |                                  |                                   | m n o p q   |                               |        |
|       |                                  |                                   | r s t u v   |                               |        |
|       |                                  |                                   | w x y z     |                               |        |
|       |                                  |                                   | { \| } ~    |                               |        |

However, only the Finals in the range from `p` to `~` are specifically
allowed for anyone to use. The rest are reserved for future standardization.

### Which DCS strings are unused?

The purpose of a DCS string is defined by its "Final" character and
its Intermediate (if any). For example, sixel image data uses the
letter "q" with no Intermediate. Here are the DCS strings hackerb9 has
been able to discover so far:

| Mnemonic | Intermediate | Final | Meaning                                          |
|----------|-------------:|-------|--------------------------------------------------|
|          |              | p     | ReGIS graphics                                   |
| DECRSTS  |            $ | p     | Restore Terminal State                           |
|          |              | q     | Sixel graphics                                   |
| DECRQSS  |            $ | q     | Request Selection or Setting                     |
| DECLBAN  |              | r     | Load Banner Message                              |
| DECRPSS  |            $ | r     | Report Selection or Setting                      |
| DECTSR   |            $ | s     | Response to Terminal State Report                |
|          |              | t     | VT105 waveform graphics (for VT125)              |
| DECRSPS  |            $ | t     | Restore Presentation State                       |
| DECAUPSS |            ! | u     | Assign User Preferred Supplemental Character Set |
| DECCIR   |           1$ | u     | Cursor Information Report                        |
| DECTABSR |           2$ | u     | Tabulation Stop Report                           |
| DECLANS  |              | v     | Load Answerback Message                          |
| DECPFK   |            " | x     | Program Function Key                             |
| DECPAK   |            " | y     | Program Alphanumeric Key                         |
| DECDMAC  |            ! | z     | Define Macro                                     |
| DECCKD   |            " | z     | Copy Key Default                                 |
| DECRPTUI |            ! | \|    | Report Terminal Unit ID (DA3)                    |
| DECUDK   |              | \|    | Download User Defined Keys                       |
| DECSTUI  |            ! | {     | Set Terminal Unit ID                             |
| DECDLD   |              | {     | Down-line Load Font                              |
| DECRPFK  |            " | }     | Report Function Key Definition                   |
| DECRPAK  |            " | ~     | Report All Modifers/Key State                    |
| DECCKSR  |            ! | ~     | Response to Checksum Request                     |

As can be seen, all the Final characters which ANSI specifically
allowed for 3rd party use (`p` to `~`) have been used by DEC or
others, so we'll need to add an intermediate. Although chances of a
collision are low, we could add two intermediates to make absolutely
sure, although with the trade-off that some terminal emulators may not
correctly handle two intermediates. 


### Precedent for sixel files to contain multiple escape sequences

How do we know it is valid to concatenate multiple control sequences
in one sixel image? Because DEC included arbitrary ANSI escape
sequences in the sixel images generated by the VT340.

For example, in response to a [MediaCopy](../mediacopy/README.md) to
Host request, the VT340 returns a sixel image which includes the ANSI
SSU sequence which defines the DPI of the following image. (Side note:
yes, the sixel control string also includes DPI information, but not
all sixel engines properly implement Level 2 sixel parameters.).

A sixel image can also be made up of multiple, different DCS
sequences. For example, @j4james found that [a sixel image of Bill The
Cat](https://github.com/hackerb9/vt340test/issues/30) that was posted
online in 1989 uses a ReGIS DCS to change the color palette. The
poster (Chris F. Chiesa) stated that it was more compatible that way
because early VT240 firmware did not handle sixel color palettes
correctly.

	EscPpS(M0(H280L35S60))Esc\
	EscPpS(M1(H0L0S0))Esc\
	EscPpS(M2(H120L50S100))Esc\
	EscPpS(M3(H0L99S0))Esc\

The WordPerfect for [VMS demo file](../kermitdemos/DEMO.SIX) (at least
the version I found included with MS Kermit) contains seventeen DCS
strings, each of the first sixteen shows a colored rectangle on
the screen and the last changes the colormap of all of them.

![16 colored squares](../kermitdemos/demo2.png "Word Perfect Demo for Sixel")

