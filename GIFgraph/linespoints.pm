#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::linespoints.pm
#
# $Id: linespoints.pm,v 1.1.1.2 1999-10-10 12:07:05 mgjv Exp $
#
#==========================================================================

use strict qw(vars refs subs);
 
use GIFgraph::axestype;
use GIFgraph::lines;
use GIFgraph::points;
 
package GIFgraph::linespoints;
 
use vars qw( @ISA );
@ISA = qw( GIFgraph::axestype );
{
	# PRIVATE
	sub draw_data { # GD::Image, \@data

		my $s = shift;
		my $g = shift;
		my $d = shift;

		GIFgraph::lines::draw_data( $s, $g, $d );
		GIFgraph::points::draw_data( $s, $g, $d );

	}
 
} # End of package GIFgraph::linesPoints

1;
