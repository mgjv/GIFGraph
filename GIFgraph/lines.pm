#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::lines.pm
#
# $Id: lines.pm,v 1.1.1.4 1999-10-10 12:36:58 mgjv Exp $
#
#==========================================================================

package GIFgraph::lines;

use strict qw(vars refs subs);
 
use GD;
use GIFgraph::axestype;

@GIFgraph::lines::ISA = qw( GIFgraph::axestype );

my %Defaults = (
	
	# The width of the line to use in the lines and linespoints graphs
	# in pixels
 
	line_width		=> 1,

	# Set the scale of the line types

	line_type_scale	=> 8,

	# Which line typess to use

	line_types		=> [1],
);

{
	sub initialise()
	{
		my $self = shift;

		$self->SUPER::initialise();

		foreach my $key (keys %Defaults)
		{
			$self->set( $key => $Defaults{$key} );
		}
	}

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
			my $type = $s->pick_line_type($ds);

			for my $i (1 .. $s->{numpoints}) 
			{
				next if (!defined($$d[$ds][$i]));
				my ($xe, $ye) = $s->val_to_pixel($i+1, $$d[$ds][$i], $ds);

				#$g->line( $xb, $yb, $xe, $ye, $dsci );
				$s->draw_line( $g, $xb, $yb, $xe, $ye, $type, $dsci );
				($xb, $yb) = ($xe, $ye);
		   }
		}
	}

	sub pick_line_type($)
	{
		my $s = shift;
		my $num = shift;

		if ( exists $s->{line_types} )
		{
			return $s->{line_types}[ $num % (1 + $#{$s->{line_types}}) - 1 ];
		}

		return $num % 4 ? $num % 4 : 4;
	}

	sub draw_line($$$$$$) # ($xs, $ys, $xe, $ye, $type, $colour_index)
	{
		my $s = shift;
		my $g = shift;
		my ($xs, $ys, $xe, $ye, $type, $clr) = @_;

		my $lw = $s->{line_width};
		my $lts = $s->{line_type_scale};

		my $style = gdStyled;
		my @pattern = ();

		LINE: {

			($type == 2) && do {
				# dashed

				for (1..$lts) { push( @pattern, $clr ); }
				for (1..$lts) { push( @pattern, gdTransparent ); }

				$g->setStyle(@pattern);

				last LINE;
			};

			($type == 3) && do {
				# dotted,

				for (1..2) { push( @pattern, $clr ); }
				for (1..2) { push( @pattern, gdTransparent ); }

				$g->setStyle(@pattern);

				last LINE;
			};

			($type == 4) && do {
				# dashed and dotted

				for (1..$lts) { push( @pattern, $clr ); }
				for (1..2) { push( @pattern, gdTransparent ); }
				for (1..2) { push( @pattern, $clr ); }
				for (1..2) { push( @pattern, gdTransparent ); }

				$g->setStyle(@pattern);

				last LINE;
			};

			# default: solid
			$style = $clr;
		}

		# Tried the line_width thing with setBrush, ugly results
		# TODO: This loop probably should be around the datasets 
		# for nicer results
		for my $i (1..$lw)
		{
			my $yslw = $ys + int($lw/2) - $i;
			my $yelw = $ye + int($lw/2) - $i;

			# Need the setstyle to reset 
			$g->setStyle(@pattern) if (@pattern);
			$g->line( $xs, $yslw, $xe, $yelw, $style );
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
		my $type = $s->pick_line_type($n);

		$y += int($s->{lg_el_height}/2);

		$s->draw_line(
			$g,
			$x, $y, 
			$x + $s->{legend_marker_width}, $y,
			$type, $ci
		);
	}

} # End of package GIFgraph::lines

1;
