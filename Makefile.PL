# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.3 1999-10-10 12:33:43 mgjv Exp $
 
#--- Distribution section ---
 
$MODNAME = 'GIFgraph';
 
BEGIN { require 5.001 }
 
use ExtUtils::MakeMaker;
 
#--- MY package
 
# sub MY::libscan
# {
	# my($self,$path) = @_;
 # 
	# return '' 
		# if ($path =~ m:/(RCS|CVS|SCCS)/: ||
			# $path =~ m:[~%]$: ||
			# $path =~ m:\.(orig|rej|nfs|b[ac]k|swp)$:
          # );
 # 
	# print "$path\n";
	# $path;
# }

 
#--- Write the Makefile
 
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

