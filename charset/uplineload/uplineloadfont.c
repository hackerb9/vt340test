/* uplineloadfont.c
   hackerb9 2023 

   For every character the terminal can show, use MediaCopy (Esc [ ? 2 i)
   to grab a bitmap of it and save it to a file. 
  
   BUGS:
   o Presumes ST is sent at end of MediaCopy; blocks otherwise.
   o Uses select only for initial data, but could block afterward.
   o Takes 3 to 4 minutes to run.

   TODO:
   o Allow selecting character set from command line.
   o Add ability to switch 80/132 columns.
   o Look into querying terminal for installed character sets.
   o Prefix terminal name to each output file. (Use subdirs).
   o Are Double Width and Double Height characters the same, just stretched?
   o Convert to downlineloadable font format.
   o Investigate why it is so slow:
     * 2.36 seconds per 10x20 character
     * 3m21s for TCS (85 chars)
     * 3m07s for TCS (85 chars) with stty -echo
*/



#define _GNU_SOURCE		/* For asprintf() */
#include <stdio.h>
#include <fcntl.h>		/* open() */
#include <unistd.h>		/* write() */
#include <stdlib.h>		/* exit() */
#include <string.h>		/* strlen() */
#include <termios.h>		/* tcsetattr(), et cetera */
#include <signal.h>		/* signal() */

#include "mediacopy.h"	   /* setup_media_copy, save_region_to_file */
#include "setuptty.h"	   /* stty_setup, stty_restore */
#include "scsname.h"	   /* scsname, scslongname */

void cleanup(int signo);	/* Defined in signalhandling.c */

int print_axes(char *scs);	/* Defined in frippery.c */
int place_cursor(int u, int v);
int get_xy(int *x, int *y);
int get_cell_size(int *w, int *h);


int main() {
  int c;
  char *clear="\e[H\e[J";	/* Clear screen */
  //char *scs="\e+>";		/* Set dec-tech charset to G3 */
  //char *scs="\e+0";		/* 0 is the symbol for the vt100 gfx charset */
  char *scs="\e+%5";		/* Set MCS charset to G3 */
  //char *scs="\e/A";		/* Set Latin-1 charset to G3 */
  char *ss3="\eO";		/* Single (non-locking) shift to G3 */
  int w, h;			/* cell width & height */

  if (signal(SIGINT, cleanup) == SIG_ERR)
    perror("signal(SIGINT) error");

  printf(clear);
  setup_media_copy();
  stty_setup(STDIN_FILENO);	/* Set up raw (char-by-char) termios input */
  get_cell_size(&w, &h);	/* determine char cell size automatically */
  print_axes(scs);		/* Show title and hex axes */
  printf(scs);			/* Select character set as G3 */

#ifdef DEBUG
  for (int u=6; u<=6; u++) {    for (int v=0xD; v<=0xF; v++) {
#else
  for (int u=2; u<=7; u++) {
    for (int v=0; v<=0xF; v++) {
#endif
      place_cursor(u, v);
      int x, y;
      get_xy(&x, &y);

      c=u*16+v;			/* ASCII character 0xuv */

      if ( strcmp(scsname(scs), "tcs") == 0) {
	/* Skip TCS characters "Reserved for future use" */
	switch(c) {
	case 0x20:  case 0x38:  case 0x39:  case 0x3A:  case 0x3B:  case 0x52:
	case 0x54:  case 0x55:  case 0x6D:  case 0x75:  case 0x7F:
	  continue;
	}
      }
      if ( strcmp(scsname(scs), "mcs") == 0) {
	/* Skip DEC Supplemental MCS characters "Reserved for future use" */
	switch(c) {
	case 0x20:  case 0x24:  case 0x26:  case 0x2C:  case 0x2D:  case 0x2E:
	case 0x2F:  case 0x34:  case 0x38:  case 0x3E:  case 0x50:  case 0x5E:
	case 0x70:  case 0x7E:  case 0x7F:
	  continue;
	}
      }

      printf("%s%c\n", ss3, c);	/* Show character c from G3 */
      
      char *out;		/* Output filename */
      asprintf(&out, "char-%s-%dx%d-%02X.six", scsname(scs), w, h, c);
#ifndef FAKE_MEDIACOPY
      save_region_to_file(out, x, y, x+w-1, y+h-1);
#endif
      if (out) { free(out); out=NULL; }
    } 
  }

  stty_restore(fileno(stdin));
  place_cursor(0x7, 0xF);
  printf("\n");
  printf("\n");

  return 0;
}
