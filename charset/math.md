# Displaying Mathematics on the VT340

The VT340 can display the **DEC Technical Character Set**, which
contains Greek letters, mathematical symbols, and logical symbols.
Additionally, it contains characters that may be used to construct
larger mathematical symbols on character cell devices, such as large
integral and summation signs. 

XXX example goes here XXX

Also see [dectech.c](dectech.c), a program that shows a table of the
DEC Techncial Character Set and its output, [dectech.txt](dectech.txt)
which can be sent to a terminal such as the VT340 using `cat`.

## Basic usage from a programmer's perspective:

Until someone [hackerb9?] writes a proper locale charmap so that
Unicode can be automatically translated into the DEC Technical
Character Set, these characters will not be available to most users
without a specialized program. However, programmers can display them
easily:

1. Assign the DEC Technical Set to "G3" via SCS (Select Character Set).

   <kbd>Esc</kbd><kbd>+</kbd><kbd>></kbd>

1. Every time you want to print a mathematical character, first send SS3 to
   temporarily shift to G3...
   
   <kbd>Esc</kbd><kbd>O</kbd>

1. And then send an ASCII character from one of the tables below to choose a symbol.

	<kbd>@</kbd>	→ ∴ (Therefore)


## Slightly more detail

### 1. Assign the DEC Tech character set to G3

   <kbd>Esc</kbd><kbd></kbd><kbd>+</kbd><kbd></kbd><kbd>></kbd>

You can actually set any of over a dozen different character sets to
four different translation tables: G0, G1, G2, and G3.

<ul>

| Character Set    | G0    | G1    | G2     | G3    |
|------------------|-------|-------|--------|-------|
| U.S. ASCII       | ESC(B | ESC)B | ESC\*B | ESC+B |
| DEC Technical    | ESC(> | ESC)> | ESC\*> | ESC+> |
| VT100 Graphics   | ESC(0 | ESC)0 | ESC\*0 | ESC+0 |
| DEC Supplemental | ESC(< | ESC)< | ESC\*< | ESC+< |

</ul>

### 2. Send SS3 (non-locking shift to G3)

Renders next character using G3: <kbd>Esc</kbd><kbd>O</kbd>

<ul>

| Name           | Mnemonic | Sequence | Hex   | Function                                          |
|----------------|----------|----------|-------|---------------------------------------------------|
| Single Shift 3 | SS3      | ESC O    | 1B 4F | Use G3 character set just for the next character. |

</ul>

Locking-shifts are also available, see below.

### 3. Send an ASCII character to display a mathematical character

Display the ∴ symbol: <kbd>@</kbd>

<ul>

| Hex | ASCII | Name      | Symbol |
|-----|:-----:|-----------|:------:|
| 40  | @     | Therefore | ∴      |

</ul>

The full tables of symbols can be found below.

### Notes

* Position reserved for future standardization in the DEC technical
  set are shown as the error character ␦ (reverse question mark) both
  on the screen and in print.

* Component characters are imaged so that adjacent component
  characters form connected lines at all pitches. This 
  
* DEC compatible printers work the same way as terminals, using the
  same escape sequences.

## DEC Technical Character Set Tables 

The following tables are taken mostly from the "Printronix LG
Programmers Manual", with corrections, and using Unicode characters
found at https://vt100.net/charsets/technical.html.

### Individual Technical Characters

#### Greek

<ul>

| Hex | ASCII | Name              | Symbol | Unicode |
|-----|:-----:|-------------------|:------:|---------|
| 44  | D     | Uppercase Delta   | Δ      | 0x0394  |
| 46  | F     | Uppercase Phi     | Φ      | 0x03A6  |
| 47  | G     | Uppercase Gamma   | Γ      | 0x0393  |
| 4A  | J     | Uppercase Theta   | Θ      | 0x0398  |
| 4C  | L     | Uppercase Lambda  | Λ      | 0x039B  |
| 50  | P     | Uppercase Pi      | Π      | 0x03A0  |
| 51  | Q     | Uppercase Psi     | Ψ      | 0x03A8  |
| 53  | S     | Uppercase Sigma   | Σ      | 0x03A3  |
| 57  | W     | Uppercase Omega   | Ω      | 0x03A9  |
| 58  | X     | Uppercase Ksi     | Ξ      | 0x039E  |
| 59  | Y     | Uppercase Upsilon | Υ      | 0x03A5  |
| 61  | a     | Lowercase Alpha   | α      | 0x03B1  |
| 62  | b     | Lowercase Beta    | β      | 0x03B2  |
| 63  | c     | Lowercase Chi     | χ      | 0x03C7  |
| 64  | d     | Lowercase Delta   | δ      | 0x03B4  |
| 65  | e     | Lowercase Epsilon | ε      | 0x03B5  |
| 66  | f     | Lowercase Phi     | φ      | 0x03C6  |
| 67  | g     | Lowercase Gamma   | γ      | 0x03B3  |
| 68  | h     | Lowercase Eta     | η      | 0x03B7  |
| 69  | i     | Lowercase Iota    | ι      | 0x03B9  |
| 6A  | j     | Lowercase Theta   | θ      | 0x03B8  |
| 6B  | k     | Lowercase Kappa   | κ      | 0x03BA  |
| 6C  | l     | Lowercase Lambda  | λ      | 0x03BB  |
| 6E  | n     | Lowercase Nu      | ν      | 0x03BD  |
| 70  | p     | Lowercase Pi      | π      | 0x03C0  |
| 71  | q     | Lowercase Psi     | ψ      | 0x03C8  |
| 72  | r     | Lowercase Rho     | ρ      | 0x03C1  |
| 73  | s     | Lowercase Sigma   | σ      | 0x03C3  |
| 74  | t     | Lowercase Tau     | τ      | 0x03C4  |
| 77  | w     | Lowercase Omega   | ω      | 0x03C9  |
| 78  | x     | Lowercase Xi      | ξ      | 0x03BE  |
| 79  | y     | Lowercase Upsilon | υ      | 0x03C5  |
| 7A  | z     | Lowercase Zeta    | ζ      | 0x03B6  |

</ul>

#### Mathematical

<ul>

| Hex | ASCII | Name                         | Symbol | Unicode |
|-----|:-----:|------------------------------|:------:|---------|
| 3C  | \<    | Less Than or Equal To        | ≤      | 0x2264  |
| 3D  | \=    | Not Equal                    | ≠      | 0x2260  |
| 3E  | \>    | Greater Than or Equal To     | ≥      | 0x2265  |
| 3F  | \?    | Integral                     | ∫      | 0x222B  |
| 41  | A     | Variation or Proportional To | ∝      | 0x221D  |
| 42  | B     | Infinity                     | ∞      | 0x221E  |
| 43  | C     | Division or Divided By       | ÷      | 0xF7    |
| 45  | E     | Nabla or Del                 | ∇      | 0x2207  |
| 48  | H     | Is Approximate To            | ∼      | 0x223C  |
| 49  | I     | Similar or Equal To          | ≃      | 0x2243  |
| 4B  | K     | Times or Cross Product       | ×      | 0xD7    |
| 56  | V     | Radical                      | √      | 0x221A  |
| 6F  | o     | Partial Derivative           | ∂      | 0x2202  |
| 76  | v     | Function                     | ƒ      | 0x0192  |
| 7B  | {     | Left Arrow                   | ←      | 0x2190  |
| 7C  | \|    | Upward Arrow                 | ↑      | 0x2191  |
| 7D  | \}    | Right Arrow                  | →      | 0x2192  |
| 7E  | \~    | Downward Arrow               | ↓      | 0x2193  |

</ul>

#### Logic

<ul>

| Hex | ASCII | Name           | Symbol | Unicode |
|-----|:-----:|----------------|:------:|---------|
| 40  | @     | Therefore      | ∴      | 0x2234  |
| 4D  | M     | If and Only If | ⇔      | 0x21D4  |
| 4E  | N     | Implies        | ⇒      | 0x21D2  |
| 4F  | O     | Identical To   | ≡      | 0x2261  |
| 5A  | Z     | Is Included In | ⊂      | 0x2282  |
| 5B  | \[    | Includes       | ⊃      | 0x2283  |
| 5C  | \\    | Intersection   | ∩      | 0x2229  |
| 5D  | \]    | Union          | ∪      | 0x222A  |
| 5E  | \^    | Logical And    | ∧      | 0x2227  |
| 5F  | \_    | Logical Or     | ∨      | 0x2228  |
| 60  | \`    | Logical Not    | ¬      | 0xAC    |

</ul>

### Building Large Mathematical Symbols

This table shows how to build large mathematical symbols. The
characters are designed to connect to adjacent character cells to form
technical characters that can occupy several vertically adjacent
and/or horizontally adjacent character positions. To use this table,
find the character you want to build (along the top of the table). On
the left side of the table are various pieces of the characters needed
to create the whole. Follow the top row choice, say, INTEGRAL, all the
way down the table. Use the hex value beside the symbol name you wish
to print. For example, to build an oversize integral, you will need a
top integral (hex 24), bottom integral (hex 25), and vertical
connector (hex 26).

<ul>

**Component Characters for Large Mathematics**

| Hex | ASCII | Name                                | Symbol | Unicode | <br/>RADICAL | <br/>INTEGRAL | SQUARE<br/>BRACKETS | CURLY<br/>BRACES | PAREN-<br/>THESES | SUM-<br/>MATIONS |
|-----|:-----:|-------------------------------------|:------:|---------|:-------:|:--------:|:------:|:-----:|:-----:|:---:|
| 21  | \!    | Left Radical                        | ⎷      | 0x23B7  | X       |          |        |       |       |     |
| 22  | \"    | Top Left Radical                    | ┌      | 0x250C  | X       |          |        |       |       |     |
| 23  | \#    | Horizontal Connector                | ─      | 0x2500  | X       |          |        |       |       | X   |
| 24  | \$    | Top Integral                        | ⌠      | 0x2320  |         |          | X      |       |       |     |
| 25  | \%    | Bottom Integral                     | ⌡      | 0x2321  |         | X        |        |       |       |     |
| 26  | \&    | Vertical Connector                  | │      | 0x2502  | X       | X        | X      | X     | X     |     |
| 27  | \'    | Top Left Square Bracket             | ⎡      | 0x23A1  |         |          | X      |       |       |     |
| 28  | \(    | Bottom Left Square Bracket          | ⎣      | 0x23A3  |         |          | X      |       |       |     |
| 29  | \)    | Top Right Square Bracket            | ⎤      | 0x23A4  |         |          | X      |       |       |     |
| 2A  | \*    | Bottom Right Square Bracket         | ⎦      | 0x23A6  |         |          | X      |       |       |     |
| 2B  | \+    | Top Left Parenthesis                | ⎛      | 0x239B  |         |          |        | X     | X     |     |
| 2C  | \,    | Bottom Left Parenthesis             | ⎝      | 0x239D  |         |          |        | X     | X     |     |
| 2D  | \-    | Top Right Parenthesis               | ⎞      | 0x239E  |         |          |        | X     | X     |     |
| 2E  | \.    | Bottom Right Parenthesis            | ⎠      | 0x23A0  |         |          |        | X     | X     |     |
| 2F  | \/    | Left Middle Curly Brace             | ⎨      | 0x23A8  |         |          |        | X     |       |     |
| 30  | 0     | Right Middle Curly Brace            | ⎬      | 0x23AC  |         |          |        | X     |       |     |
| 31  | 1     | Top Left Summation                  | ␦      |         |         |          |        |       |       | X   |
| 32  | 2     | Bottom Left Summation               | ␦      |         |         |          |        |       |       | X   |
| 33  | 3     | Top Vertical Summation Connector    | ␦      |         |         |          |        |       |       | X   |
| 34  | 4     | Bottom Vertical Summation Connector | ␦      |         |         |          |        |       |       | X   |
| 35  | 5     | Top Right Summation                 | ␦      |         |         |          |        |       |       | X   |
| 36  | 6     | Bottom Right Summation              | ␦      |         |         |          |        |       |       | X   |
| 37  | 7     | Right Middle Summation              | ␦      |         |         |          |        |       |       | X   |

_␦ marks characters which Unicode (as of 2022) is unable to reproduce,
namely the large summation character. Note that Unicode has summation
top (⎲) and bottom (⎳) characters, but those are insufficient even for
the simplest mathematics. In contrast, DEC's sigma can grow
arbitrarily large in either axis which means it can be centered
vertically with the equation to its right and properly span the
initial state (e.g., $i=-∞$) beneath it._

</ul>
