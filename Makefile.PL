# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.2 1999-10-10 13:03:19 mgjv Exp $
 
#--- Distribution section ---
 
$MODNAME = 'GIFgraph';
 
BEGIN { require 5.004 }
 
use ExtUtils::MakeMaker;
use Config;
 
my @clean = qw(*% *.b[ac]k *.old tags samples/sample??.gif);
opendir(DD, 'samples') || die 'samples directory missing';
my @samples = 
	sort
	map { s/\.pl$/.gif/; $_ } 
	grep { /^sample..\.pl$/ } 
	readdir(DD);
closedir(DD);

WriteMakefile(
		'VERSION_FROM'		=> $MODNAME . '.pm',	#finds $VERSION
        'DISTNAME'  		=> $MODNAME,
        'NAME'      		=> $MODNAME,

		($] >= 5.005 ?
			('ABSTRACT'		=> 'Produces GIF graph plots',
			 'AUTHOR'		=> 'Martien Verbruggen (mgjv@comdyn.com.au)',
			) : ()
		),

		'PREREQ_PM'			=> { 'GD' => 0, },
 
        'dist'    			=> {
			'COMPRESS' 		=> 'gzip -9f',
			'SUFFIX'   		=> 'gz', 
		},
 
        'clean'   	=> { 'FILES' => q(*% *.b[ac]k *.old tags) },
        'realclean'	=> { 'FILES' => q(samples/sample??.gif) },

		'macro'	  => { 'SAMPLES' => "@samples" },
);

sub MY::postamble {
	my $postamble =<<END;
samples: all
	@(cd samples && make PERL=$Config{'perl'})
	echo Samples have been created in samples directory
END

	$postamble;
}

