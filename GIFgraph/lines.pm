#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::lines.pm
#
# $Id: lines.pm,v 1.1.1.3 1999-10-10 12:33:47 mgjv Exp $
#
#==========================================================================

package GIFgraph::lines;

use strict qw(vars refs subs);
 
use GIFgraph::axestype;

@GIFgraph::lines::ISA = qw( GIFgraph::axestype );

{
	# PRIVATE
	sub draw_data($$) # GD::Image, \@data
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;

		foreach my $ds (1 .. $s->{numsets}) 
		{
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			my ($xb, $yb) = $s->val_to_pixel( 1, $$d[$ds][0], $ds);

			for my $i (1 .. $s->{numpoints}) 
			{
				next if (!defined($$d[$ds][$i]));
				my ($xe, $ye) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);

				$g->line( $xb, $yb, $xe, $ye, $dsci );
				($xb, $yb) = ($xe, $ye);
		   }
		}
	}

	sub draw_legend_marker($$$$) # (GD::Image, data_set_number, x, y)
	{
		my $s = shift;
		my $g = shift;
		my $n = shift;
		my $x = shift;
		my $y = shift;

		my $ci = $s->set_clr( $g, $s->pick_data_clr($n) );

		$y += int($s->{lg_el_height}/2);

		$g->line(
			$x, $y, 
			$x + $s->{legend_marker_width}, $y,
			$ci
		);
	}

} # End of package GIFgraph::lines

1;
