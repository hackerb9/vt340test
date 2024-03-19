$!	Setup file for mdraw 
$
$!	Create directory
$
$!	path := "disk_tex:[mdraw]"
$	path := "disk_dgpwc:[mike_d.m5]"
$
$	inquire/nopunct initial "Is this the initial creation?"
$	if .not. initial then goto logs
$
$	create/directory 'path
$
$!	copy files to it
$
$	copy mdraw.exe,vregis.exe,sixel.com,sixland.exe,sixel.exe 'path'
$	copy mdraw.mdr 'path'
$
$logs:
$!	set up logicals and symbols
$!	this stuff would go in a group login file or a personal one
$
$	assign 'path' mdraw
$	mdraw :== $mdraw:mdraw.exe
$	sixel :== @mdraw:sixel.com
$	vregis :== $mdraw:vregis.exe
$
$
