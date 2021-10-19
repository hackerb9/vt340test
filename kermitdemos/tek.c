/* File tek.c from Kermit Demos. Compile with gcc tek.c -lm
 *
 *   -p: send print command to save a screenshot in print.six. 
 *       (will appear to hang if terminal does not support Tek Print to Host) 
*/

/* Modified by hackerb9 to output directly to the screen. */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#define ESC 0x1b
#define FF 0x0c			/* Esc ^L == Clear screen */
#define CAN 0x18		/* Esc ^X == Return from sub-Tek mode */
#define FS 0x1c			/* Esc ^\ == Enter point plotting mode */
#define GS 0x1d			/* Esc ^] == Enter Line drawing mode */
#define US 0x1f			/* Esc ^_ == Enter Alpha (text) mode */
#define ESCZ 0x1a		/* Report terminal type */
#define RED 1			/* ANSI color primaries */
#define GREEN 2
#define BLUE 4
#define color(c) putchar(ESC);putchar('[');putchar('1');\
        putchar(';');putchar('3'); putchar('0'+c);putchar('m');\
	putchar(GS); coord(0, 0);

/* Note: The putchar(GS) at the end of color() was added for VT340
   compatibility. It gets confused by Kermit's ANSI color sequences 
   and puts the following text in the wrong location. */

FILE *fpout; 			/* stream for printing sixels if -p given */

void coord(int x, int y)	/* package coordinates Tek style */
{
        putchar((y / 32) + 32);       /* high y */
        putchar((y % 32) + 96);       /* low y */
        putchar((x / 32) + 32);       /* high x */
        putchar((x % 32) + 64);       /* low x */
}

int main(int argc, char *argv[])
{
        int i, x, y, xc = 750, yc = 500;
        double radius = 125.0;
	int printflag=0;

	if (argc>1 && argv[1][0]=='-' && argv[1][1]=='p')
	  printflag=1;
	
	/* Setup sixel printing */
	if (printflag) {
	  if ((fpout = fopen("tek.six", "wb")) == NULL) /* write binary mode */
	    exit(1);
	  /* See mediacopy.sh for what these mean */
	  fputs("[?2i[?43h[?44h[?45h[?46h[?47l", stdout);
	}
	
	/* clear screen, enter tek mode (new way, for VT340) */
        putchar(ESC); fputs("[?38h", stdout);  
	/* clear screen, enter graphics mode (old way, for Kermit) */
        putchar(ESC); putchar(FF);  

        putchar(ESC); putchar(FF);  
        for (i = 0; i < 40; i++) putchar('\0');       /* padding */
                                                        /* for mode switch */
        color(RED);             
        putchar(GS); coord(210,500);                  /* moveto */
        putchar(US); fputs("shallow fan", stdout);         /* text mode */
        color(GREEN+RED);
        putchar(GS); coord(50,500); coord(200,400);   /* drawto's */
        coord(50,500); coord(200,450); 
        coord(50,500); coord(200,500);
        coord(50,500); coord(200,550);
        coord(50,500); coord(200,600);
        
        color(BLUE);
        putchar(GS); coord(460,500);
        putchar(US); fputs("steep fan", stdout);
        putchar(GS); coord(400,200); coord(400,800);
        coord(400,500); coord(450,200);
        coord(400,500); coord(450,300);
        coord(400,500); coord(450,400);
        coord(400,500); coord(450,500);
        coord(400,500); coord(450,600);
        coord(400,500); coord(450,700);
        coord(400,500); coord(450,800);
        putchar(US); putchar(' ');

        color(GREEN);
        putchar(GS);                          /* simple circle */
        for (i = 0; i <= 360; i++)
                {
                x = radius * cos(M_PI * i / 180.0);
                y = radius * sin(M_PI * i / 180.0);
                coord(x+xc, y+yc);
                }

        color(GREEN+BLUE);
        putchar(GS); coord(75, 65);                   /* moveto */
        putchar(US); fputs("This is a house\n", stdout);  /* text mode */
        putchar(GS);                          /* draw lines for house */
        coord(50,50); coord(300,50);
        coord(300,200); coord(50,200);
        coord(175,250); coord(300,200);
        putchar(GS); coord(50,50); coord(50,200);
        color(RED+BLUE);
                                        /* do some point plotting */
        putchar(GS); coord(350,50);
        putchar(FS);                  /* draw a dotted rectangle */
        for (i = 350; i <= 600; i += 4) coord(i,50);
        for (i = 50;  i <= 200; i += 4) coord(600,i);
        for (i = 600; i >= 350; i -= 4) coord(i,200);
        for (i = 200; i >= 50;  i -= 4) coord(350,i);
        color(RED+GREEN+BLUE);
        putchar(GS); coord(50,10);                    /* move to */
        putchar(US); fputs(" the end.", stdout);          /* text mode */

        fflush(stdout); 		/* flush graphics before sleep */

	/* send a hardcopy of the screen to the host */
	/* XXX Does not work on the VT340 as half of the hardcopy gets
	   sent to screen. XXX */
	if (printflag) {	/* -p */
	  putchar(ESC);
	  putchar(0x17);	/* Esc ETB == Tek hardcopy */

	  /* Wait first for Pq for start of sixels
	   * then for Esc \ for end string. */
	  x=-1; /* previous char */
	  while ( (i=getchar()) != EOF) {
	    fputc(i, fpout);
	    if (x=='P') {
	      if (i=='q') break;
	      /* Ignore digits and semicolons between P and q */
	      if (i==';') continue;
	      if (i>='0' && i<='9') continue;
	    }
	    x=i;
	  }
	  while ( (i=getchar()) != EOF) {
	    fputc(i, fpout);
	    if (x==ESC && i=='\\') break;
	    x=i;
	  }
	  fclose(fpout);
	}

	if (!feof(stdin))
	  sleep(5);		/* Look on my Works, ye Mighty, and despair! */


	/* clear screen, exit tek mode (for VT340) */
        putchar(ESC); fputs("[?38l", stdout);

	/* Workaround VT340 bug that turns off Auto Wrap Mode*/
        putchar(ESC); fputs("[?7h", stdout);

        exit(0);
}
