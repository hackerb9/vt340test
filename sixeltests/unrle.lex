/* unrle.lex		Remove Run Length Encoding from Sixel data
 *
 * Compile with:   flex unrle.lex && gcc lex.unrle.c -o unrle
 */

 /* Change "yy" prefix to "unrle" for file names */
%option warn
%option prefix="unrle"

/* Functions */
    void parse_bang(char *p);

 /* Define states to be lexed */  
%x sixel

ESC	\x1B
DCS	({ESC}P)|\x90
CSI	({ESC}[)|\x9b
ST	({ESC}\\)|\x9c
NUMBER	[0-9]+
NUMOPT	[0-9]*
			
%%

{DCS}{NUMOPT};{NUMOPT};{NUMOPT}q	ECHO; BEGIN(sixel);
<sixel>{ST}				ECHO; BEGIN(INITIAL);
<sixel>!{NUMBER}.			parse_bang(yytext);

%%

void parse_bang(char *p) {
    if (!p || !*p) return;
    int r = atoi(p+1);
    int c = p[strlen(p)-1];
    while (r--)
	fputc(c, yyout);
 }

int main(int argc, char *argv[]) {

  ++argv, --argc; 		/* skip over program name */

  /* First arg (if any) is input file name */
  yyin = (argc>0) ? fopen( argv[0], "r" ) : stdin;
  if (yyin == NULL) { perror(argv[0]); exit(1);  }

  /* Second arg (if any) is output file name */
  ++argv, --argc;
  yyout = (argc>0) ? fopen( argv[0], "w+" ) : stdout;
  if (yyout == NULL) { perror(argv[0]); exit(1);  }
  
  while (yylex())
    ;
  return 0;
}


int yywrap() {
  return 1;			/* Always only read one file */
}
