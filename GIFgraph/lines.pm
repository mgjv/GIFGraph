#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::lines.pm
#
# $Id: lines.pm,v 1.1.1.2 1999-10-10 12:07:06 mgjv Exp $
#
#==========================================================================

use strict qw(vars refs subs);
 
use GIFgraph::axestype;

package GIFgraph::lines;

use vars qw( @ISA );
@ISA = qw( GIFgraph::axestype );
{
	# PRIVATE
	sub draw_data { # GD::Image, \@data

		my $s = shift;
		my $g = shift;
		my $d = shift;

		foreach my $ds (1 .. $s->{numsets}) 
		{
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			my ($xb, $yb) = $s->val_to_pixel( 1, $$d[$ds][0], $ds);

			for my $i (1 .. $s->{numpoints}) 
			{
				my ($xe, $ye) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);

				$g->line( $xb, $yb, $xe, $ye, $dsci );
				($xb, $yb) = ($xe, $ye);
		   }
		}
	}

} # End of package GIFgraph::lines

1;
