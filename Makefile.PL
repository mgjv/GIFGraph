# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.4 1999-10-10 12:37:32 mgjv Exp $
 
#--- Distribution section ---
 
$MODNAME = 'GIFgraph';
 
BEGIN { require 5.001 }
 
use ExtUtils::MakeMaker;
 
my @clean = qw(*% *.html *.b[ac]k *.old .[A-z]* tags);
push @clean, map { "*/$_" } @clean;
 
WriteMakefile(
		'VERSION_FROM'		=> $MODNAME . '.pm',	#finds $VERSION
        'DISTNAME'  		=> $MODNAME,
        'NAME'      		=> $MODNAME,

		'PREREQ_PM'			=> { 'GD' => 0, },
 
        'dist'    			=> {
			'COMPRESS' 		=> 'gzip -9f',
			'SUFFIX'   		=> 'gz', 
		},
 
        'clean'   => { 'FILES' => join(" ", @clean), },
);

