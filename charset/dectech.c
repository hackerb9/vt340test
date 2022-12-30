#include <stdio.h>

/* Print out a table of the DEC Technical Character Set for the VT340, etc */
/* hackerb9 2022 */

int main() {
  int c;
  char *scs="\e+>";		/* Set dec-tech charset to G3 */
  char *ss3="\eO";		/* Single (non-locking) shift to G3 */
  char *dw="\e#6";		/* Double-wide line */
  char *dt="\e#3";		/* Double-size top */
  char *db="\e#3";		/* Double-size bottom */
  char *d[] = { "\e#3", "\e#4" };

  printf(scs);

  printf ("DEC Technical Character Set\n\n");

  int j;
  for (j=0; j<=1; j++) {
    printf("%s     ", d[j]);
    for (int i=2; i<=7; i++) { printf (" %X_", i); }
    printf("\n");
  }
  printf("\n");
  for (int v=0; v<=0xF; v++) {
    for (j=0; j<=1; j++) {
      printf ("%s  _%X ", d[j], v);
      for (int u=2; u<=7; u++) {
	c=u*16+v;			/* ASCII character 0xuv */
	switch(c) {
	case 0x20:  case 0x38:  case 0x39:  case 0x3A:  case 0x3B:  case 0x52:  
	case 0x54:  case 0x55:  case 0x6D:  case 0x75:  case 0x7F:
	  printf("   ");		/* Skip characters "Reserved for future use" */
	  break;

	default:
	  printf(" %s%c ", ss3, c);
	  break;
	}
      }
      printf("\n");
    }
  }
  printf("\n");

  return 0;
}
