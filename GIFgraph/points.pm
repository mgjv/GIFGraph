#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::points.pm
#
# $Id: points.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
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
		my $ds;
		foreach $ds (1..$s->{numsets}) {
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			for (0..$s->{numpoints}) {
				my ($xp, $yp) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
				$s->marker( $g, $xp, $yp, $s->pick_marker($ds), $dsci );
		   }
		}
	}
 
} # End of package GIFgraph::Points

1;
