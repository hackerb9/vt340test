SRCS := setuptty.c mediacopy.c scsname.c signalhandling.c uplineloadfont.c frippery.c
SRCS += setuptty.h mediacopy.h scsname.h

CFLAGS += -Wall

# By default, just compile the binary
uplineloadfont: ${SRCS}

# 'make run' sets up the terminal and runs the program.
# It takes a VT340+ two seconds per character, 
# which means 3.5 minutes for a whole character set)
run: uplineloadfont
	time ./uplineloadfont

# 'make char-tcs.gif' creates an animated image containing all of the characters
char-tcs.gif: tcs/char-tcs*.six
	convert tcs/char-tcs*.six -loop 0 -delay 30 char-tcs.gif

# 'make tcs-montage.png' creates a montage of all images in the tcs directory 
# Todo: make this an automatic rule for any directory.
tcs-montage.png: tcs/*.six
	for f in $^; \
	do \
		g=$${f##*-}; \
		g=$${g%.six}; \
		convert $$f $(dir $<)$$g.png; \
	done
	for a in 2 3 4 5 6 7; 
	do \
		for b in 0 1 2 3 4 5 6 7 8 9 A B C D E F; \
		do \
			f=$(dir $<)$$a$$b.png; \
			if [ ! $$f -o -z $$f ]; \
			then \
				convert xc:black -transparent black $$f; \
			fi \
		done \
	done
	montage -title "Technical Character Set 10x20" \
		-label '%t' -background gray33 -fill gray66 \
		-tile 16x6 -scale 600% -geometry 60x60+5+5 \
		$(dir $<)??.png tcs-montage.png
	rm $(dir $<)??.png

# make debug is like run but saves time by only creating a couple characters.
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


