# Character Sets on the VT340

While the DEC VT340 had impressive multilingual capabilities for its
time, it predated Unicode by decades and is tricky to use with current
multilingual software. Instead of a single codepage which contains
millions of characters, there were a multitude of character sets, most
limited to a single byte.

The traditional method used back in the 1980s and 1990s was to either
supplement the 7-bit US ASCII character set with accented characters
using an 8-bit code, such as Latin-1, or to replace the US ASCII
character set completely [XXX check this] with a "national" one, such
as "Greek" or "Hebrew". The VT340 has tables and fonts for 24
different regions and can show four of them [XXX test this] on the
screen simultaneously.

DEC uses the terms "GL" and "GR" to refer to currently active
character sets for the "graphic" characters on the "left" and "right"
of an 8-bit character table. The left contains the usual 7-bit ASCII
and the right contains the bytes with the high-bit set.

<ul>

_Note that "graphic" here just means "visible" and is used to
differentiate from "control" characters in the table, whose meaning
does not change with GL and GR._

</ul>

[TODO: Verify my understanding is correct and make a diagram showing
the relationship of GL, GR with G0, G1, G2, G3 and with the different
character sets.]

## Latin-1 and friends

The VT340's setup menu does not allow setting GL and GR directly, but
one can change the displayed character set, which does the same thing.
For example, the author of this page (hackerb9) prefers to use Latin-1
and sets the environment variable `LANG` to en_US.iso88591 to inform
programs to display characters correctly. (Note: for LANG to work,
modern systems often require uncommenting iso88591 in /etc/locale.gen
and then re-running `sudo locale-gen`). 

<ul>

``` bash
export LANG=$(locale -a 2>&- | egrep -s 8859.*15?$ | head -1)
[ "$LANG" ] || export LANG=C    # No Latin-1, so fallback to "C"
```

</ul>

## "Shifting" (multibyte characters)

While that works for single-byte character sets, the VT340 can
simultaneously show characters that are beyond those 8-bits by using
multiple bytes per character via "shifting".

<ul>
* Quick shifting example (partial differential):

  ```bash
  $ echo $'\e+>'
  $ echo $'\eO\x64'
  ∂
  ```
</ul>

To make things slightly confusing, in order to shift the character set
the VT340 has four variables G0, G1, G2, and G3 which the user (or a
program) defines to point to specific translation tables. In the
example above, the first line selected "DEC Technical Character Set"
for G3. The second line instructed the VT340 to temporarily shift in
G3 and show codepoint 0x64, which happens to be "∂" in DEC Tech (and
"d" in ASCII).

[TODO: Add in how G0 is special. It's the default character set, right?]

## Character Set Selection

To make a character set available, it first must be designated as
either G0, G1, G2, or G3. The designated set is then invoked into "GL"
or "GR" using single or locking shift before use. As mentioned above,
GL means "Graphic Left" and contains the single-byte characters in
which the high bit is cleared, x<=127. GR is analogous, with the high
bit set: 128 <= x <= 255.

### Single and Locking Shifts

A single shift (SS2 or SS3), effects only the first printable GL
character following the single shift sequence.

A locking shift (LS2, LS3, LS1R, LS2R, or LS3R) persists until another
locking shift is invoked.

### Select active character sets 

Here are the escape sequences for for Single and Locking Shifts:

<ul>

| Name                  | Mnemonic | Sequence | Hex   | Function                                                          |
|-----------------------|----------|----------|-------|-------------------------------------------------------------------|
| Single Shift 2        | SS2      | ESC N    | 1B 4E | The character that follows SS2 selects from the G2 character set. |
| Single Shift 3        | SS3      | ESC O    | 1B 4F | The character that follows SS3 selects from the G3 character set. |
| Locking Shift 0       | LS0      | \<SI\>   | 0F    | The G0 character set becomes the active GL character set.         |
| Locking Shift 1       | LS1      | \<SO\>   | 0E    | The G1 character set becomes the active GL character set.         |
| Locking Shift 2       | LS2      | ESC n    | 1B 6E | The G2 character set becomes the active GL character set.         |
| Locking Shift 3       | LS3      | ESC o    | 1B 6F | The G3 character set becomes the active GL character set.         |
| Locking Shift 1 Right | LS1R     | ESC ~    | 1B 7E | The G1 character set becomes the active GR character set.         |
| Locking Shift 2 Right | LS2R     | ESC }    | 1B 7D | The G2 character set becomes the active GR character set.         |
| Locking Shift 3 Right | LS3R     | ESC\|    | 1B 7C | The G3 character set becomes the active GR character set.         |

</ul>



## Select Character Set Sequences (SCS)


The Select Character Set sequence (SCS) assigns a character set to the
G0, G1, G2, or G3 character set designators. This table gives the
sequences that select the available 94-Character Sets. The following
table gives the sequences that select the available 96-Character Sets.


#### Selecting 94-Character Sets Using Single and Locking Shifts

<ul>

| Character Set        | G0              | G1              | G2                | G3              |
|----------------------|-----------------|-----------------|-------------------|-----------------|
| U.S. ASCII           | ESC(B           | ESC)B           | ESC\*B            | ESC+B           |
| DEC Finnish          | ESC(5           | ESC)5           | ESC\*5            | ESC+5           |
| French (France)      | ESC(R           | ESC)R           | ESC\*R            | ESC+R           |
| DEC French Canadian  | ESC(9           | ESC)9           | ESC\*9            | ESC+9           |
| German               | ESC(K           | ESC)K           | ESC\*K            | ESC+K           |
| Italian              | ESC(Y           | ESC)Y           | ESC\*Y            | ESC+Y           |
| JIS Roman            | ESC(J           | ESC)J           | ESC\*J            | ESC+J           |
| DEC Norwegian/Dutch  | ESC(6           | ESC)6           | ESC\*6            | ESC+6           |
| Spanish              | ESC(Z           | ESC)Z           | ESC\*Z            | ESC+Z           |
| DEC Swedish          | ESC(7           | ESC)7           | ESC\*7            | ESC+7           |
| DEC Great Britain    | ESC(A           | ESC)A           | ESC\*A            | ESC+A           |
| ISO Norwegian/Danish | ESC(‘           | ESC)’           | ESC\*’            | ESC+’           |
| DEC Dutch            | ESC(4           | ESC)4           | ESC\*4            | ESC+4           |
| DEC Swiss            | ESC(=           | ESC)=           | ESC\*=            | ESC+=           |
| DEC Portuguese       | ESC(%6          | ESC)%6          | ESC\*%6           | ESC+%6          |
| VT100 Graphics       | ESC(0           | ESC)0           | ESC\*0            | ESC+0           |
| DEC Supplemental     | ESC(%5 or ESC(< | ESC)%5 or ESC)< | ESC\*%5 or ESC\*< | ESC+%5 or ESC+< |
| DEC Technical        | ESC(>           | ESC)>           | ESC\*>            | ESC+>           |
| ISO Katakana         | ESC(I           | ESC)I           | ESC\*I            | ESC+I           |
| 7-Bit Hebrew         | ESC(%=          | ESC)%=          | ESC\*%=           | ESC+%           |
| 7-Bit Turkish        | ESC(%2          | ESC)%2          | ESC\*%2           | ESC+%2          |
| Greek Supplemental   | ESC(“?          | ESC)”?          | ESC\*”?           | ESC+”?          |
| Hebrew Supplemental  | ESC(“4          | ESC)”4          | ESC\*”4           | ESC+”4          |
| Turkish Supplemental | ESC(%0          | ESC)%0          | ESC\*%0           | ESC+%0          |


</ul>


#### Selecting 96-Character Sets Using Single and Locking Shifts

<ul>

| Character Set | G0 | G1    | G2    | G3    |
|---------------|----|-------|-------|-------|
| ISO Latin 1   |    | ESC-A | ESC.A | ESC/A |
| ISO Latin 2   |    | ESC-B | ESC.B | ESC/B |
| ISO Latin 5   |    | ESC-M | ESC.M | ESC/M |
| ISO Latin 9*  |    | ESC-b | ESC.b | ESC/b |
| ISO Cyrillic  |    | ESC-L | ESC.L | ESC/L |
| ISO Greek     |    | ESC-F | ESC.F | ESC/F |
| ISO Hebrew    |    | ESC-H | ESC.H | ESC/H |

* The VT340 does not support Latin 9

</ul>


