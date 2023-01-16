/* Unnecessary code for positioning the characters to make it look nicer */

#include <stdio.h>
#include <ctype.h>		/* isdigit() */
#include <stdlib.h>		/* atoi() */
#include <unistd.h>		/* exit(), alarm() */

#include "mediacopy.h"		/* receive_media_copy() */
#include "setuptty.h"		/* stty_setup, stty_restore */
#include "scsname.h"		/* scsname, scslongname */


/* Control Sequence Introducer */
#define CSI "\e["

/* Device Control String */
#define DCS "\eP"

/* String Terminator */
#define ST "\e\\"



int print_axes(char *cs) {
  printf ("%s Character Set\r\n\n", scslongname(cs));

  printf("     ");
  for (int i=2; i<=7; i++) { printf (" %X_", i); }
  printf("\r\n");
  printf("\r\n");
  for (int v=0; v<=0xF; v++) {
    printf ("  _%X \r\n", v);
  }
  return 0;

}

void cup(int r, int c) {
  /* Move cursor to row, column where 1,1 is top left */
  printf("\e[%d;%dH", r, c);
  fflush(stdout);
}

int place_cursor(int u, int v) {
  /* Place the cursor in the grid for character 0xuv */
  cup(v+5, (u-1)*3+4);
  return 0;
}


int get_rc(int *row, int *col) {
  /* Use Cursor Position Report to get the row, column of the cursor

     The origin starts at 1, 1 at the upper left.
     On a VT340: col ∈ [1, 132],  row ∈ [1, 24]
  */
  /* NOTA BENE: This routine presumes termios has already been used to
     read one character at a time (cbreak or raw mode) */

  char *line = NULL;
  size_t len = 0;
  ssize_t nread;

  printf(CSI "6n");

  /* Response is CSI ROW ; COL R where
   * 	ROW and COL are integers and
   * 	CSI is either ESC [ or 0x9B
   */
  nread = getdelim(&line, &len, ';', stdin);
  if (nread == -1) {perror("get_rc():getdelim(';')"); _exit(1);}

  /* line is now CSI ROW ; */
  char *p=line;			/* Skip over CSI */
  while (*p && ! isdigit(*p) )
	 p++;
  *row = atoi(p);

  nread = getdelim(&line, &len, 'R', stdin);
  if (nread == -1) {perror("get_rc():getdelim('R')"); _exit(1);}
  *col = atoi(line);

  if (line)
    free(line);

  return 0;
}




ssize_t getdelim_timeout( char **restrict lineptr,
			  size_t *restrict n,
			  int delim,
			  FILE *restrict stream,
			  double seconds) {

  /* Same as getdelim(), but returns -1 after "timeout" seconds if the
     terminal does not reply at all to an escape sequence.

     Note that this can block if the terminal responds but does not
     include the expected delimiter character.
 */

  /* NOTA BENE: This routine presumes termios has already been used to
     read one character at a time (cbreak or raw mode).
  */

  /* Use select so that we don't block on getdelim(). */
  fd_set set;
  struct timeval timeout;
  int rv;

  FD_ZERO(&set);
  FD_SET(fileno(stream), &set);
  timeout.tv_sec = (int)(seconds);
  timeout.tv_usec = (int)( 1000 * (seconds - (int)(seconds)) );

  /* Wait for a response or timeout */
  rv = select(1, &set, NULL, NULL, &timeout);

  if (rv == 0) {
    /* Timed out */
    return 0;
  }

  if (rv > 0) {
    /* Data came in before the timeout */
    return getdelim(lineptr, n, delim, stream);
  }
  else {
    return -1;
  }
}

int get_cell_size_xterm(int *width, int *height) {
  /* Use XTerm's XTWINOPS escape sequence to get the width and height
     of each character cell.

     Returns -1 on failure. (This always fails on a genuine VT340.)
  */
  /* NOTA BENE: This routine presumes termios has already been used to
     read one character at a time (cbreak or raw mode).
  */

  printf(CSI "16t");
  fflush(stdout);
  /* Response is CSI 6 ; HEIGHT ; WIDTH t, where
   * 	HEIGHT and WIDTH are integers and
   * 	CSI is either ESC [ or 0x9B
   */

  /* Wait for a response or timeout */
  char *line = NULL;
  size_t len = 0;
  ssize_t nread;

  /* Read and ignore CSI 6 ; */
  nread = getdelim_timeout(&line, &len, ';', stdin, 0.25);
  if (nread == -1) {perror("get_cell_size():getdelim_timeout(';')"); _exit(1);}
  if (nread) {
    fprintf(stderr, "\r\nGot A: %s\n", line+1);
  }
  free(line); line=NULL; len=0;

  if (nread > 0) {
    /* Read width */
    nread = getdelim(&line, &len, ';', stdin);
    if (nread == -1) {perror("get_cell_size():getdelim_timeout(';')"); _exit(1);}
    if (nread) {
      fprintf(stderr, "\r\nGot B: %s\n", line);
      *width = atoi(line);
    }
    free(line); line=NULL; len=0;

    if (nread > 0) {
      /* Read height */
      nread = getdelim(&line, &len, 't', stdin);
      if (nread == -1) {perror("get_cell_size():getdelim_timeout('t')"); _exit(1);}
      if (nread) {
	fprintf(stderr, "\r\nGot C: %s\r\n", line);
	*height = atoi(line);
      }
      free(line); line=NULL; len=0;
    }
  }

  if (line) { free(line); line=NULL; len=0; }

  if (nread > 0)
    return 0;
  else
    return -1;
}

int get_cell_size_vt(int *width, int *height) {
  /* Return the width and height of each character cell.
   *
   * Determines this by drawing a fullsize VT100 graphic character and
   * examining the resulting sixel data from MediaCopy.
   *
   * This should work with any terminal that can handle MediaCopy to
   * Host and has support for the VT100 Graphics characters.
   */
  char *clear="\e[H\e[J";	/* Clear screen */
  char *scs="\e*";		/* Set next character charset to G2 */
  char *cs="0";			/* 0 is the symbol for VT100 graphics */
  char *ss2="\eN";		/* Single (non-locking) shift to G2 */

  printf(clear);
  printf("%s%s", scs, cs);	/* Set G2 to be VT100 graphics  */
  printf("%s%c", ss2, 0x6F);	/* Show a horizontal line */
  cup(999,0);			/* Cursor to the bottom line */
  printf("Determining character cell width");

  stty_setup(STDIN_FILENO);	/* Make sure terminal is receiving char at a time */
  setup_media_copy();		/* Tell terminal to send sixels to host */

  // Send sixel data as ReGIS "hard copy" to host.
  printf(DCS "p");
  printf("S(H(P[0,0])[0,0][%d,%d])", 99, 99);
  printf(ST);

  /* buf will be a string of sixels, sans DCS and ST */
  char *buf = receive_media_copy();

  /* Parse buf to count how many columns of pixels the horizontal line
     took up. Format looks something like this (without whitespace):
     0;1;6q"1;1;100;100#1;1;0;49;59#2;1;120;46;71#3;1;240;49;59 [...]
	#7!10E$#0!10x-
	#0!10~-
	#0!10~-
	#0!10B-

     So, basically, skip to the first '!' and read the decimal number.
  */
  char *p = buf;
  while (*p != '\0' && *p != '!')
    p++;

  if (*p == '\0') {		/* This should never happen. */
    fprintf(stderr, "Bug: didn't find ! in sixel from horizontal bar\n");
    exit(1);
  }
  p++;
  *width = atoi(p);
  free(buf);

  /************************************************/
  /* Now do the same as above, but for the height */
  printf(clear);
  printf("%s%c", ss2, 0x78);	/* Show a vertical line */
  cup(1000,0);			/* Cursor to the bottom line */
  printf("Determining character cell height");
  fflush(stdout);

  // Send sixel data as ReGIS "hard copy" to host.
  printf(DCS "p");
  printf("S(H(P[0,0])[0,0][%d,%d])", 99, 99);
  printf(ST);

  /* buf will be a string of sixels, sans DCS and ST */
  buf = receive_media_copy();

  /* Parse buf to count how many columns of pixels the horizontal line
     took up. Format looks something like this (without whitespace):

     0;1;6q"1;1;100;100#1;1;0;49;59#2;1;120;46;71#3;1;240;49;59 [...]
	#7????~~$-
	#7????~~$-
	#7????~~$-
	#7????BB$-
	-------------

     So, basically, count the number of '-' (graphic newlines) until
     we get to a line that replaces '~' with '?', '@', 'B', 'F', 'N', '^'
     				     1	      0    1    1    1    1    1
				     1	      0    0   	1    1 	  1    1
				     1	      0    0	0    1	  1    1
				     1	      0    0	0    0	  1    1
				     1	      0    0	0    0	  0    1
				     1	      0    0   	0    0 	  0    0
  */
  int count=0;
  char *q;

  /* Find first '-' (graphic new line) */
  p = buf;
  while (*p != '\0' && *p != '-') 	// #7????~~$#0~~~~??~~~~-
    p++;				//                      q
  q=p;

  /* Find second '-' */
  p++;
  while (*p != '\0' && *p != '-') 	// -#7????~~$#0~~~~??~~~~-
    p++;				// q                     p
  count += 6;

  /* Now we're looking for the line where the pattern changes */
  while ( *p != '\0' && *p == *q ) {
    if (*p == '-')
      count += 6;
    p++;
    q++;
  }      

  /* Okay, found a difference from one line to the next */
  switch ( *p ) {
  case '!':			/* repeat means we ran out of sixels. */
  case '\0':			/* similarly, this line doesn't count. */
  case '?':			/* 000000 */
    count+=0;
    break;
  case '@':			/* 000001 */
    count+=1;
    break;
  case 'B':			/* 000011 */
    count+=2;
    break;
  case 'F':			/* 000111 */
    count+=3;
    break;
  case 'N':			/* 001111 */
    count+=4;
    break;
  case '^':			/* 011111 */
    count+=5;
    break;
  default:
    stty_restore();
    fprintf(stderr, "bug: get_cell_size_vt: ~ should never change to %c\n", *p);
    exit(1);
  }    
  *height = count;

  free(buf);

  cup(1000,0);			/* Cursor to the bottom line */
  printf("\e[K");		/* Clear old text */
  printf("%d x %d character cell", *width, *height);
  cup(0,0);
  printf(" \r");

  if (*width > 99 || *height > 99)
    return -1;

  return 0;
}


static int width_cache=-1, height_cache=-1;

int get_cell_size(int *w, int *h) {
  /* Return the width and height of each character cell.

     If escape sequences fail (as they would on a true VT340), this
     falls back to get_cell_size_vt, which uses MediaCopy to take
     100x100 snapshot and analyzes the sixels to determine the cell
     size.
  */

  if (width_cache > 0 && height_cache > 0) {
    *w = width_cache;
    *h = height_cache;
    return 0;
  }

  if (get_cell_size_xterm(w, h) < 0) {
    if (get_cell_size_vt(w, h) < 0) {
      return -1;
    }
  }
  
  /* Default if all goes awry */
  if (*w <= 0 || *w > 99)
    *w=10;
  if (*h <= 0 || *h > 99)
    *h=20;

  width_cache=*w;
  height_cache=*h;
  
  return 1;
}


int get_xy(int *x, int *y) {
  /* Return the x, y pixel coordinates of the upper-left of the current cursor location.
   *
   * This uses the sixel/regis coordinate system; origin is 0,0 at the upper-left.
   * On a VT340: x ∈ [0, 799], y ∈ [0, 479]
   */

  int r, c;
  get_rc(&r, &c);

  int w, h;
  get_cell_size( &w, &h );

  *x = (c-1) * w;		/* Origin of character cells is 1, 1 */
  *y = (r-1) * h;

  return 0;
}
