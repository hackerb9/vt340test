#!/bin/bash -e

REGIS=$'\eP0p'
ST=$'\e\\'

trap cleanup EXIT
cleanup() {
    echo -n ${ST}
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


main() {
    echo -n ${REGIS}
    echo ';P[0,0]W(I(R))T"Please wait, loading macros into terminal"'

    cat alfa.regis bravo.regis charlie.regis delta.regis echo.regis \
        foxtrot.regis golf.regis hotel.regis india.regis juliet.regis \
	kilo.regis lima.regis mike.regis november.regis oscar.regis \
	papa.regis quebec.regis romeo.regis sierra.regis tango.regis \
	uniform.regis victor.regis whiskey.regis xray.regis yankee.regis \
	zulu.regis

    echo -n ${ST}

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
