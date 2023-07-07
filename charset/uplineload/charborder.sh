#!/bin/bash

# Given a directory name, add a dashed red border to all the
# individual character images. (Result is w+2 x h+2 pixels).
#
# Filenames are in the format "char-foo-bar-schmurr-XX.png"
# where XX is two hexadecimal digits.
# Output is in border-XX.png.

if [[ "$1" && -d "$1" ]]; then
   cd $1
fi

for f in char*.six; do
    read v h < <(identify -format '%h %w' "$f")
    h=$((2*h+1))
    v=$((2*v+1))
    output=border-${f##*-} && output=${output%.six}.png
    convert "$f" miff:- | convert - -scale 200% \
	    -density 120 -units pixelsperinch -threshold 1% -negate \
	    -colorspace rgb -alpha on -background none -mattecolor none \
	    -frame 1 -strokewidth 0.5 -stroke red -fill none \
	    -draw "stroke-dasharray 1 5 path 'M 0,0 h $h v $v h -$h v -$v'" \
	    "$output"
done


# Bugs: Uses two `convert`s in a pipeline because ImageMagick version
# 6.9.11-60 cannot handle doing anything to a sixel file except
# changing it to a different type. Any modification at all, even just
# '-scale 200%' will make the screen blank.
