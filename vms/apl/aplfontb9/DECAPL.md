# DEC APL Character Set

|    | _0 | _1 | _2 | _3 | _4 | _5 | _6 | _7 | _8 | _9 | _A | _B | _C | _D | _E | _F |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| 2_ |    | ¨  | ≤  | ∨  | ∧  | ≠  | ÷  | ×  | ¯  | ⍺  | ⊥  | ∩  | ⌊  | ∊  | ∇  | ∆  |
| 3_ | ⍳  | ∘  | ⎕  | ⊤  | ○  | ⍴  | ⌈  | ↓  | ∪  | ⍵  | ⊃  | ⊂  | ←  | ⊢  | →  | ≥  |
| 4_ | ⋄  | ⊣  | ⍙  | 𝐴  | 𝐵  | 𝐶  | 𝐷  | 𝐸  | 𝐹  | 𝐺  | 𝐻  | 𝐼  | 𝐽  | 𝐾  | 𝐿  | 𝑀  |
| 5_ | 𝑁  | 𝑂  | 𝑃  | 𝑄  | 𝑅  | 𝑆  | 𝑇  | 𝑈  | 𝑉  | 𝑊  | 𝑋  | 𝑌  | 𝑍  | ⍝  | ⌶  | ⍎  |
| 6_ | ⍕  | ⌹  | ⍇  | ⍈  | ⍞  | ⍌  | ⍋  | ⍒  | ⍫  | ⍱  | ⍲  | ⍟  | ⊖  | ⍉  | ⌽  | ⍪  |
| 7_ | ⌿  | ⍀  | ⊆  | ⊇  | ≡  | ↑  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ␄  | ⌷  |    |

This is the character set which is embedded in the [fonts](README.md)
which DEC included with APL for the VAX circa 1990 as documented in
the [Users Guide][APLUG]. Note that this differs from both the
character set APL uses internally and from the older chart in DEC STD
107 (1980).

[APLUG]: ../PDF_DOCS/AA-P142E-TE_VAX_APL_Users_Guide_Jun91_text.pdf "APL Users' Guide (1991)"

To display an APL character, send its GL/ASCII character after **LS1**
(0x0E) and before **LS0** (0x0F). The "GR" column is only used if GR
is set to point to G1 (see Composite APL Character Set below).

| Character | Name                     | GL | ASCII | GR | DEC name              | TTY |
|-----------|--------------------------|----|-------|----|-----------------------|-----|
| ¨         | Diaeresis                | 21 | !     | a1 | Double Dots           | .DD |
| ≤         | Less than or Equal to    | 22 | "     | a2 | Less than or Equal    | .LE |
| ∨         | Or                       | 23 | #     | a3 | Or                    | .OR |
| ∧         | And                      | 24 | $     | a4 | And                   | \&  |
| ≠         | Not Equal To             | 25 | %     | a5 | Not Equal to          | .NE |
| ÷         | Divide                   | 26 | &     | a6 | Divide                | \%  |
| ×         | Times                    | 27 | '     | a7 | Times                 | \#  |
| ¯         | High Minus               | 28 | (     | a8 | Negation              | .NG |
| ⍺         | Alpha                    | 29 | )     | a9 | Alpha                 | .AL |
| ⊥         | Up Tack                  | 2a | \*    | aa | Base (Decode)         | .DE |
| ∩         | Intersection             | 2b | +     | ab | Down U _[sic]_        | .DU |
| ⌊         | Downstile                | 2c | ,     | ac | Floor                 | .FL |
| ∊         | Element of               | 2d | -     | ad | Epsilon               | .EP |
| ∇         | Del                      | 2e | .     | ae | Del                   | .DL |
| ∆         | Delta                    | 2f | /     | af | Lower Del             | .LD |
| ⍳         | Iota                     | 30 | 0     | b0 | Iota                  | .IO |
| ∘         | Jot                      | 31 | 1     | b1 | Jot (Small O)         | .SO |
| ⎕         | Quad                     | 32 | 2     | b2 | Box                   | .BX |
| ⊤         | Down Tack                | 33 | 3     | b3 | Represent (Encode)    | .EN |
| ○         | Circle                   | 34 | 4     | b4 | Circle (Large O)      | .LO |
| ⍴         | Rho                      | 35 | 5     | b5 | Rho                   | .RO |
| ⌈         | Upstile                  | 36 | 6     | b6 | Ceiling               | .CE |
| ↓         | Drop                     | 37 | 7     | b7 | Down Arrow            | .DA |
| ∪         | Union                    | 38 | 8     | b8 | Up U                  | .UU |
| ⍵         | Omega                    | 39 | 9     | b9 | Omega                 | .OM |
| ⊃         | Right Shoe               | 3a | :     | ba | Right U               | .RU |
| ⊂         | Left Shoe                | 3b | ;     | bb | Left U                | .LU |
| ←         | Gets                     | 3c | \<    | bc | Left arrow            | \_  |
| ⊢         | Right Tack               | 3d | =     | bd | Left Tack _[sic]_     | .LK |
| →         | Goto                     | 3e | >     | be | Right arrow (Go to)   | .GO |
| ≥         | Greater than or Equal to | 3f | ?     | bf | Greater than or Equal | .GE |
| ⋄         | Diamond                  | 40 | @     | c0 | Diamond               | .DM |
| ⊣         | Left Tack                | 41 | A     | c1 | Right Tack _[sic]_    | .RK |
| ⍙         | Delta Underbar           | 42 | B     | c2 | Underscored Delta     | .UD |
| 𝐴         | Underlined CAPITAL A     | 43 | C     | c3 | Underscored A         | .ZA |
| 𝐵         | Underlined CAPITAL B     | 44 | D     | c4 | Underscored B         | .ZB |
| 𝐶         | Underlined  CAPITAL C    | 45 | E     | c5 | Underscored  C        | .ZC |
| 𝐷         | Underlined  CAPITAL D    | 46 | F     | c6 | Underscored  D        | .ZD |
| 𝐸         | Underlined  CAPITAL E    | 47 | G     | c7 | Underscored  E        | .ZE |
| 𝐹         | Underlined  CAPITAL F    | 48 | H     | c8 | Underscored  F        | .ZF |
| 𝐺         | Underlined  CAPITAL G    | 49 | I     | c9 | Underscored  G        | .ZG |
| 𝐻         | Underlined  CAPITAL H    | 4a | J     | ca | Underscored  H        | .ZH |
| 𝐼         | Underlined  CAPITAL I    | 4b | K     | cb | Underscored  I        | .ZI |
| 𝐽         | Underlined  CAPITAL J    | 4c | L     | cc | Underscored  J        | .ZJ |
| 𝐾         | Underlined  CAPITAL K    | 4d | M     | cd | Underscored  K        | .ZK |
| 𝐿         | Underlined  CAPITAL L    | 4e | N     | ce | Underscored  L        | .ZL |
| 𝑀         | Underlined  CAPITAL M    | 4f | O     | cf | Underscored  M        | .ZM |
| 𝑁         | Underlined  CAPITAL N    | 50 | P     | d0 | Underscored  N        | .ZN |
| 𝑂         | Underlined  CAPITAL O    | 51 | Q     | d1 | Underscored  O        | .ZO |
| 𝑃         | Underlined  CAPITAL P    | 52 | R     | d2 | Underscored  P        | .ZP |
| 𝑄         | Underlined  CAPITAL Q    | 53 | S     | d3 | Underscored  Q        | .ZQ |
| 𝑅         | Underlined  CAPITAL R    | 54 | T     | d4 | Underscored  R        | .ZR |
| 𝑆         | Underlined  CAPITAL S    | 55 | U     | d5 | Underscored  S        | .ZS |
| 𝑇         | Underlined  CAPITAL T    | 56 | V     | d6 | Underscored  T        | .ZT |
| 𝑈         | Underlined  CAPITAL U    | 57 | W     | d7 | Underscored  U        | .ZU |
| 𝑉         | Underlined  CAPITAL V    | 58 | X     | d8 | Underscored  V        | .ZV |
| 𝑊         | Underlined  CAPITAL W    | 59 | Y     | d9 | Underscored  W        | .ZW |
| 𝑋         | Underlined  CAPITAL X    | 5a | Z     | da | Underscored  X        | .ZX |
| 𝑌         | Underlined  CAPITAL Y    | 5b | [     | db | Underscored  Y        | .ZY |
| 𝑍         | Underlined  CAPITAL Z    | 5c | \\    | dc | Underscored Z         | .ZZ |
| ⍝         | Lamp                     | 5d | ]     | dd | Lamp (Comment)        | \"  |
| ⌶         | I-Beam                   | 5e | ^     | de | I-Beam                | .IB |
| ⍎         | Hydrant                  | 5f | \_    | df | Hydrant (Execute)     | .XQ |
| ⍕         | Thorn                    | 60 | `     | e0 | Thorn (Format)        | .FM |
| ⌹         | Domino                   | 61 | a     | e1 | Divide Quad           | .DQ |
| ⍇         | Quad Left Arrow          | 62 | b     | e2 | Input Quad            | .IQ |
| ⍈         | Quad Right Arrow         | 63 | c     | e3 | Output Quad           | .OQ |
| ⍞         | Quote Quad               | 64 | d     | e4 | Quote Quad            | .QQ |
| ⍌         | Quad Down Caret          | 65 | e     | e5 | Quad Del              | .QD |
| ⍋         | Grade Up                 | 66 | f     | e6 | Grade Up              | .GU |
| ⍒         | Grade Down               | 67 | g     | e7 | Grade Down            | .GD |
| ⍫         | Del Tilde                | 68 | h     | e8 | Protected Del         | .PD |
| ⍱         | Nor                      | 69 | i     | e9 | Nor                   | .NR |
| ⍲         | Nand                     | 6a | j     | ea | Nand                  | .NN |
| ⍟         | Log                      | 6b | k     | eb | Logarithm             | .LG |
| ⊖         | Circle Bar               | 6c | l     | ec | Column Reverse        | .CR |
| ⍉         | Transpose                | 6d | m     | ed | Transpose             | .TR |
| ⌽         | Circle Stile             | 6e | n     | ee | Reverse               | .RV |
| ⍪         | Comma Bar                | 6f | o     | ef | Column Comma          | .CC |
| ⌿         | Slash Bar                | 70 | p     | f0 | Column Slash          | .CS |
| ⍀         | Slope Bar                | 71 | q     | f1 | Column Backslash      | .CB |
| ⊆         | Left Shoe Underbar       | 72 | r     | f2 | Subset                | .SS |
| ⊇         | Right Shoe Underbar      | 73 | s     | f3 | Contains              | .CO |
| ≡         | Equal Underbar           | 74 | t     | f4 | Match                 | .MT |
| ↑         | Up Arrow                 | 75 | u     | f5 | Up Arrow              | \^  |
| ⌷         | Squad                    | 76 | v     | f6 | Squish Quad           | .SQ |
| ⌷         | Squad                    | 77 | w     | f7 |                       |     |
| ⌷         | Squad                    | 78 | x     | f8 |                       |     |
| ⌷         | Squad                    | 79 | y     | f9 |                       |     |
| ⌷         | Squad                    | 7a | z     | fa |                       |     |
| ⌷         | Squad                    | 7b | {     | fb |                       |     |
| ⌷         | Squad                    | 7c | \|    | fc |                       |     |
| ␄         | OUT                      | 7d | }     | fd | _[Unused]_            |     |
| ⌷         | Squad                    | 7e | ~     | fe | Squish Quad           | .SQ |


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

### Escape codes to set up

To replicate the Composite APL setup, one would first load the APL
font (by catting it to the screen) which names the font Dscs `&0` and
then maps it to G1. (`ESC` `)` `&` `0`). Then one would use these
escape codes:

| Set | Mapping          | Escape sequence                |
|-----|------------------|--------------------------------|
| G0  | ASCII            | `ESC` `(` `B`                  |
| G1  | APL              | `ESC` `)` `&` `0`              |
| G2  | Latin-1 or MCS   | `ESC` `.` `A` or `ESC` `(` `<` |
| G3  | Special Graphics | `ESC` `+` `0`                  |
| GL  | G0               | `0x0F`                         |
| GR  | G1               | `ESC` `~`                      |

### APL in GR

If I'm reading the manual correctly, GR, the active 8-bit character
set, was changed to point to G1 (APL) instead of G2 (Latin-1).
Meaning, the APL program used bytes with the high-bit set to show APL
instead of shifts (LS0, LS1). This technique would not work in a
modern terminal which supports UTF-8. 

Here are the hexadecimal codes for APL when shifted into GR.


|    | _0 | _1 | _2 | _3 | _4 | _5 | _6 | _7 | _8 | _9 | _A | _B | _C | _D | _E | _F |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| A_ |    | ¨  | ≤  | ∨  | ∧  | ≠  | ÷  | ×  | ¯  | ⍺  | ⊥  | ∩  | ⌊  | ∊  | ∇  | ∆  |
| B_ | ⍳  | ∘  | ⎕  | ⊤  | ○  | ⍴  | ⌈  | ↓  | ∪  | ⍵  | ⊃  | ⊂  | ←  | ⊢  | →  | ≥  |
| C_ | ⋄  | ⊣  | ⍙  | 𝐴  | 𝐵  | 𝐶  | 𝐷  | 𝐸  | 𝐹  | 𝐺  | 𝐻  | 𝐼  | 𝐽  | 𝐾  | 𝐿  | 𝑀  |
| D_ | 𝑁  | 𝑂  | 𝑃  | 𝑄  | 𝑅  | 𝑆  | 𝑇  | 𝑈  | 𝑉  | 𝑊  | 𝑋  | 𝑌  | 𝑍  | ⍝  | ⌶  | ⍎  |
| E_ | ⍕  | ⌹  | ⍇  | ⍈  | ⍞  | ⍌  | ⍋  | ⍒  | ⍫  | ⍱  | ⍲  | ⍟  | ⊖  | ⍉  | ⌽  | ⍪  |
| F_ | ⌿  | ⍀  | ⊆  | ⊇  | ≡  | ↑  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ⌷  | ␄  | ⌷  |    |
