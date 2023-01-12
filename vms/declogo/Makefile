# Convert .eps logo to sixel.

# This only gets the logo most of the way there. The big problem with
# it is that it lacks transparency because ImageMagick cannot (yet) do
# that for sixel files. See declogo.six for the final handtweaked version.
temp1.six: declogo.eps
	convert -density 300 declogo.eps -colorspace gray +trim -border 10 \
	"(" \
		xc:black xc:gray50 xc:gray75 xc:gray25 +append \
		-write mpr:MYMAP +delete \
	")"  \
	+dither -remap mpr:MYMAP -geometry 800x480 -colors 4 \
	$@
	echo >> $@
	sed -r -i~ 's/-/-\n/g' $@

# This target requires a genuine VT340 to turn the image transparent.
# Still needs handtweaking to remove colormap, change color numbers,
# pick block color.
temp2.six: temp1.six
	clear
	@cat $<
	bash ../../mediacopy/mediacopy.sh --debug 800x222
	tr -d '\n' < print.six  > $@ && rm print.six
	sed -r -i~ 's/-/-\n/g' $<

clean:
	rm temp1.six temp2.six 2>/dev/null || true
