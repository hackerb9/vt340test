#!/bin/bash
# Given a directory name and a title string,
# montage all the sixel files inside that directory into a single file
# named after the directory, but with "-montage.png" suffixed.
#
# Example usage: ./mkmontage tcs "Technical Character Set 10x20"

# BUGS: This doesn't work yet

declare -Ag scstable=([asc]="ASCII (ANSI X3.4-1986)"
		      [gfx]="DEC VT100 Graphics" 
		      [tcs]="DEC Technical" 
		      [mcs]="DEC Multinational" 
		      [pref]="User-preferred Supplemental" 
		      [soft]="Down-Line-Loadable (Soft)" 

		      [lat1]="Latin Alphabet No. 1" 
		      [lat2]="Latin Alphabet No. 2" 
		      [lat3]="Latin Alphabet No. 3" 
		      [lat4]="Latin Alphabet No. 4" 
		      [cyr]="Latin/Cyrillic" 
		      [arab]="Latin/Arabic" 
		      [grk]="Latin/Greek" 
		      [heb]="Latin/Hebrew" 
		      [lat5]="Latin Alphabet No. 5" 
		      [math]="Math/Technical Set (?)" 

		      [cgb]="Chinese (CAS GB 2312-80)" 
		      [jap]="Japanese (JIS X 0208)" 
		      [kata]="JIS-Katakana (JIS X 0201)" 
		      [jrom]="JIS-Roman (JIS X 0201)" 
		      [kor]="Korean (KS C 5601-1989)" 

		      [uknr]="British National Replacement" 
		      [nlnr]="Dutch National Replacement" 
		      [finr]="Finnish National Replacement" 
		      [frnr]="French National Replacement" 
		      [qunr]="French Canadian National Replacement" 
		      [denr]="German National Replacement" 
		      [itnr]="Italian National Replacement" 
		      [nonr]="Norwegian/Danish National Replacement" 
		      [ptnr]="Portuguese National Replacement" 
		      [esnr]="Spanish National Replacement" 
		      [senr]="Swedish National Replacement" 
		      [chnr]="Swiss National Replacement" 

		      [grnr]="Greek National Replacement" 
		      [ilnr]="Hebrew National Replacement" 
		      [runr]="Russian National Replacement" 
		      [scsnr]="SCS National Replacement" 
		      [trnr]="Turkish National Replacement" 

		      [dgrk]="DEC Greek" 
		      [dheb]="DEC Hebrew" 
		      [dtur]="DEC Turkish" 
		      [dcyr]="DEC Cyrillic" 
		     )

scslongname() {
    # Given a name like "tcs-10x20" or "mcs", return a meaningful title.
    # For example, "Technical Character Set 10x20"

    local scs			# word before the first dash ("tcs")
    local rest			# words after the first dash ("10x20")
    IFS=- read scs rest <<<"$1"	
    local title=${scstable[$scs]:-$scs}
    
    echo "$title Character Set${rest:+ }${rest}"
}

dir="${1%/}"
title="${2:-$(scslongname "$dir")}"

cd "$dir"

# Imagemagick has a bug where it turns sixel files black when
# manipulating them, so convert all to PNG first. While we're at it
# change the filenames to just the hexadecimal code so we can use
# "montage -label '%t'" to label each character.

# Convert "char-tcs-10x20-7E.six" to "7E.png"
for f in char*.six; do
    g=${f##*-}
    g=${g%.six}
    convert $f $g.png
done
 
# Create blanks for any missing characters
for a in {2..7}; do
    for b in {0..9} {A..F}; do
	f=$a$b.png
	if [[ ! -e $f || -z $f ]]; then
	    convert xc:black -transparent black $f
	fi
    done
done

montage -title "$title" \
	-label '%t' -background gray33 -fill gray66 \
	-tile 16x6 -scale 600% -geometry 60x60+5+5 \
	??.png ../$dir-montage.png
rm ??.png
