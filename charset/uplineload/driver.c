/* Test driver for frippery */

#include <stdio.h>
#include <unistd.h>

int stty_setup( int fd );	/* Defined in setuptty.c */
int stty_restore( );

int get_xy(int *x, int *y);
int get_cell_size(int *x, int *y);

void main() {
  int x,y;

  stty_setup(STDIN_FILENO);	/* Set up raw (char-by-char) termios input */

  get_xy(&x, &y);

  int w,h;
  get_cell_size(&w, &h);

  stty_restore(STDIN_FILENO);	/* Set up raw (char-by-char) termios input */

  printf("x is %d\ty is %d\n", x, y);
  printf("w is %d\th is %d\n", w, h);

}
