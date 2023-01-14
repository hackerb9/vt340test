SRCS := setuptty.c signalhandling.c uplineloadfont.c 

# By default, just compile the binary
uplineloadfont: ${SRCS}

# 'make run' sets up the terminal and runs the program.
# It takes a VT340+ two seconds per character, 
# which means 3.5 minutes for a whole character set)
run: uplineloadfont
	time ./uplineloadfont
	mkdir -p tcs
	mv char-tcs*.six tcs/

# 'make char-tcs.gif' creates an animated image containing all of the characters
char-tcs.gif: tcs/char-tcs*.six
	convert tcs/char-tcs*.six -loop 0 -delay 30 char-tcs.gif

# make debug is like run but saves time by only creating a couple characters.
debug: 
	gcc -DDEBUG ${SRCS}
	./a.out 2>debug.out



