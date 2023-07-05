#!/bin/bash
#
# Use REGIS to draw some graphics on the VT340 screen

CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

declare -a functions		# List of test functions that can be run.

main() {
    if [[ -z "$1" ]]; then
	select c in "${functions[@]}"; do
	    if [[ -z "$c" ]]; then
		if [[ ${functions[@]} == *$REPLY* ]]; then
		    c=$REPLY
		fi
	    fi
	    if [[ "$c" ]]; then
		echo Running $c
		break
	    fi
	done
    else
	c="$1"
    fi

    if [[ $(type -t -- "$c") != "function" ]]; then
	echo "Sorry, $c is not a function."
	exit
    fi

    echo -n ${DCS}'3p'		# Enter interactive REGIS mode
    echo -n "W(F15)"    	# Bitmask 111 => Write to all color planes
    echo -n "S(EA[0,0][799,479])P[0,0]" # Clear screen.
    
    $c

    echo -n ${ST}			# Exit REGIS mode
}
 

functions+=(raf)
raf() { # RAF roundels
    cat <<-EOF
	P[400,200]
	W(S1)
	W(I1)C[+100]
	W(I15)C[+66]
	W(I2)C[+33]
	EOF
}

functions+=(bitplane)
bitplane() {
    # Test of writing to each of the four bitmap planes of the VT340.
    echo "W(I15)"		# Color "15", normally would turn all 4 bits on
    echo "W(F1)"		# F1 bitmask: Only plane 0
    echo "P[400,0]W(S1)C[+250]W(S0)"
    echo "W(F2)"		# F2 bitmask: Only plane 1
    echo "P[200,380]W(S1)C[+250]W(S0)"
    echo "W(F4)"		# F4 bitmask: Only plane 2
    echo "P[600,380]W(S1)C[+250]W(S0)"
    echo "W(F8)"		# F8 bitmask: Only plane 3
    echo "P[400,240]W(S1)C[+100]W(S0)"
    echo "P[400,240]W(S1N1)C[+50]W(S0N0)" # Negate inner circle

    echo "W(F15)"		# Re-enable writing to all planes.

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

    # Notes: Color mixing via planes doesn't make a lot of sense using
    # the default color map. For example, BLUE (0001) and RED (0010)
    # make GREEN (0011). Of course, the colors could be remapped
    # easily enough if that was desired. E.g., 0 Black, 1 Blue, 2 Red,
    # 3 MAGENTA, 4 GREEN, 5 Cyan, 6 Yellow, 7 White

    echo "S("		# Adjust colormap so intersections look right
    echo "M4(H240 L49 S59)	M3(H60 L49 S59)" # Swap green & magenta.
    echo "M12(H240 L46 S28)	M11(H60 L46 S28)" # Same for low sat G&M.
    echo "M15(H0 L46 S0)	M7(H0 L100 S0)"	  # Swap medium & bright gray.
    echo ")"

    echo -n ${ST}
    tput cup 1000
    read -s -n1 -p "Magenta & green swapped. Hit any key to reset colormap to default..."
    echo -n $'\r'
    tput el
    echo -n ${DCS}p

    echo "S("		# Undo changes to colormap
    echo "M3(H240 L49 S59)	M4(H60 L49 S59)"
    echo "M11(H240 L46 S28)	M12(H60 L46 S28)"
    echo "M7(H0 L46 S0)		M15(H0 L100 S0)"
    echo ")"
}

functions+=(checkerboard)
checkerboard() {
    # Draws a checkerboard, but too slowly.
    square() { echo -n "F(V[][+$1,][,+$1][-$1,][,-$1])"; }
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

functions+=(plaid)
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

functions+=(resetpalette)
resetpalette() {
    cat <<-EOF
	S(
	M 0 	(  H0   L0   S0)
	M 1 	(  H0  L49  S59)
	M 2 	(H120  L46  S71)
	M 3 	(H240  L49  S59)
	M 4 	( H60  L49  S59)
	M 5 	(H300  L49  S59)
	M 6 	(H180  L49  S59)
	M 7 	(  H0  L46   S0)
	M 8 	(  H0  L26   S0)
	M 9 	(  H0  L46  S28)
	M 10	(H120  L42  S38)
	M 11	(H240  L46  S28)
	M 12	( H60  L46  S28)
	M 13	(H300  L46  S28)
	M 14	(H180  L46  S28)
	M 15	(  H0  L79   S0)
	)
	EOF
}


functions+=(quit)
quit() {
    exit
}
main "$@"
