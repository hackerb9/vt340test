#!/bin/bash
#
# Use REGIS to draw some graphics on the VT340 screen

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

main() {
    echo -n ${DCS}'3p'		# Enter interactive REGIS mode
    echo -n "W(F15)"    	# Bitmask 111 => Write to all color planes
#    echo -n "S(EA[0,0][799,479])P[0,0]" # Clear screen.
    
    if [[ -z "$1" ]]; then
	raf
    else
	"$@"
    fi

    echo -n ${ST}			# Exit REGIS mode
}
 
bitplane() {

    # Test of writing to each of the four bitmap planes of the VT340.
    echo -n "W(I15)"		# Color "15", normally would turn all 4 bits on
    echo -n "W(F1)"		# Only plane 0 is changed with this bitmask
    echo -n "P[400,0]W(S1)C[+250]W(S0)"
    echo -n "W(F2)"		# Only plane 1
    echo -n "P[200,380]W(S1)C[+250]W(S0)"
    echo -n "W(F4)"		# Only plane 2
    echo -n "P[600,380]W(S1)C[+250]W(S0)"
    echo -n "W(F8)"		# Only plane 3
    echo -n "P[400,240]W(S1)C[+100]W(S0)"

    echo -n "W(S0 F15)"		# Re-enable writing to all planes.

    echo -n "S("		# Fix colormap so intersections look right
    echo -n "M3(H60 L49 S59) M4(H240 L49 S59)"    # Swap green & magenta.
    echo -n "M12(H240 L46 S28)	M11(H60 L46 S28)" # Same for low sat G&M.
#    echo -n "M15(H0 L46 S0)	M7(H0 L100 S0)"	  # Swap medium & bright gray.
    echo -n ")"


    # Notes: Color mixing via planes doesn't make a lot of sense using
    # the default color map. For example, BLUE (0001) and RED (0010)
    # make GREEN (0011). Of course, the colors could be remapped
    # easily enough if that was desired. E.g., 0 Black, 1 Blue, 2 Red,
    # 3 MAGENTA, 4 GREEN, 5 Cyan, 6 Yellow, 7 White

    # Default VT340 colors by bitplane
    #
    # | 8 | 4 | 2 | 1 | Color name   | Additional use    |
    # |---|---|---|---|--------------|-------------------|
    # | 0 | 0 | 0 | 0 | Black        | Screen Background |
    # | 0 | 0 | 0 | 1 | Blue         |                   |
    # | 0 | 0 | 1 | 0 | Red          |                   |
    # | 0 | 0 | 1 | 1 | Green        |                   |
    # | 0 | 1 | 0 | 0 | Magenta      |                   |
    # | 0 | 1 | 0 | 1 | Cyan         |                   |
    # | 0 | 1 | 1 | 0 | Yellow       |                   |
    # | 0 | 1 | 1 | 1 | Gray 50%     | Foreground Text   |
    # | 1 | 0 | 0 | 0 | Gray 25%     | Bold + Blink FG   |
    # | 1 | 0 | 0 | 1 | Dim Blue     |                   |
    # | 1 | 0 | 1 | 0 | Dim Red      |                   |
    # | 1 | 0 | 1 | 1 | Dim Green    |                   |
    # | 1 | 1 | 0 | 0 | Dim Magenta  |                   |
    # | 1 | 1 | 0 | 1 | Dim Cyan     |                   |
    # | 1 | 1 | 1 | 0 | Dim Yellow   |                   |
    # | 1 | 1 | 1 | 1 | Gray 75%     | Bold Foreground   |
}

raf() {
    echo -n "W(I15)"
    echo -n "P[400,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]" # RAF roundels
}

square() { echo -n "F(V[][+$1,][,+$1][-$1,][,-$1])"; }

checkerboard() {
    # Draws a checkerboard, but too slowly.
    echo -n "P[0,0]"
    for x in {1..25}; do
	for y in {1..15}; do
	    if (( (x+y)%2 )); then echo -n "W(I14)"; else echo -n "W(I0)"; fi
	    square 32
	    echo -n "P[,+32]"
	done
	echo -n "P[+32,0]"
    done    
}

plaid() {
    echo -n "P[0,0]W(F15)"	# bitmask 15 == all bits in color index.
    echo -n "S(M0(D))W(I10)"
    echo -n "P[0,0]"
    for y in {1..15}; do
	echo -n "F(V[][+800,][,+16][-800,])"
	echo -n "P[,+32]"
    done

    # 
    echo -n "P[0,0]W(F3 I15)"  # bitmask 3 == change lower two bits only.
    for x in {1..25}; do
	echo -n "F(V[][,+480][+16,][,-480])"
	echo -n "P[+32]"
    done
    echo -n "W(F15 I15)"
}


main "$@"
