#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::linespoints.pm
#
# $Id: linespoints.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
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
