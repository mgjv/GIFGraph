#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::points.pm
#
# $Id: points.pm,v 1.1.1.2 1999-10-10 12:07:06 mgjv Exp $
#
#==========================================================================

use strict qw(vars refs subs);
 
use GIFgraph::axestype;

package GIFgraph::points;

use vars qw( @ISA );
@ISA = qw( GIFgraph::axestype );
{
	# PRIVATE
	sub draw_data { # GD::Image, \@data

		my $s = shift;
		my $g = shift;
		my $d = shift;

		foreach my $ds (1..$s->{numsets}) 
		{
			# Pick a colour
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );

			for my $i (0 .. $s->{numpoints}) 
			{
				my ($xp, $yp) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);
				$s->marker( $g, $xp, $yp, $s->pick_marker($ds), $dsci );
			}
		}
	}
 
} # End of package GIFgraph::Points

1;
