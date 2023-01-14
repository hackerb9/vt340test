/* uplineloadfont.c
   hackerb9 2023 

   For every character the terminal can show, use MediaCopy (Esc [ ? 2 i)
   to grab a bitmap of it and save it to a file. 
  
   BUGS:
   o Currently only works for the DEC Technical Character Set.
   o Must be run as:  stty raw ixon ixoff; ./a.out; stty cooked
   o Presumes ST is sent at end of MediaCopy.
   o Should probably use select or poll to handle a timeout.
   o Could be lovelier on the screen as it is working.
   o Takes 3 to 4 minutes to run and ^C doesn't cancel (stdio buffering).

   TODO:
   o Use termios to set terminal to raw while running.
   o On exit, reset terminal settings, flush stdout.
   o 132 column characters.
   o Double Width and Double Height characters.
   o Convert to downlineloadable font format.
   o Investigate why it is so slow:
     * 2.36 seconds per 10x20 character
     * 3m21s for TCS (85 chars)
     * 3m07s for TCS (85 chars) with stty -echo
   o Add ability to select other character sets.

*/



#define _GNU_SOURCE		/* For asprintf() */
#include <stdio.h>
#include <fcntl.h>		/* open() */
#include <unistd.h>		/* write() */
#include <stdlib.h>		/* exit() */
#include <string.h>		/* strlen() */
#include <termios.h>		/* tcsetattr(), et cetera */
#include <signal.h>		/* signal() */

int stty_setup( int fd );	/* Defined in setuptty.c */
int stty_restore( );

/* Control Sequence Introducer */
#define CSI "\e["

/* Device Control String */
#define DCS "\eP"

/* String Terminator */
#define ST "\e\\"

int decgpbm_flag = 0;		/* 0 is transparent background */

void setup_media_copy() {
  
  /* (MC) 2: Send graphics to host communications port */
  printf(CSI "?2i");
      
  /* DECGEPM: Graphics Expanded Print Mode (only for Level 1 Graphics) */
  // l: Compressed:  6" x 3" printout, 800x240
  // h: Expanded:   12" x 8" printout, 1600x480
  printf(CSI "?43h");

  // DECGPCM: Print Graphics Color Mode
  // l: Print in black and white
  // h: Print in color
  printf(CSI "?44h");

  // DECGPCS: Print Graphics Color Space
  // l: Print using HLS colors
  // h: Print using RGB colors (ImageMagick requires this)
  printf(CSI "?45h");

  // DECGPBM: Print Graphics Background Mode (forced on in level 1 sixel)
  printf(CSI "?45");
  if ( decgpbm_flag )
    putchar('h');		// Include background when printing
  else
    putchar('l');		// Do not send background (transparent bg)

  // DECGRPM: Graphics Rotated Print Mode
  // l: Use compress or expand to fit on printer.
  // h: Rotate image 90 degrees CCW. 8" x 12" printout
    printf(CSI "?47l");
}

char *receive_media_copy() {
  // Read stdin and return DCS data received on stdin as a malloc'd string.

  // Nota Bene:
  // * The Esc P at the start and Esc \ at the end will be missing. 
  // * The result must be freed by the calling routine.
  // * Does not handle 8-bit DCS (0x90) and ST (0x9C)

  // Since media copy is not delimited, we look for the DCS string
  // (Esc P) that starts the sixel data. The VT340 in Level 2 sixel
  // mode, actually always sends a string terminator, a carriage
  // return, and sets the DPI before the sixel data, so we have to
  // skip over it. (Esc \ CR Esc [ 2 SP I). 

  FILE *stream;
  char *line = NULL;
  size_t len = 0;
  ssize_t nread;
  
  stream = stdin;
  int delim='\e';		/* Esc \ is the String Terminator */

  /* Read data from terminal until Esc character. */
  char c;
  while (c != 'P') {
    /* Skip everything until we get to a Device Control String (Esc P) */
    nread = getdelim(&line, &len, delim, stream); 
    if (nread == -1) {perror("receive_media_copy, getdelim"); _exit(1);}
    c = getchar(); // Character after the Esc ("P" for DCS string)
  }

  /* We got Esc P, now read the rest of the string up to the first Esc */
  nread = getdelim(&line, &len, delim, stream); 
  if (nread == -1) {perror("receive_media_copy, getdelim"); _exit(1);}
  c = getchar(); // Character after the Esc ("\" for String Terminator)
#ifdef DEBUG
  if (c != '\\') {fprintf(stderr, "BUG! DCS should always end with Esc \\\n");}
#endif

  return line;
}

void save_region_to_file(char *filename, int x1, int y1, int x2, int y2) {
  /* x1,y1 - x2,y2: Area to copy, 0,0 is upper left corner */
  char *regis_h;		/* regis select rectangle to print */
  asprintf(&regis_h, "S(H(P[0,0])[%d,%d][%d,%d])", x1, y1, x2, y2);

  // Send sixel "hard copy" to host using REGIS
  printf(DCS "p");		// Enter REGIS mode
  printf(regis_h);		// Send hard copy sequence
  printf(ST);			// Exit REGIS mode

  char *buf = receive_media_copy();

  FILE *fp = fopen(filename, "w");
  if (!fp) { perror(filename);  _exit(1); } /* Flush stdout of REGIS MC */
  
  fprintf(fp, "\eP%s\e\\", buf);
  
  if (buf) { free(buf); buf=NULL; }
  if (regis_h) { free(regis_h); regis_h=NULL; }
  fclose(fp);
}


static void
cleanup(int signo) {
  stty_restore();		/* Undo termios changes made by stty_setup()   */
  exit(0);
}

int main() {
  int c;
  char *clear="\e[H\e[J";	/* Clear screen */
  char *scs="\e+>";		/* Set dec-tech charset to G3 */
  char *ss3="\eO";		/* Single (non-locking) shift to G3 */

  if (signal(SIGINT, cleanup) == SIG_ERR)
    perror("signal(SIGINT) error");

  stty_setup(STDIN_FILENO);	/* Set up raw (char-by-char) termios input */

  setup_media_copy();

  printf(scs);			/* Select TCS as G3 */

#ifdef DEBUG
  for (int u=6; u<=6; u++) {    for (int v=0xD; v<=0xF; v++) {
#else
  for (int u=2; u<=7; u++) {
    for (int v=0; v<=0xF; v++) {
#endif
      printf(clear);

      c=u*16+v;			/* ASCII character 0xuv */
      switch(c) {
      case 0x20:  case 0x38:  case 0x39:  case 0x3A:  case 0x3B:  case 0x52:  
      case 0x54:  case 0x55:  case 0x6D:  case 0x75:  case 0x7F:
				/* Skip characters "Reserved for future use" */
	continue;

      default:
 	printf("%s%c\n", ss3, c);	/* Show character c from G3 */
	break;
      }
      
      char *out;		/* Output filename */
      asprintf(&out, "char-tcs-%02X.six", c);
      save_region_to_file(out, 0, 0, 9, 19);
      if (out) { free(out); out=NULL; }
    } 
  }

  stty_restore(fileno(stdin));

  return 0;
}
