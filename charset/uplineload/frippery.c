/* Unnecessary code for positioning the characters to make it look nicer */

#include <stdio.h>
#include <ctype.h>		/* isdigit() */
#include <stdlib.h>		/* atoi() */
#include <unistd.h>		/* exit(), alarm() */

/* Control Sequence Introducer */
#define CSI "\e["


int print_axes(char *cs) {
  switch (cs[0]) {
  case '>':
    printf ("DEC Technical Character Set\n\n");
    break;
  default:
    printf ("Character Set '%s'\n\n", cs);
    break;
  }
    
  printf("     ");
  for (int i=2; i<=7; i++) { printf (" %X_", i); }
  printf("\n");
  printf("\n");
  for (int v=0; v<=0xF; v++) {
    printf ("  _%X \n", v);
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


int get_cell_size(int *w, int *h) {
  /* Return the width and height of each character cell.

     If escape sequences fail (as they would on a VT340), this checks
     whether the terminal is in 80 or 132 column mode and returns
     10x20 or 6x20.

  */
  /* NOTA BENE: This routine presumes termios has already been used to
     read one character at a time (cbreak or raw mode) */

  get_cell_size_xterm(w, h);

  return 0;
}

int cell_width=10;
int cell_height=20;

int get_xy(int *x, int *y) {
  /* Return the x, y pixel coordinates of the upper-left of the current cursor location.
   *
   * This uses the sixel/regis coordinate system; origin is 0,0 at the upper-left.
   * On a VT340: x ∈ [0, 799], y ∈ [0, 479]
   */

  int r, c;
  get_rc(&r, &c);	
  *x = (c-1) * cell_width;	/* Origin of character cells is 1, 1 */
  *y = (r-1) * cell_height;

  return 0;
}
