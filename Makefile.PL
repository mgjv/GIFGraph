# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.3 1999-12-26 04:39:12 mgjv Exp $
 
#--- Distribution section ---

use ExtUtils::MakeMaker;

WriteMakefile(
		'VERSION_FROM'		=> 'GIFgraph.pm',
        'DISTNAME'  		=> 'GIFgraph',
        'NAME'      		=> 'GIFgraph',

		($] >= 5.005 ?
			('ABSTRACT'		=> 'Produce GIF charts with GD',
			 'AUTHOR'		=> 'Martien Verbruggen (mgjv@comdyn.com.au)',
			) : ()
		),

		'PREREQ_PM'			=> { 
			'GD::Graph' => '1.20',
			'GD'		=> '1.14'
		},
 
        'dist'    			=> {
			'COMPRESS' 		=> 'gzip -9f',
			'SUFFIX'   		=> 'gz', 
		},
 
        'clean'   	=> { 'FILES' => q(*% *.b[ac]k *.old tags) },
);

# GD has already been 'required' by the WriteMakeFile call, but it
# doesn't hurt to do it again.
require GD;

if (GD::Image->can('gif'))
{
	require GIFgraph::Convert;
	GIFgraph::Convert::checkImageMagick();
}

print <<END;

Please read the README. GIFgraph is now a wrapper around GD::Graph, and
requires GD::Graph and GDTextUtils to be installed. it also requires
some conversion software for use with GD >= 1.20.

END
