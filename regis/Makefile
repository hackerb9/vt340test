# Each of the following ReGIS examples use 'ode' to solve ordinary
# differential equations and then 'graph' to turn the values into
# ReGIS graphics. Part of the charm of the VT340 is watching the
# images slowly take form over the course of minutes.

# Try: make lo, make at, or make lv

lo: lorenz
	ode < lorenz | graph -T regis -C -x -10 10 -y -10 10 --top-label "Lorenz Attractor"

lorenz.regis: lorenz
	ode < lorenz | graph -T regis -C -x -10 10 -y -10 10 --top-label "Lorenz Attractor" > lorenz.regis

at: atwoods
	ode < atwoods | graph -T regis -x 9 11 -y -1 1 -m 0 -S 1 -X "l: small mass vertical position" -Y "ldot: small mass vertical velocity" --top-label "Swinging Atwood's Machine"

atwoods.regis: atwoods
	ode < atwoods | graph -T regis -x 9 11 -y -1 1 -m 0 -S 1 -X "l: small mass vertical position" -Y "ldot: small mass vertical velocity" --top-label "Swinging Atwood's Machine" > atwoods.regis

lv: lotka-volterra
	ode < lotka-volterra | graph -T regis -C -x 0 5 -y 0 5 -X prey -Y predator --top-label "Lotka-Volterra phase portrait"

lotka-volterra.regis: lotka-volterra
	ode < lotka-volterra | graph -T regis -C -x 0 5 -y 0 5 -X prey -Y predator --top-label "Lotka-Volterra phase portrait" > lotka-volterra.regis

regisoutput: lorenz.regis atwoods.regis lotka-volterra.regis
