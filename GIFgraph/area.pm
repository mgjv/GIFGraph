#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::area.pm
#
# $Id: area.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
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
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my $ds;
		foreach $ds (1..$s->{numsets}) {
#		 foreach $ds (1) {
			my $dsci = $s->set_clr( $g, $s->pick_data_clr($ds) );
			my ($xb, $yb) = $s->val_to_pixel( 1, $$d[$ds][0], $ds);
			$g->line( $xb, $yb, $xb, $s->{bottom}, $dsci );
			for (1..$s->{numpoints}) {
#				 print STDERR "GIFgraph::lines::draw_data: $ds, $_ = $$d[$ds][$_]\n";
				my ($xe, $ye) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
				$g->line( $xb, $yb, $xe, $ye, $dsci );
				($xb, $yb) = ($xe, $ye);
			}
 
			$g->line( $xb, $yb, $xb, $s->{bottom}, $dsci );
			$g->line( $s->{left}, $s->{bottom}, 
					  $s->{right}, $s->{bottom}, $dsci);
			$g->fillToBorder( $xb-1, $s->{bottom}-1, $dsci, $dsci );
			$g->line( $s->{left}, $s->{bottom}, 
					  $s->{right}, $s->{bottom}, $s->{fgci} );
 
			my ($xb, $yb) = $s->val_to_pixel( 1, $$d[$ds][0], $ds);
			$g->line( $xb, $yb, $xb, $s->{bottom}, $s->{acci} );
			for (1..$s->{numpoints}) {
				my ($xe, $ye) = $s->val_to_pixel($_+1, $$d[$ds][$_], $ds);
				$g->line( $xb, $yb, $xe, $ye, $s->{acci} );
				$g->dashedLine( $xe, $ye, $xe, $s->{bottom}, $s->{acci} );
				($xb, $yb) = ($xe, $ye);
		   }
			$g->line( $xb, $yb, $xb, $s->{bottom}, $s->{acci} );
		}
		$g->line( $s->{left}, $s->{bottom}, 
				  $s->{right}, $s->{bottom}, $s->{fgci} );
	}
 
} # End of package GIFgraph::area
 
1;
