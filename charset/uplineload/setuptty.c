/* setuptty.c

   Helper routines that implement `stty cbreak ixon ixoff`.
   This lets getdelim() read a character at a time.
   Unlike "raw" mode, cbreak allows ^C to cancel the program.

   Todo: consider adding a timeout. 

*/

#include <termios.h>		/* tcsetattr(), et cetera */

static struct termios save_termios;
static int save_fd=-1;


int 
stty_setup(  int fd ) {
  /* Similar to cbreak mode, but also allow XON/XOFF flow control  */
  static struct termios new_termios;

  if (save_fd != -1) return(0);

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

int
stty_restore() {
  /* Restore terminal to setting before stty_setup() was called. */
  if (save_fd >= 0)
    if (tcsetattr(save_fd, TCSAFLUSH, &save_termios) <  0)
      return -1;

  save_fd=-1;
  return 0;
}
