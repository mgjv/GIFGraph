#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::axestype.pm
#
# $Id: axestype.pm,v 1.4 1999-12-26 10:59:19 mgjv Exp $
#
#==========================================================================

package GIFgraph::axestype;
use strict;
use GIFgraph;
use GD::Graph::axestype;
@GIFgraph::axestype::ISA = qw(GD::Graph::axestype GIFgraph);

# Intentionally left blank

1;
