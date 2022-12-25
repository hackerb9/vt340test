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

| Hex | Decimal | ASCII | Name      | Symbol |
|-----|---------|-------|-----------|--------|
| 40  | 64      | @     | Therefore | ∴      |

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

| Hex | Decimal | ASCII | Name              | Symbol |
|-----|---------|-------|-------------------|--------|
| 44  | 68      | D     | Uppercase Delta   | Δ      |
| 46  | 70      | F     | Uppercase Phi     | Φ      |
| 47  | 71      | G     | Uppercase Gamma   | Γ      |
| 4A  | 74      | J     | Uppercase Theta   | Θ      |
| 4C  | 76      | L     | Uppercase Lambda  | Λ      |
| 50  | 80      | P     | Uppercase Pi      | Π      |
| 51  | 81      | Q     | Uppercase Psi     | Ψ      |
| 53  | 83      | S     | Uppercase Sigma   | Σ      |
| 57  | 87      | W     | Uppercase Omega   | Ω      |
| 58  | 88      | X     | Uppercase Ksi     | Ξ      |
| 59  | 89      | Y     | Uppercase Upsilon | Υ      |
| 61  | 97      | a     | Lowercase Alpha   | α      |
| 62  | 98      | b     | Lowercase Beta    | β      |
| 63  | 99      | c     | Lowercase Chi     | χ      |
| 64  | 100     | d     | Lowercase Delta   | δ      |
| 65  | 101     | e     | Lowercase Epsilon | ε      |
| 66  | 102     | f     | Lowercase Phi     | φ      |
| 67  | 103     | g     | Lowercase Gamma   | γ      |
| 68  | 104     | h     | Lowercase Eta     | η      |
| 69  | 105     | i     | Lowercase Iota    | ι      |
| 6A  | 106     | j     | Lowercase Theta   | θ      |
| 6B  | 107     | k     | Lowercase Kappa   | κ      |
| 6C  | 108     | l     | Lowercase Lambda  | λ      |
| 6E  | 110     | n     | Lowercase Nu      | ν      |
| 70  | 112     | p     | Lowercase Pi      | π      |
| 71  | 113     | q     | Lowercase Psi     | ψ      |
| 72  | 114     | r     | Lowercase Rho     | ρ      |
| 73  | 115     | s     | Lowercase Sigma   | σ      |
| 74  | 116     | t     | Lowercase Tau     | τ      |
| 77  | 119     | w     | Lowercase Omega   | ω      |
| 78  | 120     | x     | Lowercase Xi      | ξ      |
| 79  | 121     | y     | Lowercase Upsilon | υ      |
| 7A  | 122     | z     | Lowercase Zeta    | ζ      |

</ul>

#### Mathematical

<ul>

| Hex | Decimal | ASCII | Name                         | Symbol |
|-----|---------|-------|------------------------------|--------|
| 3C  | 60      | \<    | Less Than or Equal To        | ≤      |
| 3D  | 61      | \=    | Not Equal                    | ≠      |
| 3E  | 62      | \>    | Greater Than or Equal To     | ≥      |
| 3F  | 63      | \?    | Integral                     | ∫      |
| 41  | 65      | A     | Variation or Proportional To | ∝      |
| 42  | 66      | B     | Infinity                     | ∞      |
| 43  | 67      | C     | Division or Divided By       | ÷      |
| 45  | 69      | E     | Nabla or Del                 | ∇      |
| 48  | 72      | H     | Is Approximate To            | ∼      |
| 49  | 73      | I     | Similar or Equal To          | ≃      |
| 4B  | 75      | K     | Times or Cross Product       | ×      |
| 56  | 86      | V     | Radical                      | √      |
| 6F  | 111     | o     | Partial Derivative           | ∂      |
| 76  | 118     | v     | Function                     | ƒ      |
| 7B  | 123     | {     | Left Arrow                   | ←      |
| 7C  | 124     | \|    | Upward Arrow                 | ↑      |
| 7D  | 125     | \}    | Right Arrow                  | →      |
| 7E  | 126     | \~    | Downward Arrow               | ↓      |

</ul>

#### Logic

<ul>

| Hex | Decimal | ASCII | Name           | Symbol |
|-----|---------|-------|----------------|--------|
| 40  | 64      | @     | Therefore      | ∴      |
| 4D  | 77      | M     | If and Only If | ⇔      |
| 4E  | 78      | N     | Implies        | ⇒      |
| 4F  | 79      | O     | Identical To   | ≡      |
| 5A  | 90      | Z     | Is Included In | ⊂      |
| 5B  | 91      | \[    | Includes       | ⊃      |
| 5C  | 92      | \\    | Intersection   | ∩      |
| 5D  | 93      | \]    | Union          | ∪      |
| 5E  | 94      | \^    | Logical And    | ∧      |
| 5F  | 95      | \_    | Logical Or     | ∨      |
| 60  | 96      | \`    | Logical Not    | ¬      |

</ul>

### Building Large Mathematical Symbols

This table shows how to build large mathematical symbols. The
characters are designed to connect to adjacent character cells to form
technical characters that can occupy several vertically adjacent
and/or horizontally adjacent character positions. To use this table,
find the character you want to build (along the top of the table). On
the left side of the table are various pieces of the characters needed
to create the whole. Follow the top row choice, say, Integral, all the
way down the table. Use the hex value beside the symbol name you wish
to print. For example, to build an oversize integral, you will need a
top integral (hex 24), bottom integral (hex 25), and vertical
connector (hex 26).

<ul>

**Component Characters for Large Mathematics**

| Name                                | Symbol | Hex | ASCII | Radical | Integral | Square | Curly | Paren | Summations |
|-------------------------------------|:------:|-----|-------|:-------:|:--------:|:------:|:-----:|:-----:|:----------:|
| Left Radical                        | ⎷      | 21  | \!    | X       |          |        |       |       |            |
| Top Left Radical                    | ┌      | 22  | \"    | X       |          |        |       |       |            |
| Horizontal Connector                | ─      | 23  | \#    | X       |          |        |       |       | X          |
| Top Integral                        | ⌠      | 24  | \$    |         |          | X      |       |       |            |
| Bottom Integral                     | ⌡      | 25  | \%    |         | X        |        |       |       |            |
| Vertical Connector                  | │      | 26  | \&    | X       | X        | X      | X     | X     |            |
| Top Left Square Bracket             | ⎡      | 27  | \'    |         |          | X      |       |       |            |
| Bottom Left Square Bracket          | ⎣      | 28  | \(    |         |          | X      |       |       |            |
| Top Right Square Bracket            | ⎤      | 29  | \)    |         |          | X      |       |       |            |
| Bottom Right Square Bracket         | ⎦      | 2A  | \*    |         |          | X      |       |       |            |
| Top Left Parenthesis                | ⎛      | 2B  | \+    |         |          |        | X     | X     |            |
| Bottom Left Parenthesis             | ⎝      | 2C  | \,    |         |          |        | X     | X     |            |
| Top Right Parenthesis               | ⎞      | 2D  | \-    |         |          |        | X     | X     |            |
| Bottom Right Parenthesis            | ⎠      | 2E  | \.    |         |          |        | X     | X     |            |
| Left Middle Curly Brace             | ⎨      | 2F  | \/    |         |          |        | X     |       |            |
| Right Middle Curly Brace            | ⎬      | 30  | 0     |         |          |        | X     |       |            |
| Top Left Summation                  | ␦      | 31  | 1     |         |          |        |       |       | X          |
| Bottom Left Summation               | ␦      | 32  | 2     |         |          |        |       |       | X          |
| Top Vertical Summation Connector    | ␦      | 33  | 3     |         |          |        |       |       | X          |
| Bottom Vertical Summation Connector | ␦      | 34  | 4     |         |          |        |       |       | X          |
| Top Right Summation                 | ␦      | 35  | 5     |         |          |        |       |       | X          |
| Bottom Right Summation              | ␦      | 36  | 6     |         |          |        |       |       | X          |
| Right Middle Summation              | ␦      | 37  | 7     |         |          |        |       |       | X          |

_␦ marks characters which Unicode (as of 2022) is unable to reproduce,
namely the large summation character. Note that Unicode has summation
top (⎲) and bottom (⎳) characters, but those are insufficient even for
the simplest mathematics. In contrast, DEC's sigma can grow
arbitrarily large in either axis which means it can be centered
vertically with the equation to its right and properly span the
initial state (e.g., $i=-∞$) beneath it._

</ul>

