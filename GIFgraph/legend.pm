#==========================================================================
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::legend.pm
#
# $Id: legend.pm,v 1.1 1999-10-10 13:03:23 mgjv Exp $
#
#==========================================================================

use strict qw(vars refs subs);
 
use GD;
 
package GIFgraph::legend;
 
{
	sub new
	{
		my $type = shift;
		my $self = {};
		bless $self, $type;

		return $self;
	}

	# for lines: 
	#	line description
	# for bars, areas:  
	#	block description
	# for points:
	#	marker, description
	# for linespoints:
	#	line+marker, description

} # End of package GIFgraph::legend

1;
