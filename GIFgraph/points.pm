#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::points.pm
#
# $Id: points.pm,v 1.1.1.3 1999-10-10 12:33:47 mgjv Exp $
#
#==========================================================================

package GIFgraph::points;

use strict qw(vars refs subs);
 
use GIFgraph::axestype;
use GIFgraph::utils qw(:all);

@GIFgraph::points::ISA = qw( GIFgraph::axestype );

{
	# PRIVATE
	sub draw_data($$) # GD::Image, \@data
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;

		foreach my $ds (1..$s->{numsets}) 
		{
			# Pick a colour
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );

			for my $i (0 .. $s->{numpoints}) 
			{
				next if (!defined($$d[$ds][$i]));
				my ($xp, $yp) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);
				$s->marker( $g, $xp, $yp, $s->pick_marker($ds), $dsci );
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

		my $old_ms = $s->{marker_size};
		my $ms = _min($s->{legend_marker_height}, $s->{legend_marker_width});

		($s->{marker_size} > $ms/2) and $s->{marker_size} = $ms/2;
		
		$x += int($s->{legend_marker_width}/2);
		$y += int($s->{lg_el_height}/2);

		$n = $s->pick_marker($n);

		$s->marker($g, $x, $y, $n, $ci);

		$s->{marker_size} = $old_ms;
	}

} # End of package GIFgraph::Points

1;
