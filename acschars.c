/* Compile with gcc acschars.c -o acschars -lncurses */
/* hackerb9 2020 */

#include <term.h>		/* For keypad_local */
#include <ncurses.h>
int main(void)
{
  initscr();

  int startrow=2;
  if (LINES<12) startrow=0;

  if (LINES>=12) {
    attron(A_REVERSE);
    mvprintw(0,0,"      NCURSES EXTENDED CHARACTERS       \n");
    attroff(A_REVERSE);
    printw("\n");
  }

  int col=1;
  int row=startrow;
  mvprintw(row++, col ,"   ");
  addch(ACS_UARROW);
  printw("  ");
  printw("\n");

  mvprintw(row++,col," ");
  addch(ACS_ULCORNER);
  addch(ACS_HLINE);
  addch(ACS_TTEE);
  addch(ACS_HLINE);
  addch(ACS_URCORNER);
  printw(" ");
  printw("\n");

  mvprintw(row++,col," ");
  addch(ACS_VLINE);
  printw(" ");
  addch(ACS_VLINE);
  printw(" ");
  addch(ACS_VLINE);
  printw("\n");

  move(row++,col);
  addch(ACS_LARROW);
  addch(ACS_LTEE);
  addch(ACS_HLINE);
  addch(ACS_PLUS);
  addch(ACS_HLINE);
  addch(ACS_RTEE);
  addch(ACS_RARROW);
  printw("\n");

  mvprintw(row++,col," ");
  addch(ACS_VLINE);
  printw(" ");
  addch(ACS_VLINE);
  printw(" ");
  addch(ACS_VLINE);
  printw("\n");

  mvprintw(row++,col," ");
  addch(ACS_LLCORNER);
  addch(ACS_HLINE);
  addch(ACS_BTEE);
  addch(ACS_HLINE);
  addch(ACS_LRCORNER);
  printw(" ");
  printw("\n");
  
  mvprintw(row++,col," ");
  printw("  ");
  addch(ACS_DARROW);
  printw("  ");
  printw("\n");

  col=14;
  row=startrow;
  mvprintw(row++, col, "Diamond ");
  addch(ACS_DIAMOND);
  mvprintw(row++, col, "Board   ");
  addch(ACS_BOARD);
  mvprintw(row++, col, "CkBoard ");
  addch(ACS_CKBOARD);
  mvprintw(row++, col, "Block   ");
  addch(ACS_BLOCK);
  mvprintw(row++, col, "Bullet  ");
  addch(ACS_BULLET);
  mvprintw(row++, col, "Degree  ");
  addch(ACS_DEGREE);
  mvprintw(row++, col, "Lantern ");
  addch(ACS_LANTERN);
  
  
  col=29;
  row=startrow;
  printw("\n");
  mvprintw(row++,col, "Scan ");
  addch(ACS_S1);
  addch(ACS_S3);
  addch(ACS_HLINE);
  addch(ACS_S7);
  addch(ACS_S9);
  mvprintw(row++, col, "Pi      ");
  addch(ACS_PI);
  mvprintw(row++, col, "PlMinus ");
  addch(ACS_PLMINUS);
  mvprintw(row++, col, "LEqual  ");
  addch(ACS_LEQUAL);
  mvprintw(row++, col, "GEqual  ");
  addch(ACS_GEQUAL);
  mvprintw(row++, col, "NEqual  ");
  addch(ACS_NEQUAL);
  mvprintw(row++, col, "Strling ");
  addch(ACS_STERLING);
  printw("\n");

  if (LINES>=12) {
    /*Long name is last string after pipe*/
    printw("\n");
    char *p=ttytype;		
    while (*p++)
      ;
    while (p>=ttytype && *p--!='|')
      ;
    p+=2;
    printw("Terminal type: %s\n", p);
  }

  move(LINES-1, 0);
  refresh();

  /* Exit, but don't use endwin as that has the titeInhibit misfeature
     which clears the screen annoyingly. Use reset_shell_mode() instead. */

  putp(keypad_local);		/* disable application keys mode.  */  
  reset_shell_mode();		/* reset the terminal but don't clear screen. */

  //  getch();			/* Old method was wait for key */
  //  endwin();			/* before clearing screen. */

  return 0;
}
