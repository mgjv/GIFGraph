#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::lines.pm
#
# $Id: lines.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
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
		my $ds;
		foreach $ds (1..$s->{numsets}) {
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			my ($xb, $yb) = $s->val_to_pixel( 1, $$d[$ds][0], $ds);
			for (1..$s->{numpoints}) {
#			print STDERR "GIFgraph::lines::draw_data: $ds, $_ = $$d[$ds][$_]\n";
				my ($xe, $ye) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
#			print STDERR "GIFgraph::lines::draw_data: $dsci: $xb, $yb: $xe, $ye\n";
				$g->line( $xb, $yb, $xe, $ye, $dsci );
				($xb, $yb) = ($xe, $ye);
		   }
		}
	}
 
} # End of package GIFgraph::lines

1;
