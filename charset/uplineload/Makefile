uplineloadfont:

run: uplineloadfont
	stty raw ixon ixoff; ./uplineloadfont; stty cooked
	mkdir -p tcs
	mv char-tcs*.six tcs/

gif:
	convert tcs/char-tcs*.six -loop 0 -delay 30 char-tcs.gif


