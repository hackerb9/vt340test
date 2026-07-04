# DEC APL Character Set

|    | _0 | _1 | _2 | _3 | _4 | _5 | _6 | _7 | _8 | _9 | _A | _B | _C | _D | _E | _F |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| 2_ |    | ¨  | ≤  | ∨  | ∧  | ≠  | ÷  | ×  | ¯  | ⍺  | ⊥  | ∩  | ⌊  | ∊  | ∇  | ∆  |
| 3_ | ⍳  | ∘  | ⎕  | ⊤  | ○  | ⍴  | ⌈  | ↓  | ∪  | ⍵  | ⊃  | ⊂  | ←  | ⊢  | →  | ≥  |
| 4_ | ⋄  | ⊣  | ⍙  | 𝐴̲  | 𝐵̲  | 𝐶̲  | 𝐷̲  | 𝐸̲  | 𝐹̲  | 𝐺̲  | 𝐻̲  | 𝐼̲  | 𝐽̲  | 𝐾̲  | 𝐿̲  | 𝑀̲  |
| 5_ | 𝑁̲  | 𝑂̲  | 𝑃̲  | 𝑄̲  | 𝑅̲  | 𝑆̲  | 𝑇̲  | 𝑈̲  | 𝑉̲  | 𝑊̲  | 𝑋̲  | 𝑌̲  | 𝑍̲  | ⍝  | ⌶  | ⍎  |
| 6_ | ⍕  | ⌹  | ⍇  | ⍈  | ⍞  | ⍌  | ⍋  | ⍒  | ⍫  | ⍱  | ⍲  | ⍟  | ⊖  | ⍉  | ⌽  | ⍪  |
| 7_ | ⌿  | ⍀  | ⊆  | ⊇  | ≡  | ↑  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ␄  | ⌷  |    |

This is the 7-bit character set which is embedded in the
[fonts](README.md) which DEC included with APL for the VAX circa 1990
as documented in the [Users Guide][APLUG]. 

Note that this differs from both the character set VAX APL uses internally
and from the older chart in DEC STD 107 (1980). It can be used as an
8-bit charset by setting GR to G1 (see [Composite APL Character Set] below).

[APLUG]: https://hackerb9.github.io/vt340test/vms/apl/PDF_DOCS/AA-P142E-TE_VAX_APL_Users_Guide_Jun91_text.pdf "APL Users' Guide (1991)"

To display an APL character, send its GL/ASCII character after **LS1**
(0x0E) and before **LS0** (0x0F). 

| Character | GL | ASCII | Common Name              | DEC VAX APL name      | TTY<br/>input | GR<br/>(8-bit) |
|-----------|----|-------|--------------------------|-----------------------|---------------|----------------|
| ¨         | 21 | !     | Dieresis                 | Double Dots           | .DD           | a1             |
| ≤         | 22 | "     | Less than or Equal to    | Less than or Equal    | .LE           | a2             |
| ∨         | 23 | #     | Or                       | Or                    | .OR           | a3             |
| ∧         | 24 | $     | And                      | And                   | \&            | a4             |
| ⍺         | 29 | )     | Alpha                    | Alpha                 | .AL           | a9             |
| ⊥         | 2a | \*    | Up Tack                  | Base (Decode)         | .DE           | aa             |
| ∩         | 2b | +     | Intersection             | Down U _[sic]_        | .DU           | ab             |
| ⌊         | 2c | ,     | Downstile                | Floor                 | .FL           | ac             |
| ∊         | 2d | -     | Element of               | Epsilon               | .EP           | ad             |
| ∇         | 2e | .     | Del                      | Del                   | .DL           | ae             |
| ∆         | 2f | /     | Delta                    | Lower Del             | .LD           | af             |
| ⍳         | 30 | 0     | Iota                     | Iota                  | .IO           | b0             |
| ∘         | 31 | 1     | Jot                      | Jot (Small O)         | .SO           | b1             |
| ⎕         | 32 | 2     | Quad                     | Box                   | .BX           | b2             |
| ⊤         | 33 | 3     | Down Tack                | Represent (Encode)    | .EN           | b3             |
| ○         | 34 | 4     | Circle                   | Circle (Large O)      | .LO           | b4             |
| ⍴         | 35 | 5     | Rho                      | Rho                   | .RO           | b5             |
| ⌈         | 36 | 6     | Upstile                  | Ceiling               | .CE           | b6             |
| ↓         | 37 | 7     | Drop                     | Down Arrow            | .DA           | b7             |
| ∪         | 38 | 8     | Union                    | Up U                  | .UU           | b8             |
| ⍵         | 39 | 9     | Omega                    | Omega                 | .OM           | b9             |
| ⊃         | 3a | :     | Right Shoe               | Right U               | .RU           | ba             |
| ⊂         | 3b | ;     | Left Shoe                | Left U                | .LU           | bb             |
| ←         | 3c | \<    | Gets                     | Left arrow            | \_            | bc             |
| ⊢         | 3d | =     | Right Tack               | Left Tack _[sic]_     | .LK           | bd             |
| →         | 3e | >     | Goto                     | Right arrow (Go to)   | .GO           | be             |
| ≥         | 3f | ?     | Greater than or Equal to | Greater than or Equal | .GE           | bf             |
| ⋄         | 40 | @     | Diamond                  | Diamond               | .DM           | c0             |
| ⊣         | 41 | A     | Left Tack                | Right Tack _[sic]_    | .RK           | c1             |
| ⍙         | 42 | B     | Delta Underbar           | Underscored Delta     | .UD           | c2             |
| 𝐴         | 43 | C     | Underlined CAPITAL A     | Underscored A         | .ZA           | c3             |
| 𝐵         | 44 | D     | Underlined CAPITAL B     | Underscored B         | .ZB           | c4             |
| 𝐶         | 45 | E     | Underlined  CAPITAL C    | Underscored  C        | .ZC           | c5             |
| 𝐷         | 46 | F     | Underlined  CAPITAL D    | Underscored  D        | .ZD           | c6             |
| 𝐸         | 47 | G     | Underlined  CAPITAL E    | Underscored  E        | .ZE           | c7             |
| 𝐹         | 48 | H     | Underlined  CAPITAL F    | Underscored  F        | .ZF           | c8             |
| 𝐺         | 49 | I     | Underlined  CAPITAL G    | Underscored  G        | .ZG           | c9             |
| 𝐻         | 4a | J     | Underlined  CAPITAL H    | Underscored  H        | .ZH           | ca             |
| 𝐼         | 4b | K     | Underlined  CAPITAL I    | Underscored  I        | .ZI           | cb             |
| 𝐽         | 4c | L     | Underlined  CAPITAL J    | Underscored  J        | .ZJ           | cc             |
| 𝐾         | 4d | M     | Underlined  CAPITAL K    | Underscored  K        | .ZK           | cd             |
| 𝐿         | 4e | N     | Underlined  CAPITAL L    | Underscored  L        | .ZL           | ce             |
| 𝑀         | 4f | O     | Underlined  CAPITAL M    | Underscored  M        | .ZM           | cf             |
| 𝑁         | 50 | P     | Underlined  CAPITAL N    | Underscored  N        | .ZN           | d0             |
| 𝑂         | 51 | Q     | Underlined  CAPITAL O    | Underscored  O        | .ZO           | d1             |
| 𝑃         | 52 | R     | Underlined  CAPITAL P    | Underscored  P        | .ZP           | d2             |
| 𝑄         | 53 | S     | Underlined  CAPITAL Q    | Underscored  Q        | .ZQ           | d3             |
| 𝑅         | 54 | T     | Underlined  CAPITAL R    | Underscored  R        | .ZR           | d4             |
| 𝑆         | 55 | U     | Underlined  CAPITAL S    | Underscored  S        | .ZS           | d5             |
| 𝑇         | 56 | V     | Underlined  CAPITAL T    | Underscored  T        | .ZT           | d6             |
| 𝑈         | 57 | W     | Underlined  CAPITAL U    | Underscored  U        | .ZU           | d7             |
| 𝑉         | 58 | X     | Underlined  CAPITAL V    | Underscored  V        | .ZV           | d8             |
| 𝑊         | 59 | Y     | Underlined  CAPITAL W    | Underscored  W        | .ZW           | d9             |
| 𝑋         | 5a | Z     | Underlined  CAPITAL X    | Underscored  X        | .ZX           | da             |
| 𝑌         | 5b | [     | Underlined  CAPITAL Y    | Underscored  Y        | .ZY           | db             |
| 𝑍         | 5c | \\    | Underlined  CAPITAL Z    | Underscored Z         | .ZZ           | dc             |
| ⍝         | 5d | ]     | Lamp                     | Lamp (Comment)        | \"            | dd             |
| ⌶         | 5e | ^     | I-Beam                   | I-Beam                | .IB           | de             |
| ⍎         | 5f | \_    | Hydrant                  | Hydrant (Execute)     | .XQ           | df             |
| ⍕         | 60 | `     | Thorn                    | Thorn (Format)        | .FM           | e0             |
| ⌹         | 61 | a     | Domino                   | Divide Quad           | .DQ           | e1             |
| ⍇         | 62 | b     | Quad Left Arrow          | Input Quad            | .IQ           | e2             |
| ⍈         | 63 | c     | Quad Right Arrow         | Output Quad           | .OQ           | e3             |
| ⍞         | 64 | d     | Quote Quad               | Quote Quad            | .QQ           | e4             |
| ⍌         | 65 | e     | Quad Down Caret          | Quad Del              | .QD           | e5             |
| ⍋         | 66 | f     | Grade Up                 | Grade Up              | .GU           | e6             |
| ⍒         | 67 | g     | Grade Down               | Grade Down            | .GD           | e7             |
| ⍫         | 68 | h     | Del Tilde                | Protected Del         | .PD           | e8             |
| ⍱         | 69 | i     | Nor                      | Nor                   | .NR           | e9             |
| ⍲         | 6a | j     | Nand                     | Nand                  | .NN           | ea             |
| ⍟         | 6b | k     | Log                      | Logarithm             | .LG           | eb             |
| ⊖         | 6c | l     | Circle Bar               | Column Reverse        | .CR           | ec             |
| ⍉         | 6d | m     | Transpose                | Transpose             | .TR           | ed             |
| ⌽         | 6e | n     | Circle Stile             | Reverse               | .RV           | ee             |
| ⍪         | 6f | o     | Comma Bar                | Column Comma          | .CC           | ef             |
| ⌿         | 70 | p     | Slash Bar                | Column Slash          | .CS           | f0             |
| ⍀         | 71 | q     | Slope Bar                | Column Backslash      | .CB           | f1             |
| ⊆         | 72 | r     | Left Shoe Underbar       | Subset                | .SS           | f2             |
| ⊇         | 73 | s     | Right Shoe Underbar      | Contains              | .CO           | f3             |
| ≡         | 74 | t     | Equal Underbar           | Match                 | .MT           | f4             |
| ↑         | 75 | u     | Up Arrow                 | Up Arrow              | \^            | f5             |
| ⌷         | 76 | v     | Squad                    | Squish Quad           | .SQ           | f6             |
| ⌷         | 77 | w     | Squad                    |                       |               | f7             |
| ⌷         | 78 | x     | Squad                    |                       |               | f8             |
| ⌷         | 79 | y     | Squad                    |                       |               | f9             |
| ⌷         | 7a | z     | Squad                    |                       |               | fa             |
| ⌷         | 7b | {     | Squad                    |                       |               | fb             |
| ⌷         | 7c | \|    | Squad                    |                       |               | fc             |
| OUT       | 7d | }     | OUT [_See note 2_]       | _[Unused]_            |               | fd             |
| ⌷         | 7e | ~     | Squad                    | Squish Quad           | .SQ           | fe             |

Note 1: The left/right tack convention changed around the turn of the
century. See "London Convention" versus "Bosworth Convention".

Note 2: The "OUT" character is not present in Unicode nor is it
mentioned in the VAX APL manual. However it _is_ in the font and
discussed online in the APL forums. Normally, the representation is
actually of the letters `O`, `U`, `T` overstruck atop each other, and
that is the case for the VT220 version of the font, however the VT340
version has the letters written in small, non-overlapping, letters at
a diagonal, similar to the graphic ␛ for Escape. 


## Composite APL Character Set

When running VAX APL, the VT340 and other terminals capable of loading
the APL font used what DEC called the "Composite APL Character Set".
The setup is:

| Active | Set | Mapping                    |
|--------|-----|----------------------------|
| GL     | G0  | 7-bit ASCII                |
| GR     | G1  | APL Character Set          |
|        | G2  | Latin-1 (DEC Supplemental) |
|        | G3  | DEC Special Graphics       |

### Escape codes to set up Composite APL

The [VMS APL User's Guide][APLUG] describes Composite Character Set in
Table 1-16, which shows that bytes with the high-bit set display the
APL glyphs. While this would be more convenient compared to constantly
sending shifts (LS0, LS1), this technique would not work in a modern
UTF-8 terminal.

Hackerb9's guess for how to replicate the Composite APL setup: first
load the [APL font](../apl/aplfontb9/APL_VT340.FNT) (by catting it to
the screen) which names the font Dscs `&0` and maps it to G1 (`ESC`
`)` `&` `0`). Then send these escape codes:

| Set | Mapping          | Escape sequence                |
|-----|------------------|--------------------------------|
| G0  | ASCII            | `ESC` `(` `B`                  |
| G1  | APL              | `ESC` `)` `&` `0`              |
| G2  | Latin-1 or MCS   | `ESC` `.` `A` or `ESC` `(` `<` |
| G3  | Special Graphics | `ESC` `+` `0`                  |
| GL  | G0               | `0x0F`                         |
| GR  | G1               | `ESC` `~`                      |

To return to normal, remap GR to point to G2: `ESC` `}`.

### Composite APL table

Based on table 1-16 in the VMS APL User's Guide.

|    | _0  | _1  | _2  | _3  | _4  | _5  | _6  | _7  | _8  | _9  | _A  | _B  | _C  | _D  | _E  | _F  |
|----|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 0_ | ␀   | ␁   | ␂   | ␃   | ␄   | ␅   | ␆   | ␇   | ␈   | ␉   | ␊   | ␋   | ␌   | ␍   | ␎   | ␏   |
| 1_ | ␐   | ␑   | ␒   | ␓   | ␔   | ␕   | ␖   | ␗   | ␘   | ␙   | ␚   | ␛   | ␜   | ␝   | ␞   | ␟   |
| 2_ | ␠   | !   | "   | #   | $   | %   | &   | '   | (   | )   | \*  | +   | ,   | -   | .   | /   |
| 3_ | 0   | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | :   | ;   | \<  | =   | >   | ?   |
| 4_ | @   | A   | B   | C   | D   | E   | F   | G   | H   | I   | J   | K   | L   | M   | N   | O   |
| 5_ | P   | Q   | R   | S   | T   | U   | V   | W   | X   | Y   | Z   | [   | \\  | ]   | ^   | \_  |
| 6_ | \`  | a   | b   | c   | d   | e   | f   | g   | h   | i   | j   | k   | l   | m   | n   | o   |
| 7_ | p   | q   | r   | s   | t   | u   | v   | w   | x   | y   | z   | {   | \|  | }   | ~   | ␡   |
| 8_ | ␢   | ␢   | ␢   | ␢   | IND | NEL | SSA | ESA | HTS | HTJ | VTS | PLD | PLU | RI  | SS2 | SS3 |
| 9_ | DCS | PU1 | PU2 | STS | CCH | MW  | SPA | EPA | ␢   | ␢   | ␢   | CSI | ST  | OSC | PM  | APC |
| A_ | ␢   | ¨   | ≤   | ∨   | ∧   | ≠   | ÷   | ×   | ¯   | ⍺   | ⊥   | ∩   | ⌊   | ∊   | ∇   | ∆   |
| B_ | ⍳   | ∘   | ⎕   | ⊤   | ○   | ⍴   | ⌈   | ↓   | ∪   | ⍵   | ⊃   | ⊂   | ←   | ⊢   | →   | ≥   |
| C_ | ⋄   | ⊣   | ⍙   | 𝐴   | 𝐵   | 𝐶   | 𝐷   | 𝐸   | 𝐹   | 𝐺   | 𝐻   | 𝐼   | 𝐽   | 𝐾   | 𝐿   | 𝑀   |
| D_ | 𝑁   | 𝑂   | 𝑃   | 𝑄   | 𝑅   | 𝑆   | 𝑇   | 𝑈   | 𝑉   | 𝑊   | 𝑋   | 𝑌   | 𝑍   | ⍝   | ⌶   | ⍎   |
| E_ | ⍕   | ⌹   | ⍇   | ⍈   | ⍞   | ⍌   | ⍋   | ⍒   | ⍫   | ⍱   | ⍲   | ⍟   | ⊖   | ⍉   | ⌽   | ⍪   |
| F_ | ⌿   | ⍀   | ⊆   | ⊇   | ≡   | ↑   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   | ⌷   |
|    | **_0**  | **_1**  | **_2**  | **_3**  | **_4**  | **_5**  | **_6**  | **_7**  | **_8**  | **_9**  | **_A**  | **_B**  | **_C**  | **_D**  | **_E**  | **_F**  |

Note 1: ␢ represents characters that are unused.

Note 2: "OUT" is at 0xFD in the font but not shown in the user
guide. 

Note 3: The font does not define 0xFF although the table shows it as a
Squish Quad.
