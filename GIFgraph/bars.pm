#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::bars.pm
#
# $Id: bars.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
#
#==========================================================================
 
use strict qw(vars refs subs);

package GIFgraph::bars;

use GIFgraph::axestype;
use GIFgraph::utils qw(:all);

use vars qw( @ISA );
@ISA = qw( GIFgraph::axestype );

{
	# PRIVATE
	sub draw_data{
		my $s = shift;
		my $g = shift;
		my $d = shift;
		if ( $s->{overwrite} ) {
			$s->draw_data_overwrite($g,$d);
		} else {
			$s->draw_data_side_by_side($g,$d);
		}
	}
 
	# Draws the bars on top of each other
 
	sub draw_data_overwrite{
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my $ds;
		foreach $ds (1..$s->{numsets}) {
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			for (0..$s->{numpoints}) {
				my ($xp, $t) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
				my $l = $xp-_round($s->{x_step}/2);
				my $r = $xp+_round($s->{x_step}/2);
				$g->filledRectangle( $l, $t, $r, $s->{bottom}, $dsci );
				$g->rectangle( $l, $t, $r, $s->{bottom}, $s->{acci} );
				$g->line( $l, $s->{bottom}, $r, $s->{bottom}, $s->{fgci} );
			}
		}
		$g->line( $s->{left}, $s->{bottom}, 
				  $s->{right}, $s->{bottom}, 
				  $s->{fgci} );
		$g->line( $s->{left}, $s->{top}, 
				  $s->{right}, $s->{top}, 
				  $s->{fgci} );
	 }
 
	# Draw the bars side by side
 
	sub draw_data_side_by_side { # GD::Image, \@data
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my $ds;
		foreach $ds (1..$s->{numsets}) {
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			for (0..$s->{numpoints}) {
				my ($xp, $t) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
				my $l = $xp-$s->{x_step}/2+
						_round(($ds-1)*$s->{x_step}/$s->{numsets});
				my $r = $xp-$s->{x_step}/2+
						_round($ds*$s->{x_step}/$s->{numsets});
				$g->filledRectangle( $l, $t, $r, $s->{bottom}, $dsci );
				$g->rectangle( $l, $t, $r, $s->{bottom}, $s->{acci} );
				$g->line( $l, $s->{bottom}, $r, $s->{bottom}, $s->{fgci} );
			}
		}
		$g->line( $s->{left}, $s->{bottom}, 
				  $s->{right}, $s->{bottom}, 
				  $s->{fgci} );
		$g->line( $s->{left}, $s->{top}, 
				  $s->{right}, $s->{top}, 
				  $s->{fgci} );
	}
 
} # End of package GIFgraph::bars

1;
