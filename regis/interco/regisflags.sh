#!/bin/bash -e

REGIS=$'\eP0p'
ST=$'\e\\'

trap cleanup EXIT
cleanup() {
    echo -n ${ST}
    stty echo
}


scale() {
    # Given a number n, rnd, and max
    # where a rnd is a random integer from 0 to max,
    # Return a random number from 1 to n, with a bias towards small numbers.
    # (Uses a roughly geometric distribution, reversed.)

    # The current bias function was chosen for aesthetics so
    # middling-small flags are the norm. Large flags can occur but
    # extremely rarely and only a specific values.

    local n=${1:-100} rnd=$2 max=$3
    # rnd is a random number from  0 to max.  ($RANDOM is broken in functions).
    echo "r = ($n-1) * ln($rnd+1)/ln($max);
	  scale = 0; ($n - r)/1" | bc -l
}    

loadflags() {
    # Load all the macros into the VT340's memory for faster drawing.
    # For details on the interspersed gobbledygook, see the file interco.regis.
    echo -n ${REGIS}
    echo ";S(E)W(M1)P[0,360]"
    echo 'W(I(R))T(S2)"Please wait, loading macros into terminal."T(S1)'
    cat alfa.regis bravo.regis charlie.regis
    echo "W(M20)P[0,0]"
    cat delta.regis echo.regis
    echo "W(I(R))F(V(B)P666666666666666V[]P200000000V[]P2222222222222V[]V(E))"
    cat	foxtrot.regis golf.regis hotel.regis
    echo "P600000000"
    cat	india.regis juliet.regis
    echo "W(I(W))F(V(B)P6666666666666V[]P200000000V[]P22222222222V[]V(E))"
    cat	kilo.regis lima.regis mike.regis
    echo "P 6 0000 0000"
    cat november.regis oscar.regis
    echo "W(I(R))F(V(B)P 666 66666 666V[]P 2 0000 0000V[]P 22 22222 22V[]V(E))"
    cat papa.regis quebec.regis romeo.regis 
    echo "P 6 0000 0000"
    cat sierra.regis tango.regis
    echo "W(I(W))F(V(B)P 66 66666 66V[]P 2 0000 0000V[]P 2 22222 2V[]V(E))"
    cat uniform.regis victor.regis whiskey.regis
    echo "P 6 0000 0000"
    cat  xray.regis yankee.regis
    echo "W(I(R))F(V(B)P 6 66666 6V[]P 2 0000 0000V[]P 22222V[]V(E))"
    cat zulu.regis

    echo -n ${ST}
}


main() {
    stty -echo			# Don't interpret stray keystrokes as ReGIS
    loadflags
    # Clear screen with dark grey.
    echo -n "${REGIS}W(I8)F(V[0,0][+799][,+479][-799][,-479])${ST}"

    local -A natsize=( [A]=4 [B]=4 [C]=5 [D]=4 [E]=2 [F]=2 [G]=6 [H]=2
		       [I]=4 [J]=3 [K]=2 [L]=2 [M]=6 [N]=4 [O]=1 [P]=5
		       [Q]=1 [R]=5 [S]=5 [T]=3 [U]=2 [V]=6 [W]=5 [X]=5
		       [Y]=5 [Z]=2 )
    local -a flags=( ${!natsize[@]} )

    while :; do
	local f=${flags[$(( $RANDOM % (${#flags[@]}) ))]}
	local -i ns=${natsize[$f]}
	rnd=$RANDOM		# Note bash has a bug in `echo $RANDOM`
	local -i scale=$(scale $(( 480/ns )) $rnd 32767 )
	local -i x=$(( $RANDOM % (800 - ns*scale + 1) ))
	local -i y=$(( $RANDOM % (480 - ns*scale + 1) ))
	echo -n ${REGIS}
	echo "P[$x,$y]"
	echo "W(M${scale})"
	echo "@${f}"
	echo -n ${ST}
    done
}

main "$@"
