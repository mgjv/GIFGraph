#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::linespoints.pm
#
# $Id: linespoints.pm,v 1.1.1.5 1999-10-10 12:37:16 mgjv Exp $
#
#==========================================================================

package GIFgraph::linespoints;
 
use strict qw(vars refs subs);
 
use GIFgraph::axestype;
use GIFgraph::lines;
use GIFgraph::points;
 
# Even though multiple inheritance is not really a good idea,
# since lines and points have the same parent class, I will do it here,
# because I need the functionality of the markers and the line types

@GIFgraph::linespoints::ISA = qw( GIFgraph::lines GIFgraph::points );

{
	sub initialise()
	{
		my $self = shift;

		$self->GIFgraph::lines::initialise();
		$self->GIFgraph::points::initialise();
	}

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
