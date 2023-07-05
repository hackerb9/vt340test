SRCS := setuptty.c mediacopy.c scsname.c signalhandling.c uplineloadfont.c frippery.c
SRCS += setuptty.h mediacopy.h scsname.h

CFLAGS += -Wall

# By default, just compile the binary
uplineloadfont: ${SRCS}

# 'make run' sets up the terminal and runs the program.
# It takes a VT340+ two seconds per character, 
# which means 3.5 minutes for a whole character set.
run: uplineloadfont
	time ./uplineloadfont


#### Extras

# 'make char-tcs.gif' creates an animated image containing all of the characters
char-tcs.gif: tcs/char-tcs*.six
	convert tcs/char-tcs*.six -loop 0 -delay 30 char-tcs.gif

montages: tcs-montage.png tcs-6x20-montage.png \
		gfx-montage.png gfx-6x20-montage.png \
		lat1-montage.png lat1-6x20-montage.png \
		mcs-montage.png mcs-6x20-montage.png

# 'make debug' is like run but saves time by only creating a couple characters.
debug: 
	gcc -DDEBUG ${SRCS}
	./a.out 2>debug.out

# make driver, just tests out some of the frippery code.
driver: 
	gcc driver.c setuptty.c mediacopy.c frippery.c scsname.c
	./a.out 2>debug.out

# A target for testing the code on terminals that don't support MediaCopy
nomc:
	gcc -DFAKE_MEDIACOPY ${SRCS}
	./a.out 2>debug.out


######################################################################

# 'make tcs-montage.png' creates a montage of all images in the tcs directory 
%-montage.png: %/*.six
	./mkmontage.sh $*
