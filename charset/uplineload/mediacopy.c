/* mediacopy.c: Routines for handling receiving sixel screenshots from the terminal. */

#define _GNU_SOURCE		/* For asprintf() */
#include <stdio.h>
#include <stdlib.h>		/* For free() */
#include <string.h>		/* For strcmp() */
#include <unistd.h>		/* For _exit() */

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
  /* * The terminal must be in cbreak or raw mode (see setuptty.c) */

  // Since media copy is not delimited, we look for the DCS string
  // (Esc P) that starts the sixel data. The VT340 in Level 2 sixel
  // mode, actually always sends a string terminator, a carriage
  // return, and sets the DPI before the sixel data, so we have to
  // skip over those. (Esc \ CR Esc [ 2 SP I). 

  // Side note: Expecting Esc P not a bug
  //
  // * This code does not handle 8-bit DCS (0x90) and ST (0x9C). The
  //   VT340 documentation states that Media Copy will never generate
  //   sixels using those characters, even in 8-bit mode. This has
  //   been confirmed on hackerb9's vt340).

  FILE *stream;
  char *line = NULL;
  size_t len = 0;
  ssize_t nread;
  
  stream = stdin;
  int delim='\e';		/* Chop up input on Esc */

  /* Read data from terminal until next Esc character. */
  char c = '\0';
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
  fflush(stdout);

  char *buf = receive_media_copy();

  FILE *fp = fopen(filename, "w");
  if (!fp) { perror(filename);  _exit(1); } /* Flush stdout of REGIS MC */
  
  fprintf(fp, "\eP%s\e\\", buf);
  
  if (buf) { free(buf); buf=NULL; }
  if (regis_h) { free(regis_h); regis_h=NULL; }
  fclose(fp);
}

