/* Test driver for frippery */

#include <stdio.h>
#include <unistd.h>
#include "mediacopy.h"		/* routines for sixel screenshots */
#include "setuptty.h"		/* routines for sixel screenshots */

int get_xy(int *x, int *y);		/* From frippery.c  */
int get_cell_size(int *x, int *y);

int main() {
  int x,y;

  stty_setup(STDIN_FILENO);	/* Set up raw (char-by-char) termios input */

  get_xy(&x, &y);

  int w,h;
  get_cell_size(&w, &h);

  stty_restore();		/* Reset to normal */

  printf("\n");
  printf("x is %d\ty is %d\n", x, y);
  printf("w is %d\th is %d\n", w, h);

  return 0;
}
