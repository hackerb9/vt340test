#!/bin/bash

# Test SGR (Select Graphic Rendition): Esc [ Ps  m
# | CSI  | Ps  | ;    | Ps  | ... | m    |
# |------|-----|------|-----|-----|------|
# | 9/11 | 3/? | 3/11 | 3/? | ... | 6/13 |

attribute[ 0  ]="all attributes off"
attribute[ 1  ]="bold or increased intensity"
attribute[ 2  ]="faint, decreased intensity or second colour"
attribute[ 3  ]="italicized"
attribute[ 4  ]="singly underlined"
attribute[ 5  ]="slowly blinking (less then 150 per minute)"
attribute[ 6  ]="rapidly blinking (150 per minute or more)"
attribute[ 7  ]="negative image"
attribute[ 8  ]="concealed characters"
attribute[ 9  ]="crossed-out (characters still legible but marked as to be deleted)"
attribute[ 10 ]="primary (default) font"
attribute[ 11 ]="first alternative font"
attribute[ 12 ]="second alternative font"
attribute[ 13 ]="third alternative font"
attribute[ 14 ]="fourth alternative font"
attribute[ 15 ]="fifth alternative font"
attribute[ 16 ]="sixth alternative font"
attribute[ 17 ]="seventh alternative font"
attribute[ 18 ]="eighth alternative font"
attribute[ 19 ]="ninth alternative font"
attribute[ 20 ]="Fraktur (Gothic)"
attribute[ 21 ]="doubly underlined"
attribute[ 22 ]="normal colour or normal intensity (neither bold nor faint)"
attribute[ 23 ]="not italicized, not fraktur"
attribute[ 24 ]="not underlined (neither singly nor doubly)"
attribute[ 25 ]="steady (not blinking)"
attribute[ 26 ]="_(reserved for proportional spacing, see CCITT Recommendation T.61)_"
attribute[ 27 ]="positive image (negative image off)"
attribute[ 28 ]="revealed characters (invisible off)"
attribute[ 29 ]="not crossed out"
attribute[ 30 ]="black display"
attribute[ 31 ]="red display"
attribute[ 32 ]="green display"
attribute[ 33 ]="yellow display"
attribute[ 34 ]="blue display"
attribute[ 35 ]="magenta display"
attribute[ 36 ]="cyan display"
attribute[ 37 ]="white display"
attribute[ 38 ]="_(reserved for setting character foreground colour, see ISO 8613-6)_"
attribute[ 39 ]="default display colour (implementation-defined)"
attribute[ 40 ]="black background"
attribute[ 41 ]="red background"
attribute[ 42 ]="green background"
attribute[ 43 ]="yellow background"
attribute[ 44 ]="blue background"
attribute[ 45 ]="magenta background"
attribute[ 46 ]="cyan background"
attribute[ 47 ]="white background"
attribute[ 48 ]="_(reserved for setting character background colour, see ISO 8613-6)_"
attribute[ 49 ]="default background colour (implementation-defined)"
attribute[ 50 ]="_(reserved for cancelling 26, proportional spacing)_"
attribute[ 51 ]="framed"
attribute[ 52 ]="encircled"
attribute[ 53 ]="overlined"
attribute[ 54 ]="not framed, not encircled"
attribute[ 55 ]="not overlined"
attribute[ 56 ]="_(reserved for future standardization)_"
attribute[ 57 ]="_(reserved for future standardization)_"
attribute[ 58 ]="_(reserved for future standardization)_"
attribute[ 59 ]="_(reserved for future standardization)_"
attribute[ 60 ]="ideogram underline or right side line"
attribute[ 61 ]="ideogram double underline or double line on the right side"
attribute[ 62 ]="ideogram overline or left side line"
attribute[ 63 ]="ideogram double overline or double line on the left side"
attribute[ 64 ]="ideogram stress marking"
attribute[ 65 ]="cancels ideogram effects, attributes 60 to 64"

# Short attribute names
att[ 0  ]="normal"
att[ 1  ]="bold"
att[ 2  ]="dim"
att[ 3  ]="italicized"
att[ 4  ]="underlined"
att[ 5  ]="slowly blinking"
att[ 6  ]="rapidly blinking"
att[ 7  ]="negative image"
att[ 8  ]="concealed characters"
att[ 9  ]="crossed-out"
att[ 10 ]="default font"
att[ 11 ]="1st font"
att[ 12 ]="2nd font"
att[ 13 ]="3rd font"
att[ 14 ]="4th font"
att[ 15 ]="5th font"
att[ 16 ]="6th font"
att[ 17 ]="7th font"
att[ 18 ]="8th font"
att[ 19 ]="9th font"
att[ 20 ]="Fraktur"
att[ 21 ]="doubly underlined"
att[ 22 ]="normal intensity"
att[ 23 ]="not italicized nor fraktur"
att[ 24 ]="not underlined"
att[ 25 ]="not blinking"
att[ 26 ]="proportional spacing"
att[ 27 ]="positive image"
att[ 28 ]="revealed characters"
att[ 29 ]="not crossed out"
att[ 30 ]="black display"
att[ 31 ]="red display"
att[ 32 ]="green display"
att[ 33 ]="yellow display"
att[ 34 ]="blue display"
att[ 35 ]="magenta display"
att[ 36 ]="cyan display"
att[ 37 ]="white display"
att[ 38 ]="character foreground colour"
att[ 39 ]="default display colour"
att[ 40 ]="black background"
att[ 41 ]="red background"
att[ 42 ]="green background"
att[ 43 ]="yellow background"
att[ 44 ]="blue background"
att[ 45 ]="magenta background"
att[ 46 ]="cyan background"
att[ 47 ]="white background"
att[ 48 ]="character background colour"
att[ 49 ]="default background colour"
att[ 50 ]="fixed-width spacing"
att[ 51 ]="framed"
att[ 52 ]="encircled"
att[ 53 ]="overlined"
att[ 54 ]="not framed, not encircled"
att[ 55 ]="not overlined"
att[ 56 ]="reserved"
att[ 57 ]="reserved"
att[ 58 ]="reserved"
att[ 59 ]="reserved"
att[ 60 ]="ideogram under/right side line"
att[ 61 ]="ideogram double under/right side line"
att[ 62 ]="ideogram over/left side line"
att[ 63 ]="ideogram double over/left side line"
att[ 64 ]="ideogram stress marking"
att[ 65 ]="cancel ideogram effects"

sgr() {
    x="$*"
    x=${x// /;}
    echo -en "\e[${x}m"
}

showall() {
    for (( i=0; i<${#attribute[@]}; i++ )); do
	echo -e "${i}: $(sgr ${i})${attribute[$i]}$(sgr 0)"
	if (( (i+1)%22 == 0 )); then
	    read -p "--More--" -n1;
	    echo -en '\r\e[K' 
	    if [[ $REPLY == 'q' ]]; then break; fi
	    if [[ $REPLY == 's' ]]; then ../../mediacopy/mediacopy.sh -o sgr-`date +%s`.png; fi
	fi
    done
}

invistest() {
    echo
    echo "Testing attribute 8 (concealed characters)"
    echo -en "You should not be able to read the following\t>>>"
    sgr 8
    echo -n "fdhrnzvfu bffvsentr" | tr '[a-z]' '[n-za-m]' 
    sgr 0
    echo "<<<"
    echo
    echo "Testing attribute 28 (revealed characters)"
    echo -en "You should be able to read the following \t\t>>>"
    sgr 8
    sgr 28
    echo -n " fnord "
    sgr 0
    echo "<<<"
    echo
}

negtest() {
    echo
    echo "Testing attribute 7 (negative image)"
    echo -en "The following text should appear reversed\t>>>"
    sgr 7
    echo -n "Negative Image"
    sgr 0
    echo "<<<"
    echo
    echo "Testing attribute 27 (positive image)"
    echo -en "The following text should appear normal\t\t>>>"
    sgr 7
    sgr 27
    echo -n "Positive Image"
    sgr 0
    echo "<<<"
    echo
}

generictest() {
    echo
    echo "Testing attribute $1: ${attribute[$1]}"
    echo -en "\t>>>"
    sgr $1
    echo -n " ${att[$1]} "
    sgr 0
    echo "<<<"
    echo
    if [[ -z $2 ]]; then return; fi

    echo "Adding in attribute $2: ${attribute[$2]}"
    echo -en "\t>>>"
    sgr $1
    echo -n "This is '${att[$1]}' ($1)"
    sgr $2
    echo -n " and now '${att[$2]}' ($2)"
    sgr 0
    echo "<<<"
    echo
}

PS3="Your choice? "
select n in "Bold/normal intensity" \
	"Dim/normal intensity" \
	"Italicized/Roman" \
	"Underlined/not underlined" \
	"Blink/steady" \
	"Slow blink/steady" \
	"Negative/positive test" \
	"Invisible/revealed test" \
	"Crossed-out/not crossed-out" \
	"Fraktur/not Fraktur" \
	"Double underlined/not underlined" \
	"Proportional/fixed-width" \
	"Framed/not framed or encircled" \
	"Encircled/not framed or encircled" \
	"Overlined/not overlined" \
	"Every Attribute" \
	"Screenshot" \
	"Quit"; do
    if [[ -z "$n" && "$REPLY" == s* ]]; then n="Screenshot"; fi
    case "$n" in
	Bold*) generictest 1 22
	       ;;
	Dim*) generictest 2 22
	      ;;
	Ital*) generictest 3 23
	       ;;
	Under*) generictest 4 24
		;;
	Blink*) generictest 5 25
		;;
	Slow*) generictest 6 25
	       ;;
	Negat*) negtest
		;;
	Invis*) invistest
		;;
	Crossed*) generictest 9 29
		  ;;
	Frak*) generictest 20 23
	       ;;
	Doub*) generictest 21 24
	       ;;
	Prop*) generictest 26 50
	       ;;
	Frame*) generictest 51 54
		;;
	Encirc*) generictest 52 54
		 ;;
	Over*) generictest 53 55
	       ;;
	Screenshot*) file="sgr-`date +%s`.png"
		     echo "Saving screenshot to $file"
		     ../../mediacopy/mediacopy.sh -o "$file"
		     ;;
	"Every Attribute") showall
			   ;;
	""|Quit) exit
		 ;;
	*) echo "Bug: '$n' wasn't handled."; exit 1
	   ;;
    esac
done

