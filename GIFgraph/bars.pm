#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::bars.pm
#
# $Id: bars.pm,v 1.1.1.3 1999-10-10 12:33:47 mgjv Exp $
#
#==========================================================================
 
package GIFgraph::bars;

use strict qw(vars refs subs);

use GIFgraph::axestype;
use GIFgraph::utils qw(:all);

@GIFgraph::bars::ISA = qw( GIFgraph::axestype );

{
	# PRIVATE
	sub draw_data{

		my $s = shift;
		my $g = shift;
		my $d = shift;

		if ( $s->{overwrite} ) 
		{
			$s->draw_data_overwrite($g,$d);
		} 
		else 
		{
			$s->draw_data_side_by_side($g,$d);
		}
	}
 
	# Draws the bars on top of each other
 
	sub draw_data_overwrite {

		my $s = shift;
		my $g = shift;
		my $d = shift;

		my $zero = $s->{zeropoint};

		for my $i (0..$s->{numpoints}) 
		{
			my $bottom = $zero;
			my ($xp, $t);

			for my $j (1..$s->{numsets}) 
			{
				next if (!defined($$d[$j][$i]));

				# get data colour
				my $dsci = $s->set_clr( $g, $s->pick_data_clr($j) );

				# get coordinates of top and center of bar
				($xp, $t) = $s->val_to_pixel($i+1, $$d[$j][$i], $j);

				# calculate left and right of bar
				my $l = $xp - _round($s->{x_step}/2);
				my $r = $xp + _round($s->{x_step}/2);

				# calculate new top
				$t -= ($zero - $bottom) if ($s->{overwrite} == 2);

				# draw the bar
				if ($$d[$j][$i] >= 0)
				{
					# positive value
					$g->filledRectangle( $l, $t, $r, $bottom, $dsci );
					$g->rectangle( $l, $t, $r, $bottom, $s->{acci} );
				}
				else
				{
					# negative value
					$g->filledRectangle( $l, $bottom, $r, $t, $dsci );
					$g->rectangle( $l, $bottom, $r, $t, $s->{acci} );
				}

				# reset $bottom to the top
				$bottom = $t if ($s->{overwrite} == 2);
			}
		}

		# redraw the 'zero' axis
		$g->line( 
			$s->{left}, $s->{zeropoint}, 
			$s->{right}, $s->{zeropoint}, 
			$s->{fgci} );
	 }

	# Draw the bars side by side
 
	sub draw_data_side_by_side { # GD::Image, \@data

		my $s = shift;
		my $g = shift;
		my $d = shift;

		foreach my $ds (1..$s->{numsets}) 
		{
			# Pick a data colour
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );

			for my $i (0..$s->{numpoints}) 
			{
				next if (!defined($$d[$ds][$i]));

				# get coordinates of top and center of bar
				my ($xp, $t) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);

				# calculate left and right of bar
				my $l = 
					$xp - $s->{x_step}/2 +
					_round(($ds-1) * $s->{x_step}/$s->{numsets});
				my $r = 
					$xp - $s->{x_step}/2 +
					_round($ds * $s->{x_step}/$s->{numsets});

				# draw the bar
				if ($$d[$ds][$i] >= 0)
				{
					# positive value
					$g->filledRectangle( $l, $t, $r, $s->{zeropoint}, $dsci );
					$g->rectangle( $l, $t, $r, $s->{zeropoint}, $s->{acci} );
				}
				else
				{
					# negative value
					$g->filledRectangle( $l, $s->{zeropoint}, $r, $t, $dsci );
					$g->rectangle( $l, $s->{zeropoint}, $r, $t, $s->{acci} );
				}

			}
		}

		# redraw the 'zero' axis
		$g->line( 
			$s->{left}, $s->{zeropoint}, 
			$s->{right}, $s->{zeropoint}, 
			$s->{fgci} );
	}
 
} # End of package GIFgraph::bars

1;
