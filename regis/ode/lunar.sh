#!/bin/sh
: lunar lander shell script using ode to solve equations of motion
echo "*** lunar lander ***"
echo -n "grav (m/sec/sec): "; read grav
echo "velocity starts at zero
empty weight 1000 kg"
vel=0
echo -n "available impulse is 10^4 n-sec/kg
	total fuel (kg): "
if read fuel; then :; else exit 0; fi
echo -n "	starting height (m): "
if read height; then :; else exit 0; fi
(echo "y'=v;v'=thrust*1000/m-$grav;m'=-thrust/10"
dur=0
while : ; do
	sleep 2
	sleep $dur
	echo -n "	thrust (kn): " 1>&2
	if read thrust; then :; else break; fi
	echo -n "	duration (sec): " 1>&2
	if read dur; then :; else break; fi
	echo "y=$height;v=$vel;thrust=$thrust;m=$fuel+1000
		print y,v,m from $dur;step 0,$dur"
done) | ode -r 1e-5 | while read height vel mass; do
	echo $mass
	echo "velocity=${vel}m/sec; mass=${mass}kg"
	echo $mass
	fuel=`echo "5k$mass 1000-pq"|dc`
	case $fuel in
	-*|0)	echo out of fuel; exit 1 ;;
	*)	echo fuel=${fuel}kg ;;
	esac
	case $height in
	-*|0)	case $vel in
			-[0-9][0-9]*) echo too fast; exit 1 ;;
			*) echo good landing; exit 0 ;;
		esac ;;
	*)	echo height=${height}m ;;
	esac
done
