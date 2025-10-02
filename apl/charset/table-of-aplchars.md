# ISO Table of APL Characters

Unfotunately, ISO never standardized a table of APL characters with
code points. A working draft found preserved in amber at
-https://www.math.uwaterloo.ca/~ljdickey/apl-rep/tables/ shows the
thoughts of the standardization committee, a few of which are relevant
for the DEC VT340.

* 131 different APL symbols (not including alphabetic letters) were
  identified. The VT340 can only store 94 characters in a soft font,
  so clearly some compromises had to be made. Or, so you would think.
  Digital's [APL Font](../aplfontb9/) actually only contains 87
  unique characters. (76 to 7C are just copies of 7E, Squish Quad).

* One character that the VT340 font can show that isn't part of the
  standard is 7D, "OUT". In the original version of APL, this was
  shown by having the letters 'O', 'U', and 'T' typed overstuck in the
  same place on the paper.

* Digital's [APL Font](../aplfontb9/) could have saved 26 characters
  by leaving out the underscored alphabet (A̲ B̲ C̲). The standards
  committee said that that alphabet was an artifact of the 1960s
  hardware which could not show lowercase. With the invention of
  "glass TTYs", there was some confusion about whether underscored
  letters were supposed to be upper or lowercase, but the committee
  may have been referring to DEC when they said,
 a
  <blockquote>
  “at least one implementer added to the confusion by including three copies of the alphabet,

	a to z,

	A to Z, and

	𝐴̲ to 𝑍̲. ”
  </blockquote>


## The table itself

Table of all standard APL characters and their Unicode equivalents,
extracted from the standard committee's draft. 


|    | APL Name               | Unicode     | G0: ASCII | G1: DEC APL | G2: Latin1 | G3: GFX | TCS     |
|----|------------------------|-------------|-----------|-------------|------------|---------|---------|
| ⍺  | Alpha                  | U+237A      |           | 29          |            |         | 61      |
| ⍶  | Alpha Underbar         | U+2376      |           |             |            |         |         |
| \  | Back Slash             | U+005C      | 5C        |             |            | 5C      |         |
| ⍀  | Back Slash Bar         | U+2340      |           | 71          |            |         |         |
| ○  | Circle                 | U+25CB      |           | 34          |            |         |         |
| ⍉  | Circle Back Slash      | U+2349      |           | 6D          |            |         |         |
| ⊖  | Circle Bar             | U+2296      |           | 6E          |            |         |         |
| ⍥  | Circle Diaeresis       | U+2365      |           |             | 76         |         |         |
| ⌾  | Circle Jot             | U+233E      |           |             |            |         |         |
| ∅  | Circle Slash           | U+2205      |           |             | 78         |         |         |
| ⍟  | Circle Star            | U+235F      |           | 6B          |            |         |         |
| ⌽  | Circle Stile           | U+233D      |           | 6C          |            |         |         |
| ⍜  | Circle Underbar        | U+235C      |           |             |            |         |         |
| \: | Colon                  | U+003A      | 3A        |             |            |         |         |
| ,  | Comma                  | U+002C      | 2C        |             |            |         |         |
| ⍪  | Comma Bar              | U+236A      |           | 6F          |            |         |         |
| ∇  | Del                    | U+2207      |           | 2E          |            |         | 45      |
| ⍢  | Del Diaeresis          | U+2362      |           |             |            |         |         |
| ⍒  | Del Stile              | U+2352      |           | 67          |            |         |         |
| ⍫  | Del Tilde              | U+236B      |           | 68          |            |         |         |
| ∆  | Delta                  | U+2206      |           | 2F          |            |         | 44      |
| ⍋  | Delta Stile            | U+234B      |           | 66          |            |         |         |
| ⍙  | Delta Underbar         | U+2359      |           | 42          |            |         |         |
| ¨  | Diaeresis              | U+00A8      |           | 21          |            |         |         |
| ∵  | Diaeresis Dot          | U+2235      |           |             |            |         |         |
| ⋄  | Diamond                | U+22C4      |           | 40          |            | 60      |         |
| ⍚  | Diamond Underbar       | U+235A      |           |             |            |         |         |
| ÷  | Divide                 | U+00F7      |           | 26          | 77         |         | 43      |
| $  | Dollar Sign            | U+0024      | 24        |             |            |         |         |
| .  | Dot                    | U+002E      | 2E        |             |            |         |         |
| ↓  | Down Arrow             | U+2193      |           | 37          |            |         | 7E      |
| ∨  | Down Caret             | U+2228      |           | 23          |            |         | 5F      |
| ⍱  | Down Caret Tilde       | U+2371      |           | 69          |            |         |         |
| ∪  | Down Shoe              | U+222A      |           | 38          |            |         | 5D      |
| ⍦  | Down Shoe Stile        | U+2366      |           |             |            |         |         |
| ⌊  | Down Stile             | U+230A      |           | 2C          |            |         | 28      |
| ⊤  | Down Tack              | U+22A4      |           | 33          |            | 77      |         |
| ⍡  | Down Tack Diaeresis    | U+2361      |           |             |            |         |         |
| ⍕  | Down Tack Jot          | U+2355      |           | 60          |            |         |         |
| ⍑  | Down Tack Overbar      | U+2351      |           |             |            |         |         |
| ⍖  | Down Vane              | U+2356      |           |             |            |         |         |
| ∊  | Epsilon                | U+220A      |           | 2D          |            | 65      |         |
| ⍷  | Epsilon Underbar       | U+2377      |           |             |            |         |         |
| =  | Equal                  | U+003D      | 3D        |             |            | 3D      |         |
| >  | Greater Than           | U+003E      | 3E        |             |            | 3E      |         |
| ⍩  | Greater Than Diaeresis | U+2369      |           |             |            |         |         |
| ≥  | Greater Than or Equal  | U+2265      |           | 3F          |            | 7A      | 3E      |
| ⌶  | I-beam                 | U+2336      |           | 5E          |            |         |         |
| ⍳  | Iota                   | U+2373      |           | 30          |            |         | 69      |
| ⍸  | Iota Underbar          | U+2378      |           |             |            |         |         |
| ∘  | Jot                    | U+2218      |           | 31          | 30         | 66      |         |
| ⍤  | Jot Diaeresis          | U+2364      |           |             |            |         |         |
| ⍛  | Jot Underbar           | U+235B      |           |             | 3A         |         |         |
| ←  | Left Arrow             | U+2190      |           | 3C          |            |         | 7B      |
| {  | Left Brace             | U+007B      | 7B        |             |            |         |         |
| [  | Left Bracket           | U+005B      | 5B        |             |            | 5B      |         |
| (  | Left Parenthesis       | U+0028      | 28        |             |            |         |         |
| ⊂  | Left Shoe              | U+2282      |           | 3B          |            |         | 5A      |
| ⍧  | Left Shoe Stile        | U+2367      |           |             |            |         |         |
| ⊆  | Left Shoe Underbar     | U+2286      |           | 72          |            |         |         |
| ⊣  | Left Tack              | U+22A3      |           | 41          |            | 75      |         |
| ⍅  | Left Vane              | U+2345      |           |             |            |         |         |
| <  | Less Than              | U+003C      | 3C        |             |            | 3C      |         |
| ≤  | Less Than or Equal     | U+2264      |           | 22          |            | 79      | 3C      |
| −  | Minus                  | U+2212      | 2D        |             | 2D         |         |         |
| ×  | Multiply               | U+00D7      |           | 27          | 57         |         |         |
| ≠  | Not Equal              | U+2260      |           | 25          |            | 7C      | 3D      |
| ≢  | Not Same               | U+2262      |           |             |            |         |         |
| ⍵  | Omega                  | U+2375      |           | 39          |            |         | 77      |
| ⍹  | Omega Underbar         | U+2379      |           |             |            |         |         |
| ¯  | Overbar                | U+00AF      |           | 28          | 2F         | 6F      |         |
| +  | Plus                   | U+002B      | 2B        |             |            |         |         |
| ⎕  | Quad                   | U+2395      |           | 32          |            |         |         |
| ⍂  | Quad Backslash         | U+2342      |           |             |            |         |         |
| ⌼  | Quad Circle            | U+233C      |           |             |            |         |         |
| ⍠  | Quad Colon             | U+2360      |           |             |            |         |         |
| ⍔  | Quad Del               | U+2354      |           | 65          |            |         |         |
| ⍍  | Quad Delta             | U+234D      |           |             |            |         |         |
| ⌺  | Quad Diamond           | U+233A      |           |             |            |         |         |
| ⌹  | Quad Divide            | U+2339      |           | 61          |            |         |         |
| ⍗  | Quad Down Arrow        | U+2357      |           |             |            |         |         |
| ⍌  | Quad Down Caret        | U+234C      |           | 65          |            |         |         |
| ⌸  | Quad Equal             | U+2338      |           |             |            |         |         |
| ⍄  | Quad Greater Than      | U+2344      |           |             |            |         |         |
| ⌻  | Quad Jot               | U+233B      |           |             |            |         |         |
| ⍇  | Quad Left Arrow        | U+2347      |           | 62          |            |         |         |
| ⍃  | Quad Less Than         | U+2343      |           |             |            |         |         |
| ⍯  | Quad Not Equal         | U+236F      |           |             |            |         |         |
| ⍰  | Quad Question          | U+2370      |           |             |            |         |         |
| ⍈  | Quad Right Arrow       | U+2348      |           | 63          |            |         |         |
| ⍁  | Quad Slash             | U+2341      |           |             |            |         |         |
| ⍐  | Quad Up Arrow          | U+2350      |           |             |            |         |         |
| ⍓  | Quad Up Caret          | U+2353      |           |             |            |         |         |
| ?  | Question               | U+003F      | 3F        |             |            |         |         |
| '  | Quote                  | U+0027      | 27        |             |            |         |         |
| !  | Quote Dot              | U+0021      | 21        |             |            |         |         |
| ⍞  | Quote Quad             | U+235E      |           | 64          |            |         |         |
| ⍘  | Quote Underbar         | U+2358      |           |             |            |         |         |
| ⍴  | Rho                    | U+2374      |           | 35          |            |         | 72      |
| →  | Right Arrow            | U+2192      |           | 3E          |            |         | 7D      |
| }  | Right Brace            | U+007D      | 7D        |             |            |         |         |
| ]  | Right Bracket          | U+005D      | 5D        |             |            | 5D      |         |
| )  | Right Parenthesis      | U+0029      | 29        |             |            |         |         |
| ⊃  | Right Shoe             | U+2283      |           | 3A          |            |         | 5B      |
| ⊇  | Right Shoe Underbar    | U+2287      |           | 73          |            |         |         |
| ⊢  | Right Tack             | U+22A2      |           | 3D          |            | 74      |         |
| ⍆  | Right Vane             | U+2346      |           |             |            |         |         |
| ≡  | Same                   | U+2261      |           | 74          |            |         | 4F      |
| ;  | Semicolon              | U+003B      | 3B        |             |            |         |         |
| ⍮  | Semicolon Underbar     | U+236E      |           |             |            |         |         |
| /  | Slash                  | U+002F      | 2F        |             |            | 2F      |         |
| ⌿  | Slash Bar              | U+233F      |           | 70          |            |         |         |
| ⌷  | Squish Quad            | U+2337      |           | 7E          |            |         |         |
| ⋆  | Star                   | U+22C6      |           |             |            |         |         |
| ⍣  | Star Diaeresis         | U+2363      |           |             |            |         |         |
| ∣  | Stile                  | U+2223      | 7C        |             |            | 78      |         |
| ⍭  | Stile Tilde            | U+236D      |           |             |            |         |         |
| ∼  | Tilde                  | U+223C      | 7E        |             |            |         | 48      |
| ⍨  | Tilde Diaeresis        | U+2368      |           |             |            |         |         |
| _  | Underbar               | U+005F      | 5F        |             |            | 73      |         |
| ↑  | Up Arrow               | U+2191      |           | 75          |            |         | 7C      |
| ∧  | Up Caret               | U+2227      | 5E        | 24          |            |         | 5E      |
| ⍲  | Up Caret Tilde         | U+2372      |           | 6A          |            |         |         |
| ∩  | Up Shoe                | U+2229      |           | 2B          |            |         | 5C      |
| ⍝  | Up Shoe Jot            | U+235D      |           | 5D          |            |         |         |
| ⌈  | Up Stile               | U+2308      |           | 36          |            |         | 27      |
| ⊥  | Up Tack                | U+22A5      |           | 2A          |            | 76      |         |
| ⍎  | Up Tack Jot            | U+234E      |           | 5F          |            |         |         |
| ⍊  | Up Tack Underbar       | U+234A      |           |             |            |         |         |
| ⍏  | Up Vane                | U+234F      |           |             |            |         |         |
| ⍬  | Zilde                  | U+236C      |           |             |            |         |         |
|    | **APL Name**           | **Unicode** | **ASCII** | **APL**     | **Latin1** | **GFX** | **TCS** |

Note that Hackerb9 has also added the equivalent character code in the
various character sets that the VT340 would have access to when using
DEC's recommended ["Composite APL Character Set"](../../charset/DECAPL.md).

Sidenote: TCS, the Technical Character Set, despite having many Greek
letters that might have been useful, is not part of the Composite APL
Character Set. If TCS had been used intead of Latin-1, it could have
saved many glyphs that the DEC APL font redundantly provided: (⍺, ∇,
∆, ÷, ↓, ∨, ∪, ⌊, ⊤, ≥, ⍳, ←, ⊂, ≤, ≠, ⍴, →, ⊃, ≡, ⍵, ↑, ∧, ∩).
