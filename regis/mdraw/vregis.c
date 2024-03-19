#include <stdio.h>     
#include <string.h>

#define ESC 0x1B
/*	scaling is inverse, smaller scale wider output looks */
#define XSCALE (149.57)
#define YSCALE (150.5)

/*
#define XSCALE (150.588)
#define YSCALE (148.837)
*/

int maxx=0,maxy=0,minx=0,miny=0;

#define DO_TEX	1
#define TEX_OUTLINE 2
#define TEX_TEXT 4
#define JUST_VIEW 8
int do_tex=0;

#define FONTS 4
char font_names[FONTS][20]={"mtextzero","mtextone","mtexttwo","mtextthree"};
char font_defs[FONTS][40]={"cmr5","cmtt8","cmtt12 scaled \\magstep1",
			"cmtt12 scaled \\magstep4"};

mx(a,b)
int a,b;
{
	if (a>b) return(a);
	else return(b);
}
mn(a,b)
int a,b;
{
	if (a<b) return(a);
	else return(b);
}

max(a,b,c)
int a,b,c;
{ int d;
	return(mx(a,mx(b,c)) );
}
min(a,b,c)
int a,b,c;
{ int d;
	return(mn(a,mn(b,c)) );
}                
plot_reset()
{	
	plot_on();	
	printf("S(E)W(P1)T(S1)");
	plot_off();
	printf("%c[1;1H",ESC);
}
plot_on()
{
	printf("%cPp",ESC);
}
plot_off()
{
	printf("%c\\",ESC);
}

vector(dx,dy)
int dx,dy;
{
	/*	V[+-dx,+-dy] */

	printf("V[%+d,%+d]",dx,dy);

}

move_to(x,y)
int x,y;
{                                               
	/* 	P[x,y]	*/

	printf("P[%d,%d]",x,y);

}
delta_move_to(x,y)
int x,y;
{                                               
	/* 	P[+-x,+-y]	*/

	printf("P[%+d,%+d]",x,y);

}

/*
 * output to the TeX out_file the string at x,y coords
 */

tex_text(out_file,text,t_size,x,y)
FILE *out_file;
char text[];
int t_size;
int x,y;
{
	char *start;
	float dx,dy;

	dx=((float)(x)/XSCALE)+.343;
	dy=((float)(y)/YSCALE);

	text[strlen(text)-2]='\0';	

	for(start=text; *start++ != '"';);

	fprintf(out_file,"\\mdrawtext %.2f %.2f {\\%s %s}\n",
			dx,dy,font_names[t_size],start);
                                      
                        

}

process_file(dx,dy,fp,out_file)
int dx,dy;
FILE 	*fp,*out_file;
{
	extern int maxx,maxy,miny,minx,do_tex;
	int x,w,y,h,dummy;
	int l_style= -1;
	int t_size; 
	char style[200],dummy_line[200],command[200],sdum[7];
	char *start;

 plot_on();
        
	dummy=fgets(dummy_line,80,fp);

	while( dummy != NULL)
	{

	if (strchr(dummy_line,'[') != 0)
	{
	dummy=fgets(dummy_line,80,fp);
	sscanf(dummy_line,"%d%d%d%d",&x,&y,&w,&h);
	process_file(dx+x,dy+y,fp,out_file);
	plot_on();
	dummy=fgets(dummy_line,80,fp);
	dummy=fgets(dummy_line,80,fp);
	dummy=fgets(dummy_line,80,fp);

	}
	else if (strchr(dummy_line,']') != 0) 
	{ 	plot_off();
		return(1);
	}
	else
	{
	sscanf(dummy_line,"%d%d%d%d",&x,&y,&w,&h);
	move_to(dx+x,dy+y);

	fgets(command,200,fp);

  	fgets(style,100,fp);
	dummy=fgets(dummy_line,200,fp);
	dummy=fgets(dummy_line,200,fp);
	dummy=fgets(dummy_line,200,fp);

	sscanf(style,"%s %d",sdum,&l_style) ;
                     
	if( l_style != -1)   
	 {
	 printf("W(P%d)",l_style);              

	 }	/* end of linestyle */
	
	if ( (out_file != NULL) && ( (do_tex & TEX_TEXT) != 0)
		&& (strncmp(command," T(",3)==0)  ) 
	{ 

	for(start=command; *start != 'S'; start++);
	sscanf(start,"S%d)",&t_size);

	 if (t_size < FONTS )
	{
	 if (t_size == 0)
	 tex_text(out_file,command,t_size,dx+x,dy+y-3);
	 else
	 tex_text(out_file,command,t_size,dx+x,dy+y);
	}
	else
		{ 
		 printf(";%s",command);
		}
	}	
	else
		{
		printf(";%s",command);
		}
	} /* end of not [ or ] */

	}   /* end of while */

	plot_off();
}

tex_file(filename,in_file)
FILE *in_file;
char *filename;
{
	FILE *fp;
	char file[64];
	extern int maxx,maxy,miny,minx,do_tex;
	float x,dx,dy;
	int i;
                              
                                         
plot_off();
	
	sprintf(file,"%s.tex",filename);
	fp=fopen(file,"w");

	dx=((float)(maxx-minx)/XSCALE);
	dy=((float)(maxy-miny)/YSCALE);

	x=(minx>(136*2.6))?( ((float)minx/136)-2.6):0 ;
	
/* define mdraw text macro */

/*	 don't hardcode font definitions 
*/
	if( (do_tex & TEX_TEXT) !=0 )	/* let TeX handle fonts */
	{
	for(i=0;i<FONTS;i++)
	fprintf(fp,"\\font\\%s=%s\n",font_names[i],font_defs[i]);

	fprintf(fp,"\\def\\mdrawtext#1 #2 #3 {\\vbox to0pt{\\kern#2in\\hbox{\\kern#1in{\\hfil #3\\hfil }}\\vss}\\nointerlineskip}\n");
	}

 	fprintf(fp,"\\vbox{\\hsize %.2f in ",.25+dx);

	if (  (do_tex & TEX_OUTLINE) )	/* draw outline on -o */
        fprintf(fp,"\\hrule height.5pt\n");

         fprintf(fp,"\\hbox{");

	if (  (do_tex & TEX_OUTLINE) )	/* draw outline on -o */
	fprintf(fp,"\\vrule width.5pt\n");

         fprintf(fp,"\\vbox{ ");
	 fprintf(fp,"\\vskip .25 in \n"); 

/* draw graphics, sending TeX text commands to tex file */
	process_file(-minx,-miny,in_file,fp);

	fprintf(fp,"\\vskip .07 in");                 
	fprintf(fp,"\\special{ln03:plotfile DISK_DGPWC:%s.pic}\n",filename);
	fprintf(fp,"\\vskip %.2f in\n",dy + .25 );
	fprintf(fp,"\\line{}");
	fprintf(fp,"} \n");
	 fprintf(fp,"\\hskip .25 in \n");  

	if (  (do_tex & TEX_OUTLINE) )	/* draw outline on -o */
	fprintf(fp,"\\vrule width.5pt");

	fprintf(fp,"} \n");

	if (  (do_tex & TEX_OUTLINE) )	/* draw outline on -o */
	fprintf(fp,"\\hrule height.5pt");

	fprintf(fp,"} \n");
	
	fclose(fp);

plot_off();
	
}                               

find_max(fp)
FILE 	*fp;
{
	extern int maxx,maxy,miny,minx;
  	int x,w,y,h,dummy,l_style;
	int braces;
	char sdum[80],style[80],dummy_line[120],command[120];


	maxx = 0;
	maxy = 0;
	minx = 800;
	miny = 480;

	braces = 0;
	fgets(dummy_line,80,fp);
	dummy=fgets(dummy_line,80,fp);

	while( dummy != NULL)
	{

	if(dummy_line[0] == '[') 
	{
	braces++;
	dummy=fgets(dummy_line,80,fp);
	sscanf(dummy_line,"%d%d%d%d",&x,&y,&w,&h);

	while(braces > 0)	/* while in sub object */
	{
	dummy=fgets(dummy_line,120,fp);
	 if (dummy_line[0] == '[') braces++;
	 if (dummy_line[0] == ']') braces--;
	}			/* end of sub object */

	} /* end of found sub */
	else
	{
	sscanf(dummy_line,"%d%d%d%d",&x,&y,&w,&h);
  	fgets(command,120,fp);	/* skip two blank lines */
	fgets(command,120,fp);
	}

  	fgets(command,120,fp);
	fgets(command,120,fp);
	dummy=fgets(dummy_line,80,fp);

	maxx= max(maxx,x+w,x);
	maxy= max(maxy,y+h,y);
	minx= min(minx,x+w,x);   
	miny= min(miny,y+h,y);  
	}                                             
	
}

reposition_file(fp)
FILE 	*fp;
{
	extern int maxx,maxy,miny,minx;
	int x,w,y,h,dummy;
	char command[120];

	plot_reset();
plot_on();


	while( (dummy=fscanf(fp,"%d%d%d%d",&x,&y,&w,&h) ) != EOF)
	{
	move_to(x-minx,y-miny);
	fgets(command,80,fp);
	fgets(command,120,fp);
	printf("%s",command);
	fgets(command,80,fp);
	}                                             
plot_off();
	
}

main(argc,argv)                                              
int argc;                                                    
char *argv[];          
{                           
	int i,dx,dy;
FILE	*fp;
	char fname[40],option[40],fnameext[10];
	char command_line[60],line[200];
	char *save_ext;

	save_ext = "mdr";
	dx = 100;
	dy = -50;
	sprintf(fnameext,".pic");
	sprintf(option," ");

	if (argc >1)
	{	i=1;
		if ((argv[1][0] == '-') || (argv[1][0] == '/'))		 
		{	i++;

			switch(argv[1][1])
			{
			  case 	'l'	:
			  case	'L' 	: sprintf(fnameext,".land");
					sprintf(option,"landscape");
			    	    break;
			  case 'T'	:
			  case 't' : 	do_tex = DO_TEX | TEX_TEXT;
			     		sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'X'	:
			  case 'x' : 	do_tex = DO_TEX;
					sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'O'	:
			  case 'o' : 	do_tex = DO_TEX | TEX_OUTLINE;
					sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'v'	:
			  case 'V' : 	do_tex = JUST_VIEW;
			    		sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  default  : 
					sprintf(fnameext,".pic");
					sprintf(option,"%s"," ");
					break;
			}
		} /* end of if */
		if (argc > 2)
		if ((argv[2][0] == '-') || (argv[2][0] == '/'))		 
		{	i++;
			switch(argv[2][1])
			{
			  case 	'l'	:
			  case	'L' 	: sprintf(fnameext,".land");
					sprintf(option,"landscape");
			    	    break;    
			  case 'T'	:
			  case 't' : 	do_tex |= DO_TEX | TEX_TEXT;
					sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'X'	:
			  case 'x' : 	do_tex |= DO_TEX;
					sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'O'	:
			  case 'o' : 	do_tex |= DO_TEX | TEX_OUTLINE;
			    		sprintf(option," ");
					sprintf(fnameext,".pic");
				    break;
			  case 'v'	:
			  case 'V' : 	do_tex |= JUST_VIEW;
			    		sprintf(option," ");
			       		sprintf(fnameext,".pic");
				    break;
			  default  : 
					sprintf(fnameext,".pic");
					sprintf(option,"%s"," ");
					break;
			}	/* end of switch */
		

		}	/* end of if */

	   	for(;i<argc;i++)
		{                
				if (NULL != strchr(argv[i],'.')  )
		 {
			save_ext=strchr(argv[i],'.');
			save_ext[0]='\0';
			save_ext++;
		 }  
		sprintf(fname,"%s.%s",argv[i],save_ext);

 		if ((fp=fopen(fname,"r")) != NULL)
		 {
		 find_max(fp);
		 lseek(fileno(fp),0L,0);
		 fgets(line,100,fp);	/* toss first line */

		plot_reset();
		if ((do_tex & DO_TEX)!=0) /* process file within tex file */
		 tex_file(argv[i],fp);

		else { 
			minx=0;miny=0;
			process_file(0,0,fp,NULL);	
		} /* end of if do tex */

		 fclose(fp);
		sprintf(fname,"%s%s",argv[i],fnameext);

		sprintf(command_line,"sixel %s %s",fname,option);
		if  ((do_tex & JUST_VIEW) == 0)
		 system(command_line);	
		 } /* end of opened file */
		else
		 printf("\n Error opening file %s",fname);
		}             /* end of for loop ? */

	
	}
	else 
	{	
	printf("\nformat: vregis [-l] [-x] [-t] [-o] [-v] fname...  ");
	printf("\n [-l] landscape output ");
	printf("\n [-x] TeX file output ");
	printf("\n [-t] TeX handles fonts ");
	printf("\n [-o] TeX with outline ");
	printf("\n [-v] Just view the file ");
	}

			
}           
        
                                                     
