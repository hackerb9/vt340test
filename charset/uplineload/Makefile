# By default, just compile the binary
uplineloadfont: setuptty.c uplineloadfont.c

# 'make run' sets up the terminal and runs the program.
# It takes a VT340+ two seconds per character, 
# which means 3.5 minutes for a whole character set)
run: uplineloadfont
	stty raw ixon ixoff; time ./uplineloadfont; stty cooked
	mkdir -p tcs
	mv char-tcs*.six tcs/

# 'make char-tcs.gif' creates an animated image containing all of the characters
char-tcs.gif: tcs/char-tcs*.six
	convert tcs/char-tcs*.six -loop 0 -delay 30 char-tcs.gif

# make debug is like run but saves time by only creating a couple characters.
debug: 
	gcc -DDEBUG uplineloadfont.c
	stty raw ixon ixoff; ./a.out 2>debug.out; stty cooked



