#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::area.pm
#
# $Id: area.pm,v 1.1.1.2 1999-10-10 12:07:05 mgjv Exp $
#
#==========================================================================
 
use strict qw(vars refs subs);

use GIFgraph::axestype;

package GIFgraph::area;
use vars qw( @ISA );

@ISA = qw( GIFgraph::axestype );
{
	# PRIVATE
	sub draw_data { # GD::Image, \@data

		my $s = shift;		# object reference
		my $g = shift;		# gd object reference
		my $d = shift;		# reference to data set

		foreach my $ds (1..$s->{numsets}) 
		{
			# Select a data colour
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );

			# Create a new polygon
			my $poly = new GD::Polygon();

			# Add the first 'zero' point
			my ($x, $y) = $s->val_to_pixel(1, 0, $ds);
			$poly->addPt($x, $y);

			# Add the data points
			for my $i (0 .. $s->{numpoints}) 
			{
				($x, $y) = $s->val_to_pixel($i + 1, $$d[$ds][$i], $ds);
				$poly->addPt($x, $y);
			}

			# Add the last zero point
			($x, $y) = $s->val_to_pixel($s->{numpoints} + 1, 0, $ds);
			$poly->addPt($x, $y);

			# Draw a filled and a line polygon
			$g->filledPolygon($poly, $dsci);
			$g->polygon($poly, $s->{acci});

			# Draw the accent lines
			for my $i (1 .. ($s->{numpoints} - 1)) 
			{
				($x, $y) = $s->val_to_pixel($i + 1, $$d[$ds][$i], $ds);
				$g->dashedLine( $x, $y, $x, $s->{zeropoint}, $s->{acci} );
		   }
		}
	}

} # End of package GIFgraph::area
 
1;
