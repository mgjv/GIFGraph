# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.6 2000-01-04 05:55:34 mgjv Exp $
 
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

		'PMLIBDIRS' 		=> [ qw(Bundle GIFgraph) ],

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

# REMOVE THE FOLLOWING CHECKS IF YOU DON'T USE Image::Magick AND YOU
# HAVE EDITED GIFgraph::Convert.
if (GD::Image->can('png'))
{
	print "Checking for conversion of PNG to GIF\n";
	require GIFgraph::Convert;
	GIFgraph::Convert::checkImageMagick();
}

print <<END;

Please read the README. GIFgraph is now a wrapper around GD::Graph, and
requires GD::Graph and GDTextUtils to be installed. it also requires
some conversion software for use with GD >= 1.20.

END
