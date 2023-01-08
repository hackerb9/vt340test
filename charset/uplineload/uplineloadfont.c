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
   o Output files start w/ escape sequences that confuse ImageMagick.

   TODO:
   o 132 column characters.
   o Double Width and Double Height characters.
   o This should replace mediacopy.sh.
   o Convert to downlineloadable font format.

*/



#define _GNU_SOURCE		/* For asprintf() */
#include <stdio.h>
#include <fcntl.h>		/* open() */
#include <unistd.h>		/* write() */
#include <stdlib.h>		/* exit() */
#include <string.h>		/* strlen() */



char *CSI="\e[";		/* Control Sequence Introducer */
char *DCS="\eP";		/* Device Control String */
char *ST="\e\\";		/* String Terminator */

int decgpbm_flag = 0;		/* 0 is transparent background */

void setup_media_copy() {
  
  /* (MC) 2: Send graphics to host communications port */
  fputs(CSI, stdout); fputs("?2i", stdout);
      
  /* DECGEPM: Graphics Expanded Print Mode (only for Level 1 Graphics) */
  // l: Compressed:  6" x 3" printout, 800x240
  // h: Expanded:   12" x 8" printout, 1600x480
  fputs(CSI, stdout); fputs("?43h", stdout);

  // DECGPCM: Print Graphics Color Mode
  // l: Print in black and white
  // h: Print in color
  fputs(CSI, stdout); fputs("?44h", stdout);

  // DECGPCS: Print Graphics Color Space
  // l: Print using HLS colors
  // h: Print using RGB colors (ImageMagick requires this)
  fputs(CSI, stdout); fputs("?45h", stdout);

  // DECGPBM: Print Graphics Background Mode (forced on in lvl 1 graphics)
  fputs(CSI, stdout); fputs("?45", stdout);
  if ( decgpbm_flag )
    putchar('h');		// Include background when printing
  else;
    putchar('l');		// Do not send background (transparent bg)

  // DECGRPM: Graphics Rotated Print Mode (90 degrees counterclockwise)
  // l: Use compress or expand to fit on printer.
  // h: Rotate image CCW. 8" x 12" printout
  fputs(CSI, stdout); fputs("?47l", stdout);
}

char *receive_media_copy() {
  // Read stdin and return DCS data received on stdin as a string.
  // Note, the Esc P at the start and Esc \ at the end will be missing. 

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
#if DEBUG
    fprintf(stderr, "len is %d, nread is %d\n", strlen(line), nread);
    fprintf(stderr, "line: %s\t", line);
    fprintf(stderr, "c: %c\n", c);
#endif
  }

  /* We got Esc P, now read the rest of the string up to the first Esc */
  nread = getdelim(&line, &len, delim, stream); 
  if (nread == -1) {perror("receive_media_copy, getdelim"); _exit(1);}
  c = getchar(); // Character after the Esc ("\" for String Terminator)
#if DEBUG
  fprintf(stderr, "len is %d, nread is %d\n", strlen(line), nread);
  fprintf(stderr, "line: %s\t", line);
  fprintf(stderr, "c: %c\n", c);
  if (c != '\\') {fprintf(stderr, "BUG! DCS should always end with Esc \\\n");}
#endif

  return line;
}

void save_region_to_file(char *filename, int x1, int y1, int x2, int y2) {
  /* x1,y1 - x2,y2: Area to copy, 0,0 is upper left corner */
  char *regis_h;		/* regis select rectangle to print */
  asprintf(&regis_h, "S(H(P[0,0])[%d,%d][%d,%d])", x1, y1, x2, y2);

  // Send sixel "hard copy" to host using REGIS
  fputs(DCS, stdout); putchar('p'); 	// Enter REGIS mode
  fputs(regis_h, stdout);		// Send hard copy sequence
  fputs(ST, stdout);			// Exit REGIS mode

  char *buf = receive_media_copy();

  FILE *fp = fopen(filename, "w");
  if (!fp) { perror(filename);  _exit(1); } /* Flush stdout of REGIS MC */
  
  fprintf(fp, "\eP%s\e\\", buf);
  
  if (buf) { free(buf); buf=NULL; }
  if (regis_h) { free(regis_h); regis_h=NULL; }
  fclose(fp);
}


int main() {
  int c;
  char *scs="\e+>";		/* Set dec-tech charset to G3 */
  char *ss3="\eO";		/* Single (non-locking) shift to G3 */
  char *clear="\e[H\e[J";	/* Clear screen */

  setup_media_copy();

  fputs(scs, stdout);			/* Select TCS as G3 */

#ifdef DEBUG
  for (int u=6; u<=6; u++) {    for (int v=0xD; v<=0xF; v++) {
#else
  for (int u=2; u<=7; u++) {
    for (int v=0; v<=0xF; v++) {
#endif
      fputs(clear, stdout);

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

  return 0;
}
