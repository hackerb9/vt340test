/* uplineloadfont.c
   hackerb9 2023 

   For every character the terminal can show, use MediaCopy (Esc [ ? 2 i)
   to grab a bitmap of it and save it to a file. 
  
   BUGS:
   o Odd glitch in MediaCopy of character 0x6E (ν, Nu).
   o Currently only works for the DEC Technical Character Set.
   o Must be run as:  stty raw ixon ixoff; ./a.out; stty cooked
   o Presumes ST is sent at start and end of MediaCopy.
   o Should probably use select or poll to handle a timeout.
   o Could be lovelier on the screen as it is working.
   o Output files start w/ escape sequences that confuse ImageMagick.

   TODO:
   o 132 column characters.
   o Double Width and Double Height characters.
   o Check: same glitches as with `read` in mediacopy.sh?
   o If this works, extend to replace mediacopy.sh.
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
  // Return data received on stdin as a string.
  // Since media copy is not delimited, we return after timing out.
  FILE *stream;
  char *line = NULL;
  size_t len = 0;
  ssize_t nread;
  
  stream = stdin;
  int delim='\\';		/* Esc \ is the String Terminator */

  /* Read data from terminal until \ character. */
  while (line == NULL) {
    nread = getdelim(&line, &len, delim, stream); 
    if ( strlen(line)==2 && line[1]=='\\' ) {
      /* MediaCopy sends an initial ST, so skip it. */
      free(line); line=NULL; len=0;
    }
  }
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
  
  fprintf(fp, buf);
  
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

  for (int u=2; u<=7; u++) {
    for (int v=0; v<=0xF; v++) {
      fputs(clear, stdout);

      c=u*16+v;			/* ASCII character 0xuv */
      switch(c) {
      case 0x20:  case 0x38:  case 0x39:  case 0x3A:  case 0x3B:  case 0x52:  
      case 0x54:  case 0x55:  case 0x6D:  case 0x75:  case 0x7F:
				/* Skip characters "Reserved for future use" */
	continue;

      default:
	fputs(ss3, stdout); putchar(c);	/* Show character c from G3 */
	break;
      }
      
      char *out;		/* Output filename */
      asprintf(&out, "char-tcs-%02X.six", c);
      save_region_to_file(out, 0, 0, 10, 20);
      if (out) { free(out); out=NULL; }
    } 
  }

  return 0;
}
