/* For catching ^C and other cleanup */

#include <stdio.h>
#include <termios.h>		/* For tcflush(), TCIOFLUSH */
#include <unistd.h>		/* For STDIN_FILENO */
#include <stdlib.h>		/* For exit() */

int stty_restore( );		/* Defined in setuptty.c */


void
discard_input() {
  /* Read from stdin discarding any excess data the terminal is
     sending. This works by sending the DA escape sequences (Esc [ c)
     and waiting for the terminal to respond with Esc ... c

     This is useful if the user hit ^C.

	 Note: When a VT340 terminal is sending sixel data,
	 it won't be listening to the keyboard while the
	 "WAIT" light is on. The trick to get it to hear ^C
	 is:

	 1. Hit the Hold Screen button ("F1"),

	 2. Wait a few seconds for the WAIT LED to go off
	    and the HOLD SCREEN LED to come on. (A white
	    triangle also flashes in the upper left of the
	    screen.)

	 3. Press ^C

	 4. Hit the Hold Screen button a second time to
	    unpause the terminal

     Why is this important here? Because this Hold Screen process adds
     a significant delay to the response from the terminal. This rules
     out the simple solution of waiting a few seconds for the terminal
     to respond and then presuming it is done.

     Instead, we send a DA request and then wait for that to
     come back from the terminal.
  */

  /* Flush input and output buffers */
  tcflush(STDIN_FILENO, TCIOFLUSH);

  /* Ask the terminal to send Device Attributes (Esc [ ... c) */
  printf("\e[c");

  /* State machine to get DA response, skip DCS */
  enum daresponse { BEGIN, GOTESC, GOTCSI, GOTDA };
  enum daresponse state = BEGIN;

  int c;
  while ( state != GOTDA ) {
    c = getchar();
    if (c<0) break;		/* e.g., EOF */

#ifdef DEBUG
    if (c != '\e') printf("%c", c);  else printf("ESC");
#endif

    switch (state) {
    case BEGIN:
      if ( c == '\e' )
	state = GOTESC;
      break;
    case GOTESC:
      if ( c == '[' )
	state = GOTCSI;
      else if ( c == '\e' )
	state = GOTESC;
      else
	state = BEGIN;
      break;
    case GOTCSI:
      if ( c == 'c' )
	state = GOTDA;
      else if ( c == ';' || c == '?' || (c>='0' && c<='9') )
	state = GOTCSI;
      else if ( c == '\e' )
	state = GOTESC;
      else
	state = BEGIN;
      break;
    default:
      fprintf(stderr, "BUG. State should never be %d.\n", state);
      _exit(1);
    }	  
  }

  return;
}

void
cleanup(int signo) {
  fprintf(stderr, "\rDiscarding stdin from terminal...");
  discard_input();
  fprintf(stderr, "\r\e[K");	/* erase to end of line */

  if (stty_restore() < 0)	/* Undo termios changes made by stty_setup() */
    fprintf(stderr, "BUG! Why didn't tcsetattr work?");
  exit(0);
}
