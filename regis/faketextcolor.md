# Coloring text pixels using ReGIS

It is not possible to have multicolored text on the VT340 because the
value of any pixel of text is 0111₂, which is an index into the
colormap. No matter what color the colormap entry is changed to, all
text will change simultaneously since it all points to the same place.

However, it _is_ possible to modify the value of pixels on the screen by
selectively erasing the bitplane using the ReGIS `W(F())` operator. 


## Test program

* [faketextcolor.sh](faketextcolor.sh)

<img src="faketextcolor.png" width=80%>

## Example code

```bash
DCS=$'\eP'
ST=$'\e\\'
# Erase screen. Writing Multiplier = 20, color Index = 0 (0000₂).
echo "${DCS}1p; S(E) W(M20,I0) ${ST}"
tput cup 10 25		# Cursor position
tput bold			# Bold text pixels are set to 15 (1111₂).
echo -n "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

# Enable only certain fields (bitplanes) for writing.
echo "${DCS}0p;"
echo "P[250,200]"
for ((i=0; i<16; i++)); do
	# Filled Vector polygon with temporary Writing style of Field "i"
    echo "F(V(W(F${i})) 0642) v0 "
done
echo "${ST}"
```

### ...

<ul>
<img src="offsetdirections.svg" width=25% align="right">

**Side note**

The mysterious number `0642` is actually offset directions for the `V`
(vector) operator. Here is the compass rose showing what each number
means. Because the code has set `W(M20)` the Writing Multiplier is 20
pixels per step. So, 0642 goes east, south, west, and then north,
making a 20x20 square. The final `V0` moves the ReGIS cursor east to
start the next box.

</ul>
<br clear="all">

## References

* https://vt100.net/docs/vt3xx-gp/chapter3.html

## Potential problems

* **How fast is it?**  

  The above implementation is rather slow, taking nearly half a second
  on a VT340+ to colorize 32 characters. There is likely some faster way
  as no optimization has been attempted, yet.

* **What if the screen scrolls up?**  

  Colorized text scrolls up properly with the screen. Tested with
  '\n' (newline) and Esc D (index).

* **What if the screen scrolls down?**

  Colorized text scrolls down properly with the screen. Tested with Esc
  M (reverse index) and with Esc [ M (delete line).

* **What if the text is shifted left?**

  Colors are removed from the line when text is shifted left by Esc [ P
  (delete character).

* **What if the text is shifted right?**

  Colors are removed from the line when the text is shifted right by Esc
  [ 4 h (insert mode).

## Portability

This example code is lacking in that it ought to test for the size of
the character cell instead of presuming it is 10x20. Due to this bug,
it will not work on the VT340 in 132 column mode, nor does it work on
terminal emulators that have different font sizes.
