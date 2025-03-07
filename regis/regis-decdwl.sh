#!/bin/bash

# A test of the interaction of ReGIS graphics upon line attributes.
# (DECDWL - Double Width Line, DECDHL - Double Height Lines).

# Unlike sixel graphics, ReGIS does not reset the line attribute flags
# to single width nor does it clear the underlying text buffer.
# (This is a good thing as it helps wide text and graphics coexist.)

# Define a macro, @C, to draw a 120x120 flag
echo -n $'\eP0p'
cat <<-EOF
	@:Q
	    F(
	      V(B)
	       [+120,]
	       [,+24]
	       [-120,]
	       (E)
	    )
	    V[,+24]
	@;
	@:C
	    W(I(B)) @Q
	    W(I(W)) @Q
	    W(I(R)) @Q
	    W(I(W)) @Q
	    W(I(B)) @Q
	@;
EOF
echo -n $'\e\\'

clear
tput cup 2 5
echo "A test of the interaction of ReGIS graphics upon line attributes."

tput cup 5 20
echo $'\e#5 1.   single-width (normal)'

tput cup 6 10
echo $'\e#62. double-width'

tput cup 7 10
echo $'\e#33. double-height'
tput cup 8 10
echo $'\e#43. double-height'

tput cup 10
echo $'\e#6'

sleep 1

# Draw the flag starting at line 6
echo -n $'\eP0p'
echo -n "P[50,100]@C"
echo -n $'\e\\'

sleep 1

tput cup 10 10
echo "4. text added afterward"

tput cup 12 0
echo "Note: Line 4 was set to double-width before the graphic was shown."
echo "Changing line attributes clears graphics but resizes text."

tput cup 18 0

