#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::bars.pm
#
# $Id: bars.pm,v 1.3 1999-12-26 10:59:19 mgjv Exp $
#
#==========================================================================
 
package GIFgraph::bars;
use strict;
use GIFgraph;
use GD::Graph::bars;
@GIFgraph::bars::ISA = qw(GD::Graph::bars GIFgraph);

sub plot 
{ 
	my $self = shift;
	my $gd   = $self->SUPER::plot(@_);
	$self->_old_plot($gd);
}

1;
