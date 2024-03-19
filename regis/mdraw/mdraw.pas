 [INHERIT ('sys$library:starlet.pen')]                  
PROGRAM mdraw(input,output);
(*
 *	MDRAW - object oriented drawing for the masses.
 *	Written by S. Mike Dierken
 *	
 *)



(*
 * Used when drawing an open or closed spline (surprise)
 *)
const	
	open_spline	= true;
	closed_spline  = false;	

TYPE
(*
 * varying strings for input and output and for storing ascii ReGIS commands
 *)
	STRING 	= VARYING[200] OF CHAR;         
	str80 = varying[80] of char;
	str20 = varying[20] of char;

(*
 * Actually used in the help screen to hold lines of info
 *)
	menu_lines = packed array [1..10] of str20;

(****     graphics rectangle record ******)
(*
 * x,y coordinates of a corner (usually upper left) w,h width and height
 *)
		grect	= record
				x:integer;	
				y: integer;
				w: integer;
				h: integer;
			  end;
(*** object ***)
(*
 * linked list of objects with pointers to sub-tree of objects
 *)
	object = record
				bounds : grect;  (* bounding rectangle*)
				sub		: ^object; (*sub tree of objects*)
				l_style: integer;	 (* line style *)
				draw	: string;	  (* ReGis commands *)
				next 	: ^object;	  (* linked list ptr *)
				prev	: ^object;
				n_file : str80;		 (* next file to expand to*)
			 end;
	ptr	= ^object;

                                     



(***************   bit byte types for I/O stuff ********)
	$ubyte  = [byte] 0..255;
	$quad	= [quad,unsafe] record
		ts,term,len,l2:$ubyte; end;
	$UQUAD = [QUAD,UNSAFE] RECORD
		L0,L1:UNSIGNED; END;
	$UWORD = [WORD] 0..65535;

	hex_pair = varying [2] of char;
	char1 = varying [1] of char;
	char20  = packed array[1..20] of char;

	command_line = varying[64] of char;
(*
 * used for splines and stuff
 *)
	intarray = array [1..200] of integer;
var
(**************** object tree stuff ************)
(*
 * Current object
 *)
	part,
(*
 * delineates the linked list of objects
 *)
	head,tail,
(*
 * pointers to cut and pasted objects
 *)
	paste_part,cut_part,

(*
 * generic temp pointers
 *)
	temp,temp2 : ptr;

(*
 * name of file to zoom up to if necessary
 *)
	zoom_file :str80;
(*
 * name of current file
 *)
	loaded_file :str80;
(*
 * current file extension for saveing and loading files
 *)
	save_ext : str20;

(*********** io channel ********)
	channel	: $uword;

(******* status constants for I/O routines ***********)
	IOREADP,IOREADT,IOREADPT,IOWRITE,IOWRITEB,ioread  : unsigned;

	port	: str20;

(*************** stuff for draw buffer *******)
	rec_num : integer;
	record_on : boolean;
	record_buf : array [0..9] of string;

(********** generic strings and booleans *************)
	new_icon : str20;
	text_size : integer;	(* text size *)
	gtext : string;		(* actual text *)
	dummy_s :str20;
	dummy_b,done : boolean := false;
	do_again : boolean := false;	(* #3 button repeat command *)

(*************** you tell me ****************)
	term_spec : array [1..2] of integer := (0,-1);

(***********  characters returned by the terminal **********)
	txy	:string;
	key	: char := ' ';		(* key just hit *)
	last_key : char := ' ';		(* key last hit *)
	key2	: char := ' ';
	hex	 : packed array [1..10] of hex_pair;

(************  spline arrays ***************)
	x_array,y_array : intarray; 

(************ standard all purpose integers *********)
	ix,iy,ic,input_cursor: integer;                       
	again_item	: integer := -1;
	last_item	: integer := -1;
(*
 * maximum x in grect list, maximum y in grect list, minimums too
 *)
	maxx,may,mix,miy,
(*
 * temp x,y coords
 *)
	tx,ty,
(*
 * temp delta x,y vectors
 *)
	dx,dy,i,j : integer;
	trect :grect;

	control_hit,mouse_hit : boolean;
(*
 * Workspace parameters
 *)
	grid_on	:boolean := false;
	grid_size : integer;

	fill_on	:boolean := false;
	arrow_on : boolean := false;
	l_style : integer := 1; (* linestyle *)

(************** menu stuff ***********)
	icon : array [0..10] of char1;		(* on screen commands *)
	menu: ptr;				(* on screen menu object *)
	menu_array : array [0..10] of grect;	(* array of 'hot' rectangles *)
(*
 * whether we should draw menu or not on screen redraws
 *)
	temp_draw,menu_draw : boolean;
	menu_w :integer;

(************* save file for ReGIS/sixel data ****************)
	pic_file : TEXT;                               
	object_file : TEXT;
	
(************   spawn a command line ie   sixel screen capture command **)
[EXTERNAL(LIB$SPAWN)] Function Spawn_command_line
	(%DESCR command:command_line):boolean;external;

(* ++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(*  $QIO                                                                    *)
(*                                                                          *)
(*    Queue I/O Request                                                     *)
(*                                                                          *)
(*     $QIO     [efn] ,chan ,func ,[iosb] ,[astadr] ,[astprm]               *)
(*     ($QIOW)  ,[p1] ,[p2] ,[p3] ,[p4] ,[p5] ,[p6]                         *)
(*                                                                          *)
(*     efn    = number of event flag to set on completion                   *)
(*                                                                          *)
(*     chan   = number of channel on which I/O is directed                  *)
(*                                                                          *)
(*     func   = function code specifying action to be performed             *)
(*                                                                          *)
(*     iosb   = address of quadword I/O status block to receive final       *)
(*              completion status                                           *)
(*                                                                          *)
(*     astadr = address of entry mask of AST routine                        *)
(*                                                                          *)
(*     astprm = value to be passed to AST routine as argument               *)
(*                                                                          *)
(*     p1...  = optional device- and function-specific parameters           *)
(*                                                                  *)


(*  $WAITFR                                                                 *)
(*                                                                          *)
(*    Wait for Single Event Flag                                            *)
(*                                                                          *)
(*     $WAITFR  efn                                                         *)
(*                                                                          *)
(*     efn    = event flag number to wait for                               *)
(*                                                                          *)
                                                                          
(* [ASYNCHRONOUS,EXTERNAL(SYS$WAITFR)] FUNCTION $WAITFR (	*)
(*	%IMMED EFN : UNSIGNED) : INTEGER; EXTERNAL;		*)


function waitfr(evnt : integer):integer;
begin
	waitfr := $waitfr(evnt::unsigned);
end;

(*
 * output command to the ReGIS terminal
 *)
PROCEDURE SQUIRT(BUF :varying[len] of char);
VAR
  	IOSTAT1	:	$UQUAD;
	SYSSTAT	: DOUBLE;  
	EFLAG1	: UNSIGNED;
	count : integer;
	temp : string;
BEGIN
		
	
(*
 * put commands into a save buffer to eventually go into object record in
 * the linked list
 *)
	if (record_on) then begin
	record_buf[rec_num] := record_buf[rec_num] + buf;
	end;

	$QIOW(chan := CHANNEL,func := IOWRITEB::integer,
		iosb:= IOSTAT1,p1:= BUF.body,p2:= BUF.length);
                                           
end;                            

PROCEDURE qwrite(BUF : STRING;flag:unsigned);
VAR
	IOSTAT1	:	$UQUAD;
	SYSSTAT,LENGTH : DOUBLE;
	EFLAG1	: UNSIGNED;
BEGIN

	$QIO(efn := flag,chan:=CHANNEL,func:=IOWRITE::integer,
		iosb:=IOSTAT1,p1:= BUF.body,p2:= BUF.LENGTH);
                                           
                                           
end;                      

(*
 * Read in terminal response to command, usually from a cursor input command
 * this will return the key pressed and coords. Parsed in regis_gin
 *)
PROCEDURE SLURP(var bod: packed array [l..u:integer]of char;
		len:integer);
VAR
	IOSTAT1	:	$QUAD;             
BEGIN

    $QIOW(chan:= CHANNEL,func:=IOREAD::integer,
		iosb:=IOSTAT1,p1:= bod,p2:= LEN,p4:=%ref term_spec );
	
                                          
end;

PROCEDURE QREAD(var bod: packed array [l..u:integer] of char;
		len:integer;flag:unsigned);
VAR
	IOSTAT1	:	$QUAD;
BEGIN

    $QIOW(efn:= flag, chan:= CHANNEL,func:=IOREAD::integer,
		iosb:=IOSTAT1,p1:= bod,p2:= LEN,p4:=%ref term_spec );
                        
end;

(********* is (x,y) within the rectangle? *********)
         
function within(x,y:integer;bounds:grect):boolean;
var
	a,b : integer;
begin
(*
 * find distance away for x and y dimensions
 *)
	a := x-bounds.x;
	b := y-bounds.y;

	if (((bounds.w >=0) and(a<=bounds.w) and (a >= 0)) 
	    or ((bounds.w <=0) and( a>=bounds.w) and (a<=0) ) )
	and  (((bounds.h >=0) and(b<=bounds.h) and (b >= 0)) 
	    or ((bounds.h <=0) and( b>=bounds.h) and (b<=0) ) ) then
	 within := true
	else 
	 within := false;

end;


(******** return pointer, or nil, of first object under (x,y) *****)
function find(x,y:integer):ptr;
var
    	p : ptr;
	done : boolean;
begin
	done := false;
	p := head;

(*
 * If empty object tree then return nil
 *)
	if (p= nil) then done := true;

	while (not done ) do
	 begin
(*
 * if cursor pointing to this object return address of object record
 *)
		if(within(x,y,p^.bounds)) then
	 	 done := true
(*
 * if more objects left to search go for it
 *)
		else if (p <> tail) then
		 p := p^.next
(*
 * no objects left, return nil
 *)
		else
		 begin
			p := nil;
			done := true;
		 end;
	 end;
	                                                            
	find := p;

end;
(***********   find next object under current object which is under pointer *****)
(*
 * x,y : coord of cursor 	p: pointer to selected object (in the list)
 *)

function find_next(x,y:integer;p:ptr):ptr;
var
	temp : ptr;
	done : boolean;
begin
	done := false;         

	temp := p;
	if(temp = nil) then
		begin
		 done := true;
		 temp := nil;
		end;

	while (not done ) do
	 begin
		if(within(x,y,temp^.bounds)) then
		 done := true
		else if (temp <> tail) then
		 temp := temp^.next
		else
		 begin
			temp := nil; 	
    			done := true;
		 end;
	 end;                                
	find_next := temp;

end;

(******* find object above current object which is under cursor ***)
(*
 * x,y: coord of cursor		p: pointer to selected object (in list)
 *)
function find_prev(x,y:integer; p:ptr):ptr;
var
	temp : ptr;
	done : boolean;
begin                            

	done := false;

	temp := p;

	if (temp= nil) then 
	 begin
		done := true;          
		temp := nil;
	 end;
	while (not done ) do
	 begin
		if(within(x,y,temp^.bounds)) then
		 done := true
		else if (temp <> head) then                
		 temp := temp^.prev
		else
		 begin
			temp := nil;
    			done := true;
		 end;
	 end;
	           
	find_prev := temp;                                                

end;

(*********  remove from linked list **********)
(*
 * part: pointer to object to remove from object list pointed to by 'head'
 * 		and 'tail'
 *)

procedure cut(part:ptr);                         
var
	temp : ptr;
begin
	if (part <> nil) then			(* got something to cut *)
	if (part <> head) then			
	 if (part <> tail) then 		(* in the middle of list *)
	 begin
(*
 * Remove object from doubly linked list.    prev <=> part <=> next  is now
 *						prev <=> next
 *)
		part^.prev^.next := part^.next;
		part^.next^.prev := part^.prev;
		part^.prev := nil;
		part^.next := nil;

	 end
	else (* part = tail *)
	 begin
(*
 * move tail of doubly linked list up one object
 * part already points to correct object
 *)
		tail := tail^.prev;
		tail^.next := nil;
		part^.prev := nil;
		part^.next := nil;
	 end
	else (* part = head *)
	 begin
	if (head = tail) then
	 begin
	 	 head := nil;		(* list now is empty *)
		 tail := nil;
	 end
	else
	 begin				(* move head down one object *)
		 head := head^.next;
		 head^.prev := nil;
	 end;
(*
 * remove any links to list of workspace objects
 *)
	part^.prev := nil;
	part^.next := nil;
	 end;

end;


(*************   give new pointer and initialize it a bit ********)
procedure gimme(var part:ptr);

begin
	new(part);
	part^.next := nil;
	part^.sub := nil;
	part^.prev := nil;

	part^.draw := ' ';
	part^.l_style := l_style;
	part^.n_file := ' ';
end;


    (*********  duplicate object tree and sub trees *******)
procedure copy_tree(from,to_obj:ptr);
     var 
             prev,next,subs,temp:ptr;
     begin
(*
 * copy data for this object
 *)
             to_obj^.bounds := from^.bounds;
             to_obj^.draw := from^.draw;
	     to_obj^.l_style := from^.l_style;
	     to_obj^.n_file := from^.n_file;
(*
 * copy any sub tree that exists
 *)
             temp:= from^.sub;
             if(temp <> nil) then
              begin
                             gimme(subs);
                             to_obj^.sub:=subs;
                     next:=temp;
                     while(next<> nil) do
                      begin
                             copy_tree(next,subs);
                             next:= next^.next;
                             prev:= subs;
                             if(next <> nil) then
                              begin
                                     gimme(subs);
                                     prev^.next := subs;
                                     subs^.prev := prev;
                              end;
                      end;
                     
              end
             else to_obj^.sub := nil;
     end;
  
(************ insert in linked list before 'at' ********)
procedure insert(var part: ptr; at:ptr);
var
	new_part : ptr;
begin

                   gimme(new_part);	(* new space so no weird pointer stuff *)
                   copy_tree(part,new_part); (* can't have two objects with *)
						(* the same sub-tree pointers *)
		  dispose(part);
                   part := new_part;

	if (at <> head) then
	 begin
		at^.prev^.next := part; (* redirect front half of list *)
		part^.prev := at^.prev; (* point back to list *)
		part^.next := at;	(* point to next object *)
		at^.prev := part;	(* point back to inserted object *)
	 end
	else (* part becomes new head *)
	begin
	 part^.next := head;
	 if (head <> nil) then (* establish back pointer *)
	  head^.prev := part
	 else	(* empty list *)
	  tail := part;

	 head := part;
	end; (* part becomes new head *)



end;


(*
 * Move by absolute coordinates
 *)

procedure regis_move(ix,iy: integer);
var 
	outbuf : str20;
begin
 	writev(outbuf,'P[',ix:3,',',iy:3,']');		{   "P[x,y]"   }
	squirt(outbuf);

end;

(*
 * Change drawing style of lines
 *)
procedure set_linestyle(style : integer);
var
	temp : boolean;
	outbuf : str20;
begin
	temp := record_on;
	record_on := false;
	outbuf := 'W(P1)';
	outbuf[4] := chr(48+style);
	squirt(outbuf);
	record_on := temp;

(*	0: blank
	1: solid
	2: dash
	3: dash_dot
	4: close_dot
	5: dash_dot_dot
	6: dot
	7: wide_dot
	8: wide_dash_dot
	9: wide_dot_dash
*)
end;

(*
 * draw the object on the screen, and all sub-objects
 * move to grect origin, all drawing commands are deltas off this
 * 
 *)

procedure draw(x,y:integer; part : ptr);
var
        temp,tnext : ptr;
        outbuf : str20;
        dx,dy:integer;
begin   
        if (part <> nil) then 
	begin (* have a part *)
	        dx:=x+part^.bounds.x;
	        dy:=y+part^.bounds.y;
                record_on := false;
	        temp := part^.sub;
	        if(temp = nil) then
                begin (* real object here *)
	                regis_move(dx,dy);
			set_linestyle(part^.l_style);
	                squirt(part^.draw);
			set_linestyle(l_style);
                end (* real object here *)
 	        else 
		 begin (* sub-object *)
	                tnext := temp;
	                while (tnext <> nil) do 
	                  begin
	                        draw(dx,dy,tnext);
	                        tnext := tnext^.next;
	                  end; (* while *)
                end; (* sub-object *)
        end; (* have a part *)
end;

(*
 * Redraw in invisible ink
 *)

procedure undraw(x,y:integer; part : ptr);
var
	outbuf : str20;
begin
   	if (part <> nil) then begin
		record_on := false;
	    	writev(outbuf,'W(E)');
		squirt(outbuf);

                draw(x,y,part);
                writev(outbuf,'W(R)');
		squirt(outbuf);
	end;
end;
                     


procedure regis_dmove(ix,iy: integer);
var 
	outbuf : str20;
	signx,signy : char;
begin
	signx := '+';
	signy := '+';

	if (ix <0 ) then signx := '-';
	if (iy <0 ) then signy := '-';

 	writev(outbuf,'P[',signx,abs(ix):1,',',signy,abs(iy):1,']');
							{   "P[x,y]"   }
	squirt(outbuf);

end;
procedure regis_vector(dx,dy: integer);
var 
	signx,signy :char;
	sx,sy: str20;
	outbuf : string;
begin                                
	signx := '+';
	signy := '+';

	if (dx < 0) then 
	 signx := '-';

	if (dy < 0) then 
	 signy := '-';

	writev(sx,dx:3);
	writev(sy,dy:3);
	
 	writev(outbuf,'V[',signx,abs(dx):1,',',signy,abs(dy):1,']');		{   "V[x,y]"   }
	squirt(outbuf);
	
end;

procedure regis_draw(ix,iy: integer);
var 
	outbuf : string;
begin
 	writev(outbuf,'V[',ix:3,',',iy:3,']');		{   "V[x,y]"   }
	squirt(outbuf);
	
end;

procedure regis_line(x1,y1,x2,y2: integer);
var 
	outbuf : str20;
begin					{ "P[x,y]V[x,y]" }
 	writev(outbuf,'P[',x1:3,',',y1:3,']V[',x2:3,',',y2:3,']');  
	squirt(outbuf);			
	
end;

procedure regis_poly(ix,iy: intarray ; count : integer;open:boolean);
var
	i : integer;
	outbuf : str20;
	signx,signy :char;

begin                  
	                             
	if (not open) then	
	 outbuf := 'V(B)'
	else                                      
	 outbuf := 'V(S)';

	squirt(outbuf);

	for i := 1 to count do
	 begin
	signx := '+';
	signy := '+';
              
	if (ix[i] < 0) then 
	 signx := '-';

	if (iy[i] < 0) then 
	 signy := '-';

		writev(outbuf,'[',signx,abs(ix[i]):1,',',signy,abs(iy[i]):1,']');

{		outbuf := '['+dec(ix)+','+dec(iy)+']';		}
                           
		squirt(outbuf);


	 end; (* of for loop *)
	outbuf := '(E)';
	squirt(outbuf);

end;

procedure regis_spline(ix,iy: intarray ; count : integer;open:boolean);
var
	i : integer;
	x_array,y_array : intarray;
	sint,cost : real;
	dx,dy : integer;
	outbuf : string;
	signx,signy : char;

begin
	
	if (not open) then	
	 outbuf := 'C(B)'
	else
	 outbuf := 'C(S)';

	squirt(outbuf);

	for i := 1 to count do
	 begin

	signx := '+';
	signy := '+';

	if (ix[i] < 0) then 
	 signx := '-';  
                       
	if (iy[i] < 0) then 
	 signy := '-';
	writev(outbuf,'[',signx,abs(ix[i]):1,',',signy,abs(iy[i]):1,']');

		squirt(outbuf);

	 end; (* of for loop *)

	outbuf := '[](E)';
	squirt(outbuf);


	if( arrow_on )then 
	begin		(* arrow on *)

	dx := round(ix[count]-ix[count-1]/5 );
	dy := round(iy[count]-iy[count-1]/5 );

	if ((dx<>0)or(dy<>0)) then 
	begin 				(* non zero *)
	
	sint := dy/(sqrt(dx*dx+dy*dy));
	cost := dx/(sqrt(dx*dx+dy*dy));

	squirt('F(');   
	x_array[1] := round(-(16* cost)+(2.5*sint));
	y_array[1] := round(-(16* sint)-(2.5*cost));

	x_array[2] := round(-5 * sint );
	y_array[2] := round(5 * cost );

	regis_poly(x_array,y_array,2,closed_spline);
	squirt(')');	 
	end; 				(* of non zero deltas *)

	end; (* of arrow draw *)                      
	

end;      

procedure regis_vspline(ix,iy: intarray ; count : integer;open:boolean);
var
	i : integer;
	outbuf : str20;
	signx,signy : char;
begin
	
	if (not open) then	
	 outbuf := 'C(B)'
	else
	 outbuf := 'C(S)';

	squirt(outbuf);

	for i := 1 to count do
	 begin
		if (ix[i] > 0) then
		signx := '+'
		else
	       	signx := '-';
   		if (iy[i] > 0) then
		signy := '+'
		else       
		signy := '-';

	writev(outbuf,'[',signx,abs(ix[i]):1,',',signy,abs(iy[i]):1,']');

{		outbuf := '['+dec(ix)+','+dec(iy)+']';		}

		squirt(outbuf);


	 end; (* of for loop *)
	outbuf := '(E)';
	squirt(outbuf);

end;

PROCEDURE REGIS_CIRCLE(IX,IY: INTEGER);
VAR
	OUTBUF :	STR20;
                      
BEGIN
	
 	writev(outbuf,'C[',ix:3,',',iy:3,']');		{   "C[x,y]"   }
	squirt(outbuf);
		

END;
PROCEDURE REGIS_dCIRCLE(IX,IY: INTEGER);
VAR
	OUTBUF :	STR20;
        signx,signy : char;      
BEGIN
	
	signx := '+';
	signy := '+';

	if (ix < 0) then signx := '-';
	if (iy < 0) then signy := '-';
 	writev(outbuf,'C[',signx,abs(ix):1,',',signy,abs(iy):1,']');	
	squirt(outbuf);
		

END;

PROCEDURE REGIS_arc(IX,IY,angle: INTEGER);
VAR
	OUTBUF :	STR20;
                      
BEGIN
						{   "C(Adeg)[x,y]"   }

 	writev(outbuf,'C(A',angle:3,')[',ix:3,',',iy:3,']');	
	squirt(outbuf);
		

END;

PROCEDURE REGIS_darc(IX,IY,angle: INTEGER);
VAR
	OUTBUF :	STR20;
        signx,signy : str20;
BEGIN
	signx := '+';
	signy := '+';

	if (ix < 0) then signx := '-';
	if (iy < 0) then signy := '-';

						{   "C(Adeg)[x,y]"   }

 	writev(outbuf,'C(A',angle:1,')[',signx,abs(ix):1,
				 	',',signy,abs(iy):1,']');	
	squirt(outbuf);
		

END;



PROCEDURE REGIS_text(Text: varying[len] of char;
	text_size,intensity : integer);
VAR
	OUTBUF :	STR20;
                      
BEGIN                          


	outbuf := 'T(W(F2),S00)';
	outbuf[10] := chr(48+(text_size div 10));
	outbuf[11] := chr(48+(text_size mod 10));
	outbuf[6] := chr( 48+ intensity );
	squirt(outbuf);

	outbuf := '"';
	squirt(outbuf);

	squirt(text);

	outbuf := '"';
	squirt(outbuf);	


END;




procedure regis_on;
var
	outbuf : str20;
begin
	outbuf := chr(144) + 'p';
	squirt(outbuf);		{ enter ReGIS mode}

end;

procedure regis_off;
var
	buf : str20;
begin
	buf := chr(156);

	squirt(buf);		    	{ exit ReGIS mode}

end;


procedure regis_exit;     
var
	outbuf : str20;

begin
	regis_off;
	$dassgn(channel);
	channel := 0;

end;           

procedure set_output_cursor(cursor : integer);
var
	outbuf : str20;
begin                                        
        (*  1: diamond  *)  	
        (*    2: cross  *)  
        (*    0: off *)     

	outbuf := 'S(C(H1))';
        outbuf[6] := chr(48+cursor);         
        squirt(outbuf);                 

end;
               
procedure set_input_cursor(cursor : integer);
var	
	outbuf	: str20;
begin
	outbuf := 'S(C(I3))';
	outbuf[6] := chr(48+cursor);
	squirt(outbuf);
   
(*	1: diamond
	2: crosshair
	3: rb_line
	4: rb_box *)
end;              
procedure self_input_cursor;      
var	
	i :integer;
	outbuf	: string;
begin
	outbuf := 'L(A1)S(C(I[+0,+0]"XO"))';
	squirt(outbuf);
   
(*	1: diamond
	2: crosshair
	3: rb_line
	4: rb_box *)
end;              

procedure regis_init(signal_error,check_ranges:boolean;port_name:str20);
var
	inbuf	:	str20;
	outbuf	:	str20;
	sysstat : integer;

begin
  
{IOREAD := uor(uor(IO$_READLBLK,IO$M_NOECHO ),IO$M_NOFILTR); }
 ioread := uor(uor(IO$_READLBLK,IO$M_PURGE),IO$M_NOECHO);
 	
IOREADP  := uor(uor(uor(IO$_READPROMPT,IO$M_NOECHO),IO$M_NOFILTR),
				IO$M_NOFORMAT);

IOREADT   := uor(uor(uor(IO$_READLBLK,IO$M_NOECHO),IO$M_NOFILTR),IO$M_TIMED);

IOREADPT  := uor(uor(uor(uor(IO$_READPROMPT,IO$M_NOECHO),
	     	IO$M_NOFILTR),IO$M_NOFORMAT),IO$M_TIMED);

IOWRITE := uor(IO$_WRITELBLK,IO$M_NOFORMAT);
 
IOWRITEB := uor(uor(IO$_WRITELBLK,IO$M_BREAKTHRU),IO$M_NOFORMAT);
      

	port := 'TT';

	SYSSTAT := $ASSIGN('TT',CHANNEL,,);
	
		regis_on;                
		outbuf := 'S(C0)W(R)';	{ turn off output cursor, overlay mode}
		squirt(outbuf);	
		set_linestyle(1);	{ set line style}
					{ determine terminal type}
		regis_off;	
                          
	
end;

procedure regis_reset;
var
	outbuf : str20;

begin
	regis_on;

	outbuf := 'S(E)P[0,0]W(P1)';
	squirt(outbuf);

	regis_off;
	outbuf := '*1;1H';  (* erase screen ,home cursors *)
	outbuf[1] := chr(155);
	squirt(outbuf);
	regis_on;
	
	set_linestyle(l_style);		(* solid line *)
	

end;
procedure undraw_box(box : grect);
var                               
	outbuf : str20;
	temp : boolean;
begin
	temp := record_on;
	record_on := false;
	regis_move(box.x,box.y);
	record_on := temp;

	writev(outbuf,'W(E)');
		squirt(outbuf);
	x_array[1] := box.w;
	y_array[1] := 0;
	x_array[2] := 0;
	y_array[2] := box.h;
	x_array[3] := -box.w;
	y_array[3] := 0;
	regis_poly(x_array,y_array,3,closed_spline);

		writev(outbuf,'W(R)');
		squirt(outbuf);

end;

procedure draw_box(box : grect);
var
	temp : boolean;
begin
	temp := record_on; 
	record_on := false;
	regis_move(box.x,box.y);
	record_on := temp;

	x_array[1] := box.w;
	y_array[1] := 0;
	x_array[2] := 0;
	y_array[2] := box.h;
	x_array[3] := -box.w;
	y_array[3] := 0;
	regis_poly(x_array,y_array,3,closed_spline);

end;

procedure draw_box_filled(box : grect);
var
	outbuf : str20;
	temp : boolean;
begin
	temp := record_on;
	record_on := false;
	regis_move(box.x,box.y);
	record_on := temp;

	squirt('F(');
	x_array[1] := box.w;
	y_array[1] := 0;
	x_array[2] := 0;
	y_array[2] := box.h;
	x_array[3] := -box.w;
	y_array[3] := 0;
	regis_poly(x_array,y_array,3,closed_spline);
	squirt(')');
                   
end;           


procedure brighten( part: ptr);
var x :integer;
begin

	x := 3;
	if (length(part^.n_file) = 0) then x := 2;
	if( index(part^.draw,'T(W(F') <>0) then
		part^.draw[7] := chr(48+x);

end;

procedure light_menu(x:integer);
var ix,tx,y,iy : integer;
begin
if(x<10) and (x>-1) then  (* valid icon number *)
begin
	ix:= menu^.bounds.x+round((menu^.bounds.w-16)/2);
	y:= (menu^.bounds.h div 10);
	tx := round(( y -20 )/2);

	 draw_box_filled(menu_array[x]);
	iy:=menu^.bounds.y+ (x*y) + tx;
	 regis_move(ix,iy);            
	 regis_text(icon[x],2,2);
end;
end;        

procedure unlight_menu(x:integer);
var ix,tx,y,iy : integer;
begin

if(x<10) and (x>-1) then  (* valid icon number *)
begin
	ix:= menu^.bounds.x+round((menu^.bounds.w-16)/2);
	y:= (menu^.bounds.h div 10);
	tx := round(( y -20 )/2);

		squirt('W(E)');
	 draw_box_filled(menu_array[x]);
		squirt('W(R)');
	 draw_box(menu_array[x]);

	iy:=menu^.bounds.y+ (x*y) + tx;
	 regis_move(ix,iy);            
	 regis_text(icon[x],2,2);
end;
end;

procedure clear_plane(plane : integer);
var g1 : grect;
	outbuf :str20;
begin
	g1.x := 0;
	g1.y := 0;
	g1.w := 800;
	g1.h := 480;

	outbuf := 'W(F1)W(E)';
	outbuf[4] := chr(48+plane);
	squirt(outbuf);
        draw_box_filled(g1);
	squirt('W(F2)W(R)');

end;      

procedure draw_grid;
var ix,iy,i : integer;
	temp : integer;
begin
	squirt('W(F1)W(R)W(P1)');
	for i:= 0 to trunc(800/grid_size)  do 
	begin
	 temp := i*grid_size;
	 regis_line(temp,0,temp,480);
	 regis_line(0,temp,800,temp );

	end;

	squirt('W(F2)W(R)');

end;	(* of draw_grid *)

procedure draw_menu;
var x,ix,iy,y:integer;
 tx :integer;
begin
	draw_box(menu^.bounds);
                                        
	ix:= menu^.bounds.x+round((menu^.bounds.w-16)/2);
	y:= (menu^.bounds.h div 10);
	tx := round(( y -20 )/2);

	for x := 0 to 9 do begin
	 draw_box(menu_array[x]);
	iy:=menu^.bounds.y+ (x*y) + tx;
	 regis_move(ix,iy);            
	 regis_text(icon[x],2,2);
	end;    

	regis_move(ix-10,iy+y);
	if(grid_on) then regis_text('grid',1,2)
	 else 	regis_text('    ',1,2);

	regis_move(ix-10,iy+y+20);
	if(fill_on) then regis_text('fill',1,2)
	 else 	regis_text('    ',1,2);

end;      

procedure undraw_menu;
var
	outbuf :str20;
begin                              
	outbuf := 'W(E)';
    	squirt(outbuf);
	draw_menu;

	outbuf := 'W(R)';
    	squirt(outbuf);
end;

procedure re_draw;
var
	part :ptr;
	outbuf :str20;
begin

	part := head;
	clear_plane(2);
	regis_off;
	outbuf := '*1;1H';  (* erase screen ,home cursors *)
	outbuf[1] := chr(155);
	squirt(outbuf);
	regis_on;

	if (menu_draw) then 
	 draw_menu;

	while (part <> nil) do 
	 begin
		draw(0,0,part);
		part := part^.next;
	 end; (* while looping *)
end;


procedure regis_gin(var ix,iy:integer;var key:char; ic:integer);
var                                 
	outbuf : str20;
	dumbuf,inbuf	: str20;	
 	dummy,dummy2,d3,d4,d5	: char;
	start,stat,junk1,junk2	: integer;
	temp_record_on : boolean;
begin
	inbuf :='               ';	
	outbuf := 'S(C(I ))R(P(I))';
	outbuf[6] := chr(48+ic);

	control_hit := false;	
	mouse_hit := false;	
	temp_record_on := record_on;
	record_on := false;                                
       	squirt(outbuf);			(* queue a write & wait *)
	slurp(inbuf.body,inbuf.length);	(* queue a read & wait *)

	start := index(inbuf,'[');
	while (inbuf[start+1] = '[') do start:=start+1;

	while ( ord(inbuf[1]) =13) do 
	 begin 
	      	junk1 := 1;
		slurp(inbuf.body,junk1);
                    
	       	squirt(outbuf);		(* queue a write & wait *)
		slurp(inbuf.body,inbuf.length);
	 end;

	start := index(inbuf,'[');
	while (inbuf[start+1] = '[') do start:=start+1;

	 if (ord(inbuf[1]) =155) then   (* function keys & help *)
	  begin
		dumbuf:=substr(inbuf,start,length(inbuf)-start+1);
		readv(dumbuf,d4,ix,d5,iy);
		readv(inbuf,dummy,junk1);
		if (junk1 > 34) then
	       	begin
		key := chr(junk1);
		mouse_hit := true;
		 end
		else 
		begin
		 control_hit := true;
		 key := chr(junk1 + 96);
		end;
	 end
	else if ((inbuf[1])=chr(27) ) then (* escape *)
	  begin
		regis_off;
	      	writeln(' Hey! use 8-bit mode in the General Set Up');
		regis_on;
	 end
	 else
	begin
		dumbuf:=substr(inbuf,start,length(inbuf)-start+1);
	       	readv(dumbuf,d4,ix,d5,iy);
		readv(inbuf,key);

	end;

	if(grid_on) then 
	 begin
 if(not (menu_draw and within(ix,iy,menu^.bounds)) )then
	  begin
		ix := (ix+ (grid_size div 2)) -((ix+ (grid_size div 2)) mod grid_size);
		iy := (iy+ (grid_size div 2)) -((iy+ (grid_size div 2)) mod grid_size) ;

(*		ix := ix- (ix mod grid_size)+ (grid_size div 2);
		iy := iy- (iy mod grid_size) + (grid_size div 2);
*)	  end;
	 end;
	record_on := temp_record_on;
end;

procedure s_logo;
	
 begin
	x_array[1] := 0;
	y_array[1] := 0;
                               
	x_array[2] := 10;
	y_array[2] := -10;

	x_array[3] := 0;
	y_array[3] := -20;
	
	x_array[4] := -10;
	y_array[4] := -40;
	
	x_array[5] := 30;
	y_array[5] := -10;

	x_array[6] := 20;
	y_array[6] := -30;
                                             
	regis_vspline(x_array,y_array,6,open_spline);
            
end;
procedure h_and(x,y,dx,dy:integer);
begin

				REGIS_vector(DX,0);
				REGIS_dMOVE(0,round(DY/2 ));
				REGIS_dARC(0,round(dY/2), 180);
				REGIS_dMOVE(0,round(DY/2));
				REGIS_vector(-dX, 0);
				REGIS_vector(0, -dY);

end;
procedure v_and(ix,iy,dx,dy:integer);
begin
            REGIS_vector(0,-DX);
            REGIS_dMOVE(round(DY/2),0);
	            REGIS_dARC(round(dy/2),0,180);
            REGIS_dMOVE(round(Dy/2),0);
            REGIS_vector(0, dx);
            REGIS_vector(-dy,0);
           
end;
procedure h_or(x,y,dx,dy:integer);
begin

		regis_vector(trunc(dx/2),0);
		regis_darc(0,dy,60);

	        REGIS_dMOVE(-dx,trunc(DY/2));
		REGIS_dARC(trunc(dx/2),trunc(dY/2), 105);
		REGIS_dMOVE(trunc(dx/2),trunc(DY/2));

		regis_vector(trunc(dx/2),0);
		regis_darc(0,-dy,-60);


end;
procedure v_or(ix,iy,dx,dy:integer);
begin
		
		regis_vector(0,-trunc(dx/2));
		regis_darc(dy,0,60);

            REGIS_dMOVE(trunc(DY/2),dx);
	    REGIS_dARC(trunc(dy/2),-trunc(dx/2),105);
            REGIS_dMOVE(trunc(Dy/2),-trunc(dx/2));

		regis_vector(0,-trunc(dx/2));
		regis_darc(-dy,0,-60);

           
end;

procedure all_delete;
begin
	while (tail <> nil) do
	begin
	 temp := tail^.prev;
	dispose(tail);
	 tail := temp;
 	end;
	head := nil;
end;
procedure move_sub(part:ptr;dx,dy:integer); (* move all objects in tree *)
    var
            temp : ptr;
            done : boolean;
    begin
            temp := part^.sub;
    
            while(temp <> nil) do begin
                    temp^.bounds.x:= temp^.bounds.x-dx;
                    temp^.bounds.y:= temp^.bounds.y-dy;
                    temp := temp^.next;
            end; (* while next *)
    
    end;

procedure sub_insert(part,at:ptr);
var 
	new_part,temp : ptr;
begin       
            temp := at^.sub;

            if(temp = nil) then
             begin
                    at^.sub := part;
             end
            else
             begin (* objects present *)
			part^.next := temp;
			temp^.prev := part;
			at^.sub := part;
             end; (* objects present *)             
	
end;            
function rsect(r1,r2:grect):boolean;
var
	x1,y1,x2,y2 :integer;
	temp :boolean;
begin

	x1 := r1.x;
	y1 := r1.y;
	temp := true;

	if (not within(x1,y1,r2) ) then
	begin
		x1 := r1.x+r1.w;
		if (not within(x1,y1,r2) ) then
		begin
			y1 := r1.y+r1.h;
			if (not within(x1,y1,r2) ) then
			begin
				x1 := r1.x;
				if (not within(x1,y1,r2) ) then
				begin
				 temp := false;			
				end;
			end;
		end;
	end;

	rsect := temp;
end;

function find_under(under:grect; except,at:ptr):ptr;
var 
	temp : ptr;
	done : boolean;
begin
	done := false;
	temp := at;
                
	while ((not done) and (temp <> nil)) do
	begin
		if (temp <> except) then	(* if not the top object *)
		begin
		 if (rsect(temp^.bounds,under) ) then  (* inside bound *)
			done := true
		 else 
			 if (rsect(under,temp^.bounds) ) then (* encompasses it*)
				done := true
	 		 else 
				temp := temp^.next;
		end
		else
		 temp := temp^.next;

	end; (* looking *)

	find_under := temp;
end; (* of find_under *)

procedure un_join(part:ptr);
var 
	x,y: integer;
	front,back,temp :ptr;
begin
	x:= part^.bounds.x;
	y := part^.bounds.y;

	move_sub(part,-x,-y);
	temp := part^.sub;
	if (temp <> nil) then
	begin
	 temp^.prev := part^.prev;
	 if (temp^.prev = nil) then	(* new head *)
	 begin
		head := temp;
	 end (* new head *)
	 else
		part^.prev^.next := temp;

	while (temp^.next <> nil) do
	 temp := temp^.next;

	temp^.next := part^.next;
	if (temp^.next = nil) then
	 begin
		tail := temp;
	 end
	else
		part^.next^.prev := temp;

	dispose(part);
	end; (* of temp <> nil *)
	

end;

function join(under:grect):ptr;
var
	top_object,temp,temp2 : ptr;
	tw,th,tx,ty : integer;
	mx,my : integer;
begin
	top_object := nil;
	temp2 := nil;

	temp := find_under(under,nil,head);
	if (temp <> nil) then
	temp2 := find_under(under,temp,temp^.next);

	if ((temp <> nil) and (temp2 <> nil)) then
	 begin
		(* make new top object as big as the one we found *)
	  gimme(top_object);
	  insert(top_object,head);

	  top_object^.bounds := temp^.bounds;

		(* if we have an object *)
         
	  while (temp <> nil) do
	  begin		(* put found object under top object *)
	      	temp2:= temp^.next;		
		cut(temp);
		
		tx := min(temp^.bounds.x,temp^.bounds.x+temp^.bounds.w);
		ty := min(temp^.bounds.y,temp^.bounds.y+temp^.bounds.h);
		tw := abs(temp^.bounds.w);
		th := abs(temp^.bounds.h);

		mx := max(tx+tw,top_object^.bounds.x +top_object^.bounds.w );
		my := max(ty+th,top_object^.bounds.y +top_object^.bounds.h  );

	  	top_object^.bounds.x := min(top_object^.bounds.x,tx);
	  	top_object^.bounds.y := min(top_object^.bounds.y,ty);
		top_object^.bounds.w := (mx-top_object^.bounds.x);
		top_object^.bounds.h := (my-top_object^.bounds.y);

		sub_insert(temp,top_object);

		temp := find_under(under,top_object,temp2);	(* find more objects *)

	  end;	(* of looking for more under here *)
	move_sub(top_object,top_object^.bounds.x,top_object^.bounds.y);
	join := top_object;

	 end (* nothing under here *)
	else join := nil;

end;


    
procedure read_sub( at_ptr:ptr);
var     done :boolean;
            line :string;
            temp,part : ptr;
begin
            done := false;
    
    while (not done) do
     begin
		readln(object_file,line);
    
    if (line <> '') then 
    begin
            gimme(part);
            if(line[1]='[') then 
             begin (* start group *)
                    readln(object_file,line);
                    readv(line,part^.bounds.x,part^.bounds.y,
                            part^.bounds.w,part^.bounds.h);
                    read_sub(part);
                    readln(object_file,line);

             end (* of start group *)

            else if(line[1]=']') then 
		  begin
                    done:= true;
(*                    readln(object_file,line); *)
		  end

               else
                begin (* object on line *)
		 readv(line,part^.bounds.x,part^.bounds.y,part^.bounds.w,part^.bounds.h);
		 readln(object_file,part^.draw);
		 readln(object_file,line);
		 if(index(line,'style')>0)  then
	     	  begin
			 line := substr(line,8,line.length-7);
			 readv(line,part^.l_style);
	  		 readln(object_file,part^.n_file);

		   end;
                end; (* object on line *)

    end   (* of if not blank line *)
    else (* blank line *)
             begin
		sub_insert(part,at_ptr);
             end;    (* end blank line *)
    
    
    end; (*  do while *)
    
                 
    end;

procedure get_file(load_file : string;load_choice : char);
var
	x,y,w,h : integer;
	line,draw : string;         
	dummy : str20;
	at_ptr,part	: ptr;
	sub_found,done : boolean;                       
begin   
	done := false;
	sub_found := false;
	open(object_file,load_file,HISTORY := OLD,ERROR := CONTINUE);
	if (status(object_file) >0 ) then
	begin
		regis_off;
		writeln('File ',load_file:10,' not found!');
		regis_on;
	end

	else (* file found *)
	begin

	if(load_choice = 'l') then all_delete;
	reset(object_file);
                           
                      
	at_ptr := head;
	gimme(part);       

        readln(object_file,zoom_file);
        readln(object_file,line);
	  
	while (not EOF(object_file) ) do
	begin

	if (line <> '') then 
	begin
           if(line[1]='[') then 
            begin (* start group *)
                   readln(object_file,line);
                   readv(line,part^.bounds.x,part^.bounds.y,part^.bounds.w,part^.bounds.h);
                   read_sub(part);
                    readln(object_file,line);
		   sub_found := true;
   
            end (* of start group *)
           else 
		if(line[1] = ']') then 
                   begin (* end group *)
                   readln(object_file,line);
                   end (* of end group *)

           else (* normal object *)
		begin
		 readv(line,part^.bounds.x,part^.bounds.y,part^.bounds.w,part^.bounds.h);
		 readln(object_file,part^.draw);
		 readln(object_file,line);
		 if(index(line,'style')>0)  then
	     	  begin
		       	 line := substr(line,8,line.length-7);
			 readv(line,part^.l_style);
			 readln(object_file,part^.n_file);
			readln(object_file,line);
	 	  end;
		end;
	end
	else (* blank line *)
		begin
		if (not sub_found) then
		begin
		 insert(part,head);
		 gimme(part);
		end
		else sub_found := false;

		 readln(object_file,line);
		end;

	end; (*  do while *)

	 insert(part,head);

	close(object_file);
	loaded_file := load_file;

	end; (* of file found *)

end;

procedure load(auto : boolean; load_choice : char);
var	
	x,y,w,h : integer;
	line,draw : string;         
	path,load_file : string;
	dummy : str20;
	at_ptr,part,temp	: ptr;
	done : boolean;
begin
	path := '';
	at_ptr := head;
	done := false;
	regis_off;
	if(not auto) then 
	 begin (* of autoload *)       
	
	write('Load file:');
	readln(load_file);
                                           
	while (index(load_file,'*')>0)  or (index(load_file,'?')>0)  do 
	begin
		x := index(load_file,']');
		if (x <> 0) then 
		begin		(* getting path and name *)
	 	path:=substr(load_file,1,x);
	      	 load_file:=substr(load_file,x+1,length(load_file)-x);

		end;
		            
		x := index(load_file,'.');
	     	if (x <> 0) then                  
		 save_ext:=substr(load_file,x,length(load_file)-x+1);
                           
		dummy_b := spawn_command_line('dir '+path+'*'+save_ext);
		write('name of load file?');
		readln(load_file);
				            
	 end; (* end while *)

		x := index(load_file,']');
		if (x <> 0) then 
		begin		(* getting path and name *)
	 	path:=substr(load_file,1,x);
		 load_file:=substr(load_file,x+1,length(load_file)-x);

		end;

	x := index(load_file,'.');
	if (x <> 0) then                                            
	 save_ext:=substr(load_file,x,length(load_file)-x+1)
	else
	 load_file := path+load_file+save_ext;
	
	end  	(* of autoload *)
	else load_file:='mdraw:mdraw'+save_ext;
        
	if(load_file <> save_ext) then  (* didnt hit return *)
	begin       
		get_file(load_file,load_choice);
	end; (* hit return just exit *)
	regis_on;
end;

procedure sub_save(obj:ptr);
var part:ptr;
begin
        part:=obj^.sub;
	while(part^.next <> nil) do part := part^.next;

        repeat                                                  
         begin (* repeating *)
                if(part^.sub <> nil) then
                 begin  (* sub tree *)
	                writeln(object_file,'[');
	                writeln(object_file,part^.bounds.x:5,part^.bounds.y:5,
                                part^.bounds.w:5,part^.bounds.h:5);
 	                sub_save(part);
	                writeln(object_file,']');
	                writeln(object_file);
	                writeln(object_file);
                 end (* of sub-subtree *)
                else
                 begin (* normal object *)
	 	      writeln(object_file,part^.bounds.x:5,part^.bounds.y:5,
                                part^.bounds.w:5,part^.bounds.h:5);
		  	writeln(object_file,part^.draw);
			writeln(object_file,' style= ',part^.l_style:3);
			writeln(object_file,part^.n_file);

	  	       writeln(object_file);
                 end;
	        part := part^.prev;
         end; (* repeating *)
        until (part= nil);

end;

procedure save;
var
	x : integer;
	path,save_file : string;
	part : ptr;
	dummy : boolean;
begin
	regis_off;
	path:= '';
	write('Save to: [',loaded_file,']');
	readln(save_file);                             
	if(length(save_file) = 0) then save_file := loaded_file;

	while(index(save_file,'*')>0 ) or (index(save_file,'?')>0)   do
	 begin
(*
 * Find the path 
 *)      

		x := index(save_file,']');
		if (x <> 0) then 
		begin		(* getting path and name *)
	 	path:=substr(save_file,1,x);
		 save_file:=substr(save_file,x+1,length(save_file)-x);

		end;

		x := index(save_file,'.');   
		if (x <> 0) then 
		 save_ext:=substr(save_file,x,length(save_file)-x+1);
	                        
		dummy:=spawn_command_line('dir '+path+'*'+save_ext);
		write('name of file? ');
		readln(save_file);

	 end; (* end while *)

(*
 * Find the path 
 *)

		x := index(save_file,']');
		if (x <> 0) then 
		begin		(* getting path and name *)
	 	path:=substr(save_file,1,x);
		 save_file:=substr(save_file,x+1,length(save_file)-x);

		end;
(*
 * Check for new file extender
 *)
	x := index(save_file,'.');
	if (x <> 0) then 
	 save_ext:=substr(save_file,x,length(save_file)-x+1)
	else
	 save_file := path + save_file + save_ext;

	if(save_file <> save_ext) then
	begin
	open(object_file,save_file,HISTORY := NEW);
	rewrite(object_file);

	writeln(object_file,zoom_file);                                      
	part := tail;
	while(part <> nil) do
	begin
          if(part^.sub <> nil) then 
           begin (* sub tree *)
                  writeln(object_file,'[');
                   writeln(object_file,part^.bounds.x:5,part^.bounds.y:5,
                                  part^.bounds.w:5,part^.bounds.h:5);
                    sub_save(part);
                  writeln(object_file,']');
                  writeln(object_file);
                  writeln(object_file);
           end   (* sub tree *)
          else
           begin (* normal object *)
	 writeln(object_file,part^.bounds.x:5,part^.bounds.y:5,
				part^.bounds.w:5,part^.bounds.h:5);
	 writeln(object_file,part^.draw);
	 writeln(object_file,' style= ',part^.l_style:2);
	 writeln(object_file,part^.n_file);
	 writeln(object_file);
	end; (* normal object *)
	 part := part^.prev;

	end;
	close(object_file);
	loaded_file := save_file;

	end; (* hit return just exit *)
	regis_on;
end;

procedure move_all(dx,dy : integer);
var
	p : ptr;                        
begin
	p := head;
	while (p <> nil) do
	begin
		p^.bounds.x := p^.bounds.x + dx;
		p^.bounds.y := p^.bounds.y + dy;
		p := p^.next;
	end;

end;
procedure columns(ix,iy: integer;line : menu_lines; times,size:integer); 
var
	i : integer;
begin
	regis_move(ix*9*size,iy*15*size);
    	for i:=1 to times do
	begin
	regis_move(ix*9*size,15*size*(iy+(i-1)));
	 regis_text(line[i],size,2);
	end;

end;



procedure help_menu;
var
	cs,ch,co,cw,ts :integer;
 	menu_line : menu_lines;
begin
	ts := 2;		(* text size *)
	co := 1;     (* col offset *)
	cw := 21;   (* col width *)
	ch := 4;    (* lines per column *)
	cs := 2; (* spacing within column *)

	menu_line[1] := 'Any key exits...';
	columns(1,0,menu_line,1,ts);

	menu_line[1] := 'To Select Object ';
	menu_line[2] := ']: under current';
	menu_line[3] := '[: above current';
	columns(co,cs,menu_line,3,ts);

	menu_line[1] := 'c: cut';     
	menu_line[2] := 'p: paste';
	menu_line[3] := 'm: move';
	columns(co + cw,cs,menu_line,3,ts);

	menu_line[1] := 'S: Save';
	menu_line[2] := 'L: Load  (* = dir)'; 
	menu_line[3] := 'M: Merge';
	columns(co,ch+cs,menu_line,3,ts);

	menu_line[1] := '0: circle';
	menu_line[2] := '1: line';
	menu_line[3] := '4: box';
	menu_line[4] := 's: spline (4 points)';
 	columns(co + cw,ch+cs,menu_line,4,ts);

	menu_line[1] := 'r: redraw';     
	menu_line[2] := 'g: Grid on/off';
	menu_line[3] := 'F: Fill on/off';
 	menu_line[4] := 'Q: Quit';
 	columns(co ,ch*2+cs,menu_line,4,ts);

	menu_line[1] := 'T: Text size';
	menu_line[2] := 'G: Grid Size';
	menu_line[3] := 'X: delete all';
	menu_line[4] := '_: line style';
 	columns(co + cw,ch*2+cs+1,menu_line,4,ts);
end;

function menu_chosen(ix,iy:integer):integer;
begin
	menu_chosen :=((iy-menu^.bounds.y)div(menu^.bounds.h div 10)) ;
end;

procedure let_go(var part:ptr);
begin
	  if(part <> nil) then
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 part:= nil;
		end;
end;

{main	- mdraw		written by S. Mike Dierken}

begin                               
	save_ext := '.mdr';
	control_hit := false;
	control_hit := false;

	icon[0] := '0';
	icon[1] := '1';
	icon[2] := '4';
	icon[3] := 's';
        icon[4] := 't';
        icon[5] := 'c';         
        icon[6] := 'p';  
        icon[7] := 'd';  
        icon[8] := 'j';  
        icon[9] := 'Q'; 	

	gimme(menu);
	menu^.l_style := 1;
 	menu^.bounds.x:=730;
 	menu^.bounds.y:=20;
 	menu^.bounds.w:=60;
 	menu^.bounds.h:=400;

	for i:= 0 to 9 do begin
	 menu_array[i].x:=menu^.bounds.x;
	 menu_array[i].w:=menu^.bounds.w;
	 menu_array[i].h:= (menu^.bounds.h div 10);
	 menu_array[i].y:=menu^.bounds.y+(i*menu_array[i].h);
	end;

	part := nil;
	cut_part := nil;
	paste_part := nil;
 	head := nil;
	tail := head;
	text_size := 1;
	rec_num := 0;                              
 	record_on := false;
	zoom_file := ' ';
	loaded_file := ' ';
                       
(*********************************************)
 	regis_init(false,false,'TT:');
	regis_on;
	regis_reset;

	input_cursor:=2;
	grid_on := false;
	grid_size := 10;
	done := false;
 	key := ' ';

(*******	put up title screen 	v1.0 ****)
	load(true,'m');
	loaded_file := ' ';
	re_draw;
 
	regis_text(' V1.0',1,2);
 	all_delete;
	regis_move(0,0);

(** wait for button *)
	regis_gin(ix,iy,key,input_cursor);

	regis_reset;
 
(****	main loop here ***)

 	while (not done) do
	 begin
	if( menu_draw) then
	begin
	unlight_menu(last_item);	(* done with command, so unlight menu *)
	end;
	regis_move(ix,iy);		(* move to where user expects cursor *)

if (do_again) then			(* repeat last menu command *)
begin
	key := last_key;
	do_again := false;

	if(menu_draw) then	light_menu(again_item);
	last_item:= again_item;
end
else
begin  (*** not do-again  ***)
 regis_gin(ix,iy,key,input_cursor); (* get input from cursor *)

(****** menu item chosen *****)
 if(mouse_hit and menu_draw and within(ix,iy,menu^.bounds))then
	begin
	 last_item := menu_chosen(ix,iy);
	 again_item := last_item;
	 light_menu(last_item);
 	 key:= icon[last_item][1];
	 regis_move(ix,iy);

	 case key of 
	  'd','j','0','1','4','t','s','8','7','p' :	begin
						temp_draw := menu_draw;
						menu_draw := false;
						regis_gin(ix,iy,key2,input_cursor); (* get input from cursor *)
						menu_draw := temp_draw;
						end;
	 end; (* case *)

	if (key = 'Q') then 
		begin
		 regis_off;
		 write('Really Quit?');
		 readln(key2);
		 if (key2<>'y') and (key2 <>'Y') then key:=' ';
		 regis_on;
		end;
	last_key := key;
	end (* of menu hit *)

	else last_item := -1;	(* menu not hit, don't unlight it *)

end; (* of not do-again *)

	if(not control_hit) then
	case key of      
		'0'	: begin		(**** circle ****)
				let_go(part);
	     			record_on := false;
				regis_move(ix,iy);

				temp_draw := menu_draw;
				menu_draw := false;
				regis_gin(dx,dy,key,3);	(** get radius point *)
				menu_draw := temp_draw;

				gimme(part);		(** new object **)
				tx := dx - ix;
				ty := dy - iy;
				ic := round(sqrt( (tx*tx) + (ty*ty) )); (* radius *)

				part^.l_style := l_style; (** set attributes **)
				part^.bounds.x := ix-ic;
				part^.bounds.w := ic+ic;
				part^.bounds.y := iy-ic;
				part^.bounds.h := ic+ic;
                                
	if(ic > ix) then 		(** deal with hitting edge of screen **)
	begin
		part^.bounds.x := ix+ic;
		part^.bounds.w := -(ic+ic);
	end;
	if(ic > iy) then 
	begin
		part^.bounds.y := iy+ic;
		part^.bounds.h := -(ic+ic);
	end;
	
				regis_move(part^.bounds.x,part^.bounds.y);

				record_buf[rec_num] := ' ';

				record_on := true;

				if (fill_on) then squirt('F(');
				regis_dmove(round(part^.bounds.w/2),round(part^.bounds.h/2));
				regis_dcircle(dx-ix,dy-iy);
				if (fill_on) then squirt(')');
                
				record_on := false;

		    		part^.draw := record_buf[rec_num];
				insert(part,head);  
				rec_num := (rec_num+1)mod 10;
				
		set_linestyle(4);		(** outline as selected **)
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;

		'1'	: begin		(**** line ****)
				let_go(part);

				regis_move(ix,iy);
				temp_draw := menu_draw;
				menu_draw := false;
 				regis_gin(dx,dy,key,3);
				menu_draw := temp_draw;
				
				record_buf[rec_num] := ' ';
				gimme(part);

				part^.l_style := l_style;
				part^.bounds.x := ix;
				part^.bounds.y := iy;
				part^.bounds.w := (dx-ix);
				part^.bounds.h := (dy-iy);

				regis_move(part^.bounds.x,part^.bounds.y);
				record_on := true;
				regis_vector(part^.bounds.w,part^.bounds.h); 
		part^.draw := record_buf[rec_num];

		insert(part,head);

				record_on := false;
				rec_num := (rec_num+1)mod 10;
		set_linestyle(4);
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;  
		'4','÷'	: begin		(**** box ****)
				let_go(part);
				regis_move(ix,iy);
				temp_draw := menu_draw;
				menu_draw := false;
				regis_gin(dx,dy,key,4);                  
				menu_draw := temp_draw;
				gimme(part);

		part^.l_style := l_style;
		part^.bounds.x := ix;                           
		part^.bounds.y := iy;
		part^.bounds.w := (dx-ix);
		part^.bounds.h := (dy-iy);


			    record_buf[rec_num] := ' ';
				record_on := true;     
				if (fill_on) then draw_box_filled(part^.bounds)
				else draw_box(part^.bounds);
				record_on := false;

				part^.draw := record_buf[rec_num];
				insert(part,head);

				rec_num := (rec_num+1)mod 10;

		set_linestyle(4);
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;

		'7'	: begin		(**** and gate ****)

			let_go(part);
			gimme(part);
			
				temp_draw := menu_draw;
				menu_draw := false;
			regis_move(ix,iy);
			regis_gin(dx,dy,key,input_cursor);
				menu_draw := temp_draw;
				part^.l_style := l_style;
		part^.bounds.x := ix;
		part^.bounds.y := iy;
			
			regis_move(part^.bounds.x,part^.bounds.y);

				record_buf[rec_num] := ' ';
				record_on := true;

			dx := 30;
			dy := 40;
			if(key = '4' ) or(key = '2') then
			 begin
				dx := -dx;
				dy := -dy;
			 end;
			if (key = '4' ) or(key = '6') then
				begin
				h_and(ix,iy,dx,dy);
				part^.bounds.w := round(dx+dy/2);
				part^.bounds.h := dy;
				end;
			if (key = '2') or(key = '8') then
				begin
				part^.bounds.w := dy;
				part^.bounds.h := -round(dx+dy/2);
				v_and(ix,iy,dx,dy);
         			end;                          

				record_on := false;
				insert(part,head);
				part^.draw := record_buf[rec_num];
				rec_num := (rec_num+1)mod 10;
		set_linestyle(4);
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;
		'8'	: begin		(**** or gate ****)
			let_go(part);
			gimme(part);
			
				temp_draw := menu_draw;
				menu_draw := false;
			regis_move(ix,iy);
			regis_gin(dx,dy,key,input_cursor);
				menu_draw := temp_draw;
				part^.l_style := l_style;
		part^.bounds.x := ix;
		part^.bounds.y := iy;
			
			regis_move(part^.bounds.x,part^.bounds.y);

				record_buf[rec_num] := ' ';
				record_on := true;
                  
			dx := 30;
			dy := 40;
			if(key = '4' ) or(key = '2') then
			 begin
				dx := -dx;
				dy := -dy;
			 end;
			if (key = '4' ) or(key = '6') then
				begin
				h_or(ix,iy,dx,dy);
				part^.bounds.w := round(dx+dy/2);
				part^.bounds.h := dy;
				end;
			if (key = '2') or(key = '8') then
				begin
				part^.bounds.w := dy;
				part^.bounds.h := -round(dx+dy/2);
				v_or(ix,iy,dx,dy);
         			end;                          

				record_on := false;
				insert(part,head);
				part^.draw := record_buf[rec_num];
				rec_num := (rec_num+1)mod 10;
		set_linestyle(4);
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;

		'c'	: begin			(**** cut object ****)
				if (part <> nil) then 
				begin
				 cut(part);
				 undraw(0,0,part);
				 undraw_box(part^.bounds);
				 paste_part :=part;
				part := nil;
				end;
			  end;

		'p'	: begin			(**** paste object ****)
				if (paste_part <> nil )then 
				begin
					gimme(temp);
					copy_tree(paste_part,temp);
					temp^.bounds.x := ix;
					temp^.bounds.y := iy;
					draw(0,0,temp);
				   	insert(temp,head);
					ix:= temp^.bounds.x;
					iy:= temp^.bounds.y;
				end;
			 end;
		'd'	: begin			(**** duplicate object ****)
				if (part <> nil) then 
				begin
                   gimme(paste_part);	(* new space so no weird pointer stuff *)
                   copy_tree(part,paste_part); (* can't have two objects with *)

					gimme(temp);
					copy_tree(paste_part,temp);
					temp^.bounds.x := ix;
					temp^.bounds.y := iy;
					draw(0,0,temp);
				   	insert(temp,head);
					ix:= temp^.bounds.x;
					iy:= temp^.bounds.y;
			 end;
			 end; (* of clone *)
		'f','ó'	: begin   (*  button #2 down *)

		 regis_move(ix,iy);
		if(part <> nil) then
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 temp := part;
		 part := find_next(ix,iy,part^.next);
		 if (part = nil) then part:=find_next(ix,iy,head);
		  if (part = temp) then part := nil;
		end

		else part := find_next(ix,iy,head);

		if (part <> nil) then 
	    begin 		(* if something there *)
				set_linestyle(4); (* redraw as dotted *)
				draw_box(part^.bounds);
				set_linestyle(l_style);
		end; (* of something there *)
		end;
                
		'[' 	: begin (* find previous *)
		if(part <> nil) then
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 part := find_prev(ix,iy,part^.prev);
			regis_move(ix,iy);
		end
		else part := find_prev(ix,iy,tail);

		if (part <> nil) then
		begin
		 set_linestyle(4);
		 draw_box(part^.bounds);
		 set_linestyle(l_style);
		end;
	end;
		']' 	: begin (* find next *)
		if(part <> nil) then               
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 part := find_next(ix,iy,part^.next);
			regis_move(ix,iy);
		end
		else part := find_next(ix,iy,head);

		if (part <> nil) then
		begin
		 set_linestyle(4);
		 draw_box(part^.bounds);
		 set_linestyle(l_style);
		end;
		end;
                
		'm','ñ'		: begin (* button #1 up or down *)
				if (part <> nil )then 
				begin
					undraw_box(part^.bounds);
					undraw(0,0,part);
					part^.bounds.x := ix;
					part^.bounds.y := iy;
					draw(0,0,part);
					regis_move(ix,iy);

					set_linestyle(4);
					draw_box(part^.bounds);
					set_linestyle(l_style);
				end;

			  end;
                                         
		'r'	: begin		(**** redraw workspace ****)
				re_draw;
				if(part <> nil) then
				begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				end;
  			  end;
		'R'	: begin		(**** redraw grid ****)
				if (grid_on ) then draw_grid;
  			  end;
		'M'	: begin		(**** merge files ****)
				load(false,'m');
				re_draw;
				if(part <> nil) then
				begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				end;
			  end;
		'F'	: begin		(**** filled objects on ****)
				fill_on := not fill_on;
				if (menu_draw) then draw_menu;
			  end;
		'g'	: begin		(**** grid on ****)
				grid_on := not grid_on;
				if( not grid_on) then clear_plane(1);
				if (grid_on ) then draw_grid;
				if (menu_draw) then draw_menu;

			  end;
		'G'	: begin		(**** grid size ****)
				regis_off;                  
				write('Grid Size? [',grid_size:2,']');
				readln(dummy_s);
				writeln;
				readv(dummy_s,grid_size,ERROR := CONTINUE);
				if (grid_size <= 0) then grid_size := 1;
				regis_on;
				if(grid_on) then
				 begin
				 clear_plane(1);
				 draw_grid;
				 end;
			  end;
		'I'	: begin
				input_cursor:=1+(input_cursor mod 2);
			  end;
		'L'	: begin
				load(false,'l');
				clear_plane(1);
				re_draw;
				if (grid_on) then draw_grid;
				part := nil;
				 end;
		'S'	: begin
				save;
				re_draw;
				if(part <> nil) then
				begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				end;
			  end;
		'J'	: begin
			  if (part <> nil) then
			  begin
				undraw_box(part^.bounds);
				draw(0,0,part);
				un_join(part);			
				part  := nil;
			  end;
			 end; (* of unjoin *)

		'j'	: begin	(* join objects *)
			let_go(part);
			trect.x := ix;
			trect.y := iy;
			regis_move(ix,iy);
			regis_gin(dx,dy,key,4);
			trect.w := dx-ix;
			trect.h := dy-iy;

			part := join(trect);  (* make new part *)
			if (part <> nil) then (* outline new part *)
			 begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
			 end;
			end;

		'k'	: begin
				arrow_on := not arrow_on;
				if (menu_draw) then draw_menu;
			 end;
		's'	: begin                               
				let_go(part);
				regis_move(ix,iy);
				gimme(part);
				part^.l_style := l_style;
				mix:= ix;
				maxx:= ix;
				miy := iy;
				may := iy;
                                
				x_array[1] := 0;
				y_array[1] := 0;
	 				tx := ix; ty := iy;      
				i := 2;
				while (key <> ' ') and (key <> 'ñ' )and (i < 20) do 
				begin
                
				temp_draw := menu_draw;
				menu_draw := false;
				    regis_gin(dx,dy,key,3);
				menu_draw := temp_draw;
					regis_move(dx,dy);
					
					mix := min(mix,dx);        
					maxx := max(maxx,dx);
					miy := min(miy,dy);
					may := max(may,dy);

					x_array[i] := dx-tx;
					y_array[i] := dy-ty;
	  				tx := dx; ty := dy;      
					i:= i+1;
			
				end;
			part^.bounds.x := mix;
			part^.bounds.y := miy;
			part^.bounds.w := maxx - mix;
			part^.bounds.h := may - miy;
                
				record_buf[rec_num] := ' ';
				regis_move(mix,miy);
				record_on := true;
				regis_dmove(ix-mix,iy-miy);
				regis_spline(x_array,y_array,i-1,open_spline);
				record_on := false;
                                                       
			part^.draw := record_buf[rec_num];
			insert(part,head);

				rec_num := (rec_num+1)mod 10;
		set_linestyle(4);
		draw_box(part^.bounds);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y;
		set_linestyle(l_style);
			  end;
		't'	: begin
				let_go(part);
				regis_off;		(** get text **)
				readln(gtext); 
				regis_on;

			gimme(part);
			part^.l_style := l_style;

			part^.bounds.x := ix;
			part^.bounds.y := iy;
			if(text_size = 0) then
			begin
			 part^.bounds.w := (length(gtext))*9;
			 part^.bounds.h := 10;
			end                     
			else
			if(text_size=1) then
			begin
			 part^.bounds.w := (length(gtext))*9*text_size;
			 part^.bounds.h := 20;
			end
			else
			begin
			 part^.bounds.w := (length(gtext))*9*text_size;
			 part^.bounds.h := 15*text_size;
			end;

				record_buf[rec_num] := ' ';
				regis_move(ix,iy);
				record_on := true;
				regis_text(gtext,text_size,2);
				record_on := false;
                
			part^.draw := record_buf[rec_num];
			insert(part,head);

				rec_num := (rec_num+1)mod 10;
		set_linestyle(4);
		draw_box(part^.bounds);
		set_linestyle(l_style);
		ix:= part^.bounds.x;
		iy:= part^.bounds.y+part^.bounds.h;
			  end;
                                        
		'_'	: begin
				regis_off;

				if(part <> nil) then 	(** global style **)
				write('Line Style? (1-9) [',
					part^.l_style:2,']')
				else
				write('Line Style? (1-9) [',
					l_style:2,']');

				readln(dummy_s);
				readv(dummy_s,i,ERROR := CONTINUE);
				writeln;
				regis_on;

				if(part <> nil) then 	(** global style **)
				begin

				 part^.l_style := i;

				 if(i<0) then part^.l_style := 0;
				 if(i>9) then part^.l_style := 9;

				 draw(0,0,part);
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				        
				end
				else
				 begin

				 l_style := i;
				 if(l_style<0) then l_style := 0;
				 if(l_style>9) then l_style := 9;
				 set_linestyle(l_style);
				 if (menu_draw) then 
					draw_menu;
				
				 end;
		

			  end;
		'T'	: begin
				regis_off;
				write('Text Size (0-16)? [',text_size:2,']');
				readln(dummy_s);
				readv(dummy_s,text_size,ERROR := CONTINUE);
				 if(text_size<0) then text_size := 0;
				writeln;
				regis_on;


			  end;


		'U'	: begin 
				let_go(part);
				if (temp2 <> nil) then
				begin
				 insert(temp2,head);
				 draw(0,0,temp2);
				end;
			  end;
		'u'	: begin
				let_go(part);
				temp2 := head;
				undraw(0,0,head);
				cut(head);  
				rec_num := (rec_num +9 ) mod 10;
				
			  end;
		'A'	: begin
		  if(part <> nil) then
				begin
				regis_off;
				write('Associate with file:');
				readln(part^.n_file); 
				regis_on;
				brighten(part);
				 draw(0,0,part);
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);

				end; (* have a part *)
			 end;		
		'x'	: begin
		  if(part <> nil) then
			if (part^.sub <> nil) then
			 begin
			 part := part^.sub;
			 while ((part <> nil) and ( (part^.n_file = '') or
						    (part^.n_file = ' '))) do
				part := part^.next; 
			 end; (* if grouped object *)

		  if(part <> nil) then
				begin
			if (part^.n_file <> ' ') and (part^.n_file<>'') then
				 begin
				 get_file(part^.n_file,'l');
				clear_plane(1);
				 re_draw;
				if (grid_on) then draw_grid;
				 part := nil;
				end; (* associated part *)

				end; (* have a part *)
			 end;		
		'z'	: begin
				 if(zoom_file <> '')and(zoom_file <> ' ') then 
				 begin
				  get_file(zoom_file,'l');
				clear_plane(1);
				 re_draw;
				if (grid_on) then draw_grid;
				 part := nil;
				 end;
			 end;		
		'Z'	: begin
				regis_off;
				write('Zoom up file= [',zoom_file,']');
				readln(zoom_file); 
				writeln;
				regis_on;
		
			  end;
		'X'	: begin
				all_delete;
				clear_plane(1);
				re_draw;
				if (grid_on) then draw_grid;
				zoom_file := loaded_file;
				part := nil;
			  end;
		'Q'	: 	done := true;
		'W'	: begin
				regis_off;
		if(part <> nil) then
		begin
		writeln('Line style of part=',part^.l_style:2);
		writeln('Associated file= ',part^.n_file);
		end
		else 
		begin
		writeln('Default extender = ',save_ext);
		writeln('Loaded file=',loaded_file);
		writeln('Zoom file=',zoom_file);
		writeln('Line style= ',l_style:2,' Text Size= ',text_size:2);
		writeln('Grid Size = ',grid_size:3,' Grid on: ',grid_on);
		writeln('Filled shapes: ',fill_on);
		end;
	if(paste_part <> nil) then writeln('Paste buffer full');
				regis_on;

			 end;	
	
		'P'	: begin                                   
			  re_draw;
			  regis_off;
				dummy_b := spawn_command_line('@md:sixel key');
			  regis_on;
			  re_draw;
	  if(part <> nil) then
		begin
		 draw(0,0,part);		 
		 draw_box(part^.bounds);
		end;
			  end;
		'O'	: begin
			  re_draw;
			  regis_off;
				dummy_b := spawn_command_line('@md:sixel key landscape');
			  regis_on;
			  re_draw;
	  if(part <> nil) then
		begin
		 draw(0,0,part);		 
		 draw_box(part^.bounds);
		end;
			  end;
		'C'	: begin
				if (grid_on) then
				move_all(400-ix,240-iy)
				else
				begin	(* move constrained to grid *)
				dx := 400-(400 mod grid_size);
				dy := 240-(240 mod grid_size);
				move_all(dx-ix,dx-iy);
				end;
				re_draw;
			  if(part <> nil) then
				begin
				 draw(0,0,part);		 
				set_linestyle(4);
				 draw_box(part^.bounds);
				set_linestyle(l_style);
				end;
			  end;
		'@'	: begin
				regis_off;
				write('New menu (10 items):');
				readln(new_icon);
				writeln;
				if (length(new_icon)=10) then
				for i:= 0 to 9 do
				 begin
				 icon[i] := new_icon[i+1];
				 end;
				regis_on;
				re_draw;
			 end;
				
		'h','H' : begin
			   	regis_reset;
				help_menu;
			   	regis_gin(ix,iy,key,input_cursor);
			   	re_draw;
	  if(part <> nil) then
		begin
		 draw(0,0,part);		 
		 draw_box(part^.bounds);
		end;
			     end;
	
		'`','õ','ö'		: begin  (* #3 mouse button *)
				do_again := true;
			  end;

	  end; (* case *)
	if(control_hit) then
	begin

	 case key of
		chr(34+96)	: begin
				menu_draw := not menu_draw;
			if(menu_draw ) then draw_menu
			else undraw_menu;

(*				   re_draw;
			 if (part <> nil) then
			  begin
				 draw(0,0,part);
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
			  end; 
*)
			  end;

		'a'	: begin (* find key *)
		 regis_move(ix,iy);
		if(part <> nil) then
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 part := find_next(ix,iy,part^.next);
		end                  
		else part := find_next(ix,iy,head);

		if (part <> nil) then
		begin
		 set_linestyle(4);
		 draw_box(part^.bounds);
		 set_linestyle(l_style);
		end;
			  end;
		'b'	: begin (* insert here key *)
				if (paste_part <> nil )then 
				begin
					gimme(temp);
					copy_tree(paste_part,temp);
					temp^.bounds.x := ix;
					temp^.bounds.y := iy;
					draw(0,0,temp);
				   	insert(temp,head);
					ix:= temp^.bounds.x;
					iy:= temp^.bounds.y;
				end;
			  end;
		'c'	: begin (* remove key *)
				if (part <> nil) then 
				begin
				 cut(part);
				 undraw(0,0,part);
				 undraw_box(part^.bounds);
				 paste_part :=part;
				 ix := part^.bounds.x;
				 iy := part^.bounds.y;
				part := nil;
				end;

			 end;
		'd'	: begin (* Select key *)
		if(part <> nil) then
		begin
		 undraw_box(part^.bounds);
		 draw(0,0,part);		 
		 part := nil;
		end;

				part:=find(ix,iy);

		if (part <> nil) then 
	    begin 		(* if something there *)
				set_linestyle(4); (* redraw as dotted *)
				draw_box(part^.bounds);
				set_linestyle(l_style);
		end; (* of something there *)
				
			  end;
		'|'		: begin (* help key *)
			   	regis_reset;
				help_menu;
			   	regis_gin(ix,iy,key,1);
			   	re_draw;
			     end;
		'e'	: begin  (* prev screen *)
				move_all(0,240);
				re_draw;
				if(part <> nil) then
				begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				end;
			   end;

		'f'	: begin (* next screen *)
				move_all(0,-240);
				re_draw;
				if(part <> nil) then
				begin
				 set_linestyle(4);
				 draw_box(part^.bounds);
				 set_linestyle(l_style);
				end;
				   end;
		end;

	end;


	 end; (* while *)
	regis_reset;
	regis_off;              
	regis_exit;
	all_delete;	

end.
                                       
                                                
