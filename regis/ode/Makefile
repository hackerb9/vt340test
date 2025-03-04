# Each of the following ReGIS examples use 'ode' to solve ordinary
# differential equations and then 'graph' to turn the values into
# ReGIS graphics. Part of the charm of the VT340 is watching the
# images slowly take form over the course of minutes.

# Try: make lo, make at, or make lv

lo: lorenz.regis
	cat lorenz.regis

lorenz.regis: lorenz.ode
	ode < lorenz.ode | graph -T regis -C -x -10 10 -y -10 10 --top-label "Lorenz Attractor" > lorenz.regis

at: atwoods.regis
	cat atwoods.regis

atwoods.regis: atwoods.ode
	ode < atwoods.ode | graph -T regis -x 9 11 -y -1 1 -m 0 -S 1 -X "l: small mass vertical position" -Y "ldot: small mass vertical velocity" --top-label "Swinging Atwood's Machine" > atwoods.regis

lv: lotka-volterra.regis
	cat lotka-volterra.regis

lotka-volterra.regis: lotka-volterra.ode
	ode < lotka-volterra.ode | graph -T regis -C -x 0 5 -y 0 5 -X prey -Y predator --top-label "Lotka-Volterra phase portrait" > lotka-volterra.regis

orb: orbit.regis
	cat orbit.regis

orbit.regis: orbit.ode
	ode <orbit.ode | graph -T regis -C -x -6.5 1.5 -y -3 3 -B --top-label "One planet orbiting two suns" > orbit.regis


regisoutput: lorenz.regis atwoods.regis lotka-volterra.regis orbit.regis

