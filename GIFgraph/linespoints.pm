#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::linespoints.pm
#
# $Id: linespoints.pm,v 1.1.1.3 1999-10-10 12:33:47 mgjv Exp $
#
#==========================================================================

package GIFgraph::linespoints;
 
use strict qw(vars refs subs);
 
use GIFgraph::axestype;
use GIFgraph::lines;
use GIFgraph::points;
 
# Multiple inheritance is not really a good idea in this case, 
# since lines and points have the same parent class
# even though it might make sense logically, and even though it
# will actually work.

# @GIFgraph::linespoints::ISA = qw( GIFgraph::lines GIFgraph::points );

@GIFgraph::linespoints::ISA = qw( GIFgraph::axestype );

{
	# PRIVATE
	sub draw_data($$) # GD::Image, \@data
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;

		$s->GIFgraph::points::draw_data( $g, $d );
		$s->GIFgraph::lines::draw_data( $g, $d );

	}
 
	sub draw_legend_marker($$$$) # (GD::Image, data_set_number, x, y)
	{
		my $s = shift;
		my $g = shift;
		my $n = shift;
		my $x = shift;
		my $y = shift;

		$s->GIFgraph::points::draw_legend_marker($g, $n, $x, $y);
		$s->GIFgraph::lines::draw_legend_marker($g, $n, $x, $y);
	}

} # End of package GIFgraph::linesPoints

1;
