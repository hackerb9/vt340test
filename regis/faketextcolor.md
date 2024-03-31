# Coloring text pixels using ReGIS

It is not possible to have multicolored text on the VT340 because the
value of any pixel of text is 0111₂, which is an index into the
colormap. No matter what color the colormap entry is changed to, all
text will change simultaneously since it all points to the same place.

However, it _is_ possible to modify the value of pixels on the screen by
selectively erasing the bitplane using the ReGIS `W(F())` operator. 



## How to do it

Example code:

```bash
DCS=$'\eP'
ST=$'\e\\'
echo "${DCS}1p; S(E) W(M20,I0) ${ST}"
tput cup 10 25
tput bold			# Bold text pixels are set to 1111
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

### Side note

<ul>
<img src="offsetdirections.svg" width=25% align="right">

The mysterious number `0642` is actually offset directions
for the `V` (vector) operator. Here is the compass rose showing what
each number means. The global setting `W(M20)` changed the default
Writing Multiplier to 20 pixels per step, instead of one.

</ul>
<br clear="all">


## Test program

* [faketextcolor.sh](faketextcolor.sh)

<img src="faketextcolor.png" width=80%>

## References

* https://vt100.net/docs/vt3xx-gp/chapter3.html

## How fast is it? 

The above implementation is rather slow, taking nearly half a
second on a VT340+ to colorize 32 characters. There is likely some
faster way as no optimization has been attempted, yet.

## What if the screen scrolls?

Colorized text scrolls properly with the screen.

## What if the text is shifted via inserts?

Not tested.

