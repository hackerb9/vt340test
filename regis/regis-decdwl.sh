#!/bin/bash

# A test of the interaction of ReGIS graphics upon line attributes.
# Although only DECDWL is shown, the effect for DECDHL is the same.

#  DECDWL - Double Width Line - Esc # 6
#  DECDHL - Double Height Lines - Esc # 3 and Esc # 4
#  DECSWL - Single Width Line - Esc # 5

# On a VT340, changing the line attributes clears any graphics on that row.
# (Setting line attributes to the same as before has no effect.)

# Unlike sixel graphics, ReGIS does not reset the line attribute flags
# to single width nor does it clear the underlying text buffer.
# (This is a good thing as it helps wide text and graphics coexist.)

# This tests all orderings of Line Attributes, Text, and Graphics.
#
# The most natural ordering is to set the attributes immediately
# before the text, with the graphics coming before or after:
# 1. ATG
# 2. GAT
# Less natural would be to set the attributes immediately after the text:
# 3. TAG
# 4. GTA
# Most peculiar would be to draw graphics between the attributes and text:
# 5. AGT
# 6. TGA

# Although peculiar, #5 is useful because it means it is possible to
# update the text on a double-width line without erasing the graphics.


# Define a macro, @C, to draw a 120x120 flag
echo -n $'\eP0p'
cat <<-EOF
;"Zulu. Natural flag size is 2x2 pixels. Use multiplier 60 for 120x120."
@:Z
    W(M60)
    P7
    W(I(Y))    F( V 3005 )
    W(I(B))    F( V 1663 )
    W(I(R))    F( V 7441 )
    W(I(D))    F( V 5227 )
    P3
    W(I(W))    V 00664422
@;
EOF
echo -n $'\e\\'


DECDWL=$'\e#6'

clear
tput cup 1
cat <<EOF
	      The effect of ordering upon ReGIS graphics
	       with line attributes (double-size text)
EOF

tput cup 5 10
echo ${DECDWL}"1. Attributes, Text, Graphics"

tput cup 7 10
echo "3. Text, Attributes, Graphics"${DECDWL}

tput cup 9			# Line 5. AGT
echo ${DECDWL}

tput cup 10 10
echo "6. Text, Graphics, Attributes"


sleep .5

# Draw the flag using macro starting at line 6
echo -n $'\eP0p'
echo -n "P[50,100]@Z"
echo -n $'\e\\'

sleep .5

tput cup 6 10
echo ${DECDWL}"2. Graphics, Attributes, Text"

tput cup 8 10
echo "4. Graphics, Text, Attributes"${DECDWL}

tput cup 9 10
echo "5. Attributes, Graphics, Text"

tput cup 10			# Line 6. TGA
echo ${DECDWL}


tput cup 12 0
cat <<EOF
Line attributes were changed after drawing ReGIS graphics for 2, 4, & 6.
On a genuine VT340, the graphics on those lines are erased, regardless
of whether there was text on the line or not. Note that setting a line
attribute to be the same as before the graphic was drawn has no effect.

EOF

