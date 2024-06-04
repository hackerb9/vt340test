#!/bin/bash
# Graph paper generator.
#
#     Given a grid size, display an image of graph paper on the screen.
#     Useful for checking sixel cursor alignment and aspect ratio in
#     terminal emulators.
#
# hackerb9, June 2024

# Note: Gridlines are TWO pixels wide so that there is a complete
#       border around the final image which reads visually as half a
#       gridline in width. Due to this, three pixels is the absolute
#       minimum value for minor gridlines and five pixels is the
#       smallest practical minimum.

# TODO: Use getopt to change final line ending, macro parameter, etc.

declare -i width=3 height=2 defaultminor=10 minor major=10

# At the end of the image, the cursor is advanced forward text/graphic newline.
declare ending="nlonly"		# nlonly, gnlonly, both, or neither


usage() {
    local b=$(tput bold) i=$(tput sitm) r=$(tput sgr0)
    local -i minor=${minor:-defaultminor}
    local -i majsize=$((minor * major))
    echo -n "Usage: $(basename $0) "
    echo -n "[${i}width${r}${b}x${r}${i}height${r}] "
    echo -n "[${i}minor${r} [${i}major${r}]] "
    echo
    cat <<-EOF
	where
	      ${i}minor${r} is number of pixels in each small square's side, and
	      ${i}major${r} is number of small squares in each large square's side.
	      ${i}width${r} is number of major squares horizontally,
	     ${i}height${r} is number of major squares vertically, 

	Examples:

	    $(basename $0) 20		# Each small square is 20x20 pixels
	    $(basename $0) 8 10 10x6	# 8x8 minor, 80x80 major, 800x480 total

	Defaults: $minor $major ${width}x$height
	    minor=$minor, major=$major, width=$width, height=$height

	EOF
    printf "%20s" "minor squares: "
    echo "${minor}x${minor} pixels"
    printf "%20s" "major squares: "
    echo "${majsize}x${majsize} pixels"
    echo "# of major squares: ${width} by ${height}"
    printf "%20s" "total image size: "
    echo "$((majsize * width))x$((majsize * height)) pixels"
    exit
}


main() {
    for opt; do
	if [[ $opt =~ ^([0-9]*)x([0-9]*)$ ]]; then
	    width=${BASH_REMATCH[1]}
	    height=${BASH_REMATCH[2]}
	elif [[ $opt =~ ^[0-9]+$ ]]; then
	    if [[ -z "$minor" ]]; then
		minor=$opt
	    else
		major=$opt
	    fi
	else
	    usage 
	fi
    done

    minor=${minor:-defaultminor}
    if (( minor < 3 )); then echo "minor cannot be less than 3">&2; exit 1; fi

    local -a args
    args+=(-size ${minor}x${minor} -shave 1x1 xc:aliceblue)
    args+=(-duplicate $((major - 1)))
    args+=(-bordercolor paleturquoise -border 1x1)
    args+=(+append -duplicate $((major - 1)) -append)
    args+=(-shave 1x1 -bordercolor skyblue -border 1x1)
    args+=(-duplicate $((height - 1)) -append)
    args+=(-duplicate $((width - 1)) +append)

    local nl="\n" esc=$'\e'; bslash="\\\\" gnl="-" st="$esc$bslash"

    convert "${args[@]}" sixel:- |
	case $ending in 
	    nlonly)		# At image end, remove GNL, add text NL.
		sed -r "s/${gnl}?${st}${nl}?/${st}${nl}/"
		;;
	    gnlonly)		# Remove NL, add GNL.
		sed -r "s/${gnl}?${st}${nl}?/${gnl}${st}/"
		;;
	    both)		# Add both graphic and text newline.
		sed -r "s/${gnl}?${st}${nl}?/${gnl}${st}${nl}/"
		;;
	    neither)		# Remove both graphic and text newline.
		sed -r "s/${gnl}?${st}${nl}?/${st}/"
		;;
	    *)
		cat
		;;
	esac
}

main "$@"

######################################################################
# This script is just a verbose way of doing:
#
# convert -size 18x18 xc:aliceblue -shave 1x1 -duplicate 4 -bordercolor paleturquoise -border 1x1 +append -duplicate 4 -append -shave 1x1 -bordercolor skyblue -border 1x1 -duplicate 3 -append -duplicate 7 +append sixel:-

