/* setuptty.c

   Helper routines that implement `stty cbreak ixon ixoff`.
   This lets getdelim() read a character at a time.
   Unlike "raw" mode, cbreak allows ^C to cancel the program.

   Todo: consider adding a timeout. 

*/

#include <termios.h>		/* tcsetattr(), et cetera */
#include <unistd.h>		/* read() */
#include <stdio.h>		/* fprintf() */

static struct termios save_termios;
static int save_fd=-1;


int 
stty_setup(  int fd ) {
  /* Similar to cbreak mode, but also allow XON/XOFF flow control  */
  static struct termios new_termios;

  if (tcgetattr(fd, &save_termios) <0)
    return(-1);

  new_termios = save_termios;	/* structure copy */


  new_termios.c_iflag &= ~(IGNBRK 		// Turn off ignoring break
			   | PARMRK		// Parity errors read as \0.
			   | ISTRIP		// Do not strip off 8th bit.
			   | INLCR | ICRNL	// Do not swap input NL<->CR.
			   | IGNCR		// Do not ignore CR on input.
			   );
  new_termios.c_iflag |= ( BRKINT	// ^C flushes buffers and sends SIGINT.
			   | IXON	// Enable XON/XOFF on output. 
			   | IXOFF	// Enable XON/XOFF on input.
			   );


  new_termios.c_oflag &= ~OPOST; 		// Disable output processing.

  new_termios.c_lflag &= ~(ICANON  		// Disable canonical input mode
			   | ECHO | ECHONL 	// Do not echo characters
			   | IEXTEN		// Disable input processing.
			   );
  new_termios.c_lflag |= ISIG; 		// Generate signals on keys (^C->INTR).


  new_termios.c_cflag &= ~(CSIZE | PARENB); 	// Do not use parity.
  new_termios.c_cflag |= ( CS8			// Use 8-bit characters.
			   | CLOCAL		// Do not wait if DSR is low.
			   );

  new_termios.c_cc[VMIN] = 1;	/* Read 1 byte at a time. */
  new_termios.c_cc[VTIME] = 0;	/* No timer. */

  if (tcsetattr(fd, TCSAFLUSH, &new_termios) <  0)
    return -1;

  save_fd = fd; 		/* This enables stty_restore */

  return 0;
}

void
discard_input() {
  /* Read from the filedescriptor using a timeout so any data the
     terminal is sending can be received and discarded.

     This is useful if the user hit ^C.

     Note: When a VT340 terminal is sending sixel data, it won't be
     listening to the keyboard while the "WAIT" light is on. The trick
     to get it to hear ^C is:
     1. Hit the Hold Screen button ("F1"),
     2. Wait a few seconds for the WAIT LED to go off and the HOLD
        SCREEN LED to come on. (A white triangle appears in the upper
        left of the screen.)
     3. Press ^C
     4. Hit the Hold Screen button a second time to unpause the terminal

     Why is this important here? Because the Hold Screen process adds
     a significant delay to the response from the terminal. This rules
     out the simple solution of waiting a few seconds for the terminal
     to respond and then presuming it is done.
  */

  char buf[1024];
  struct termios new_termios;

  if (save_fd < 0) return;

  new_termios = save_termios;	/* structure copy */
  
  /* Set input to wait up to x tenths of a second instead of blocking */
  new_termios.c_cc[VMIN] = 0;	/* multiple bytes, up to bufsize */
  new_termios.c_cc[VTIME] = 20;	/* timeout in tenths of a second */

  new_termios.c_lflag &= ~(ICANON  		// Disable canonical input mode
			   | ECHO | ECHONL 	// Do not echo characters
			   | IEXTEN		// Disable input processing.
			   );

  /* Set up terminal so we can drain it without blocking */
  if (tcsetattr(save_fd, TCSANOW, &new_termios) <  0)
    return;

  /* Flush input and output buffers */
  if (tcflush(save_fd, TCIOFLUSH) < 0)
    return;

  while ( read(save_fd, buf, sizeof(buf)) > 0 ) {
      ; /* discard input from terminal */
  }
}

int
stty_restore() {
  /* Restore terminal to setting before stty_setup() was called. */
  if (save_fd >= 0)
    if (tcsetattr(save_fd, TCSAFLUSH, &save_termios) <  0)
      return -1;

  return 0;
}
