#==========================================================================
#			   Copyright (c) 1995-1998 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::mixed.pm
#
# $Id: mixed.pm,v 1.1.1.1 1999-10-10 12:40:28 mgjv Exp $
#
#==========================================================================

package GIFgraph::mixed;
 
use strict;
 
use GIFgraph::axestype;
use GIFgraph::lines;
use GIFgraph::points;
use GIFgraph::linespoints;
use GIFgraph::bars;
use GIFgraph::area;
 
# Even though multiple inheritance is not really a good idea, I will
# do it here, because I need the functionality of the markers and the
# line types We'll include axestype as the first one, to make sure
# that's where we look first for methods.

@GIFgraph::mixed::ISA = qw( 
	GIFgraph::axestype 
	GIFgraph::lines 
	GIFgraph::points 
);

my %Defaults = (
	default_type => 'lines',
	mixed => 1,
);

{
	sub initialise()
	{
		my $self = shift;

		$self->SUPER::initialise();

		my $key;
		foreach $key (keys %Defaults)
		{
			$self->set( $key => $Defaults{$key} );
		}

		$self->GIFgraph::lines::initialise();
		$self->GIFgraph::points::initialise();
	}

	sub draw_data_set($$$) # GD::Image, \@data, $ds
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my $ds = shift;

		my $type = $s->{types}->[$ds-1] || $s->{default_type};

		# Try to execute the draw_data_set function in the package
		# specified by type
		#
		eval '$s->GIFgraph::'.$type.'::draw_data_set($g, $d, $ds)';

		# If we fail, we try it in the package specified by the
		# default_type, and warn the user
		#
		if ($@)
		{
			warn "Set $ds, unknown type $type, assuming $s->{default_type}\n";

			eval '$s->GIFgraph::'.
				$s->{default_type}.'::draw_data_set($g, $d, $ds)';
		}

		# If even that fails, we bail out
		#
		die "Set $ds: unknown default type $s->{default_type}\n" if $@;
	}
 
	sub draw_legend_marker($$$$) # (GD::Image, data_set_number, x, y)
	{
		my $s = shift;
		my $g = shift;
		my $ds = shift;
		my $x = shift;
		my $y = shift;

		my $type = $s->{types}->[$ds-1] || $s->{default_type};

		eval '$s->GIFgraph::'.$type.'::draw_legend_marker($g, $ds, $x, $y)';

		eval '$s->GIFgraph::'.
			$s->{default_type}.'::draw_legend_marker($g, $ds, $x, $y)' if $@;

	}

} # End of package GIFgraph::linesPoints

1;
