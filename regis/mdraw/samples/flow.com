$!	ready the mdraw pictures for charts.tex   
$
$ 	inquire/nopunct conv "Should I convert the flow pictures? (y/n)"
$	if .not. conv then goto texit
$
$	vregis -t -o flow1 flow2 flow3
$
$!	TeX the main file which indirectly inputs the three flowcharts
$!	take a look at charts.tex to see how it is done
$
$texit:
$	tex charts.tex
$	dvi2ln3 charts.dvi
$
$!	print it out on the ln03	
$!	lazprint := print/form=ln03_a_size/nofeed 
$!	lazprint charts.ln3	
$
$ exit
