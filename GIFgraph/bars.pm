#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::bars.pm
#
# $Id: bars.pm,v 1.2 1999-12-26 04:39:12 mgjv Exp $
#
#==========================================================================
 
package GIFgraph::bars;
use strict;

use GIFgraph::axestype;
use GIFgraph::utils qw(:all);
@GIFgraph::bars::ISA = qw(GIFgraph::axestype GD::Graph::bars);

# Intentionally left blank

1;
