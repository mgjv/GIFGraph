#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#			   Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::axestype.pm
#
# $Id: axestype.pm,v 1.1.1.5 1999-10-10 12:37:15 mgjv Exp $
#
#==========================================================================

package GIFgraph::axestype;

use strict qw(vars refs subs);
 
use GIFgraph;
use GIFgraph::utils qw(:all);

@GIFgraph::axestype::ISA = qw( GIFgraph );

my %Defaults = (
 
	# Set the length for the 'short' ticks on the axes.
 
	tick_length			=> 4,
 
	# Do you want ticks to span the entire width of the graph?
 
	long_ticks			=> 0,
 
	# Number of ticks for the y axis
 
	y_tick_number		=> 5,
 
	# Skip every nth label. if 1 will print every label on the axes,
	# if 2 will print every second, etc..
 
	x_label_skip		=> 1,
	y_label_skip		=> 1,

	# Do we want ticks on the x axis?

	x_ticks				=> 1,
 
	# Draw axes as a box? (otherwise just left and bottom)
 
	box_axis			=> 1,
 
	# Use two different axes for the first and second dataset. The first
	# will be displayed using the left axis, the second using the right
	# axis. You cannot use more than two datasets when this option is on.
 
	two_axes			=> 0,
 
	# Print values on the axes?
 
	x_plot_values 		=> 1,
	y_plot_values 		=> 1,
 
	# Space between axis and text
 
	axis_space			=> 4,
 
	# Do you want bars to be drawn on top of each other, or side by side?
 
	overwrite 			=> 0,

	# Draw the zero axis in the graph in case there are negative values

	zero_axis			=>	1,

	# Draw the zero axis, but do not draw the bottom axis, in case
	# box-axis == 0
	# This also moves the x axis labels to the zero axis
	zero_axis_only		=>	1,

	# Size of the legend markers

	legend_marker_height	=> 8,
	legend_marker_width		=> 12,
	legend_spacing			=> 4,
	legend_placement		=> 'BC',		# '[B][LCR]'

	# Format of the numbers on the y axis

	y_number_format			=> undef,
);

{
 
	# PUBLIC
	sub plot($) # (\@data)
	{
		my $self = shift;
		my $data = shift;
 
		$self->check_data($data);
		$self->setup_legend();
		$self->setup_coords($data);
		$self->init_graph($self->{graph});
		$self->draw_text($self->{graph});
		$self->draw_axes($self->{graph}, $data);
		$self->draw_ticks($self->{graph}, $data);
		$self->draw_data($self->{graph}, $data);
		$self->draw_legend($self->{graph});

		return $self->{graph}->gif;
	}

	sub set_x_label_font($) # (fontname)
	{
		my $self = shift;
		$self->{xlf} = shift;
		$self->set( 
			xlfw => $self->{xlf}->width,
			xlfh => $self->{xlf}->height,
		);
	}
	sub set_y_label_font($) # (fontname)
	{
		my $self = shift;
		$self->{ylf} = shift;
		$self->set( 
			ylfw => $self->{ylf}->width,
			ylfh => $self->{ylf}->height,
		);
	}
	sub set_x_axis_font($) # (fontname)
	{
		my $self = shift;
		$self->{xaf} = shift;
		$self->set( 
			xafw => $self->{xaf}->width,
			xafh => $self->{xaf}->height,
		);
	}
	sub set_y_axis_font($) # (fontname)
	{
		my $self = shift;
		$self->{yaf} = shift;
		$self->set( 
			yafw => $self->{yaf}->width,
			yafh => $self->{yaf}->height,
		);
	}

	sub set_legend(@) # List of legend keys
	{
		my $self = shift;
		$self->set( legend => [@_]);
	}

	sub set_legend_font($) # (font name)
	{
		my $self = shift;
		$self->{lgf} = shift;
		$self->set( 
			lgfw => $self->{lgf}->width,
			lgfh => $self->{lgf}->height,
		);
	}
 
	# PRIVATE
	# called on construction, by new
	# use inherited defaults
 
	sub initialise()
	{
		my $self = shift;
 
		$self->SUPER::initialise();
 
		my $key;
		foreach $key (keys %Defaults) 
		{
			$self->set( $key => $Defaults{$key} );
		}
 
		$self->set_x_label_font(GD::gdSmallFont);
		$self->set_y_label_font(GD::gdSmallFont);
		$self->set_x_axis_font(GD::gdTinyFont);
		$self->set_y_axis_font(GD::gdTinyFont);
		$self->set_legend_font(GD::gdTinyFont);
	}
 
	# inherit check_data from GIFgraph
 
	sub setup_coords($)
	{
		my $s = shift;
		my $data = shift;

		# Do some sanity checks
		$s->{two_axes} = 0 if ( $s->{numsets} != 2 || $s->{two_axes} < 0 );
		$s->{two_axes} = 1 if ( $s->{two_axes} > 1 );

		delete $s->{y_label2} unless ($s->{two_axes});

		# Set some heights for text
		$s->set( tfh => 0 ) unless ( $s->{title} );
		$s->set( xlfh => 0 ) unless ( $s->{x_label} );

		if ( ! $s->{y1_label} && $s->{y_label} ) 
		{
			$s->{y1_label} = $s->{y_label};
		}

		$s->set( ylfh1 => $s->{y1_label} ? 1 : 0 );
		$s->set( ylfh2 => $s->{y2_label} ? 1 : 0 );

		unless ( $s->{x_plot_values} ) 
		{ 
			$s->set( xafh => 0 ); 
		}
		unless ( $s->{y_plot_values} ) 
		{
			$s->set( yafh => 0 );
			$s->set( yafw => 0 );
		}

		my $lbl = ($s->{xlfh} ? 1 : 0) + ($s->{xafh} ? 1 : 0);

		# calculate the top and bottom of the bounding box for the graph
		$s->{bottom} = 
			$s->{gify} - $s->{b_margin} - 1 -
			( $s->{xlfh} ? $s->{xlfh} : 0 ) -
			( $s->{xafh} ? $s->{xafh}: 0) -
			( $lbl ? $lbl * $s->{text_space} : 0 )
		;

		$s->{top} = $s->{t_margin} +
					( ( $s->{tfh} ) ? $s->{tfh} + $s->{text_space} : 0 );
		$s->{top} = $s->{yafh}/2 if ( $s->{top} == 0 );
 
		$s->set_max_min($data);

		# Create the labels for the y_axes, and calculate the max length

		$s->create_y_labels();

		# calculate the left and right of the bounding box for the graph
		my $ls = $s->{yafw} * $s->{y_label_len}[1];
		$s->{left} = $s->{l_margin} +
					 ( ( $ls ) ? $ls + $s->{axis_space} : 0 ) +
					 ( ( $s->{ylfh1} ) ? $s->{ylfh}+$s->{text_space} : 0 );

		$ls = $s->{yafw} * $s->{y_label_len}[2] if $s->{two_axes};
		$s->{right} = $s->{gifx} - $s->{r_margin} - 1 -
					  $s->{two_axes}* (
						  ( ( $ls ) ? $ls + $s->{axis_space} : 0 ) +
						  ( ( $s->{ylfh2} ) ? $s->{ylfh}+$s->{text_space} : 0 )
					  );
 
		# calculate the step size for x data
		$s->{x_step} = ($s->{right}-$s->{left})/($s->{numpoints} + 2);
 
		# get the zero axis level
		my $dum;
		($dum, $s->{zeropoint}) = $s->val_to_pixel(0, 0, 1);

		# Check the size
		die "Vertical Gif size too small"
			if ( ($s->{bottom} - $s->{top}) <= 0 );

		die "Horizontal Gif size too small"	
			if ( ($s->{right} - $s->{left}) <= 0 );
 
		# set up the data colour list if it doesn't exist yet.
		$s->set( 
			dclrs => [ qw( lred lgreen lblue lyellow lpurple cyan lorange )] 
		) unless ( exists $s->{dclrs} );
 
		# More sanity checks
		$s->{x_label_skip} = 1 if ( $s->{x_label_skip} < 1 );
		$s->{y_label_skip} = 1 if ( $s->{y_label_skip} < 1 );
		$s->{y_tick_number} = 1 if ( $s->{y_tick_number} < 1 );
	}

	sub create_y_labels
	{
		my $s = shift;

		$s->{y_label_len}[1] = 0;
		$s->{y_label_len}[2] = 0;

		my $t;
		foreach $t (0..$s->{y_tick_number})
		{
			my $a;
			foreach $a (1 .. ($s->{two_axes} + 1))
			{
				my $label = 
					$s->{y_min}[$a] +
					$t *
					($s->{y_max}[$a] - $s->{y_min}[$a])/$s->{y_tick_number};
				
				$label = sprintf($s->{y_number_format}, $label)
					if (defined($s->{y_number_format}));
				
				my $len = length($label);

				$s->{y_labels}[$a][$t] = $label;

				($len > $s->{y_label_len}[$a]) and 
					$s->{y_label_len}[$a] = $len;
			}
		}
	}
 
	# inherit open_graph from GIFgraph
 
	sub draw_text($) # GD::Image
	{
		my $s = shift;
		my $g = shift;
 
		# Title
		if ($s->{tfh}) 
		{
			my $tx = 
				$s->{left} + 
				($s->{right} - $s->{left})/2 - 
				length($s->{title}) * $s->{tfw}/2;
			my $ty = $s->{top} - $s->{text_space} - $s->{tfh};

			$g->string($s->{tf}, $tx, $ty, $s->{title}, $s->{tci});
		}

		# X label
		if ($s->{xlfh}) 
		{
			# TODO Need more control for placement
			my $tx = 
				3 * ($s->{left}+$s->{right})/4 - 
				length($s->{x_label}) * $s->{xlfw}/2;
			my $ty = $s->{gify} - $s->{xlfh} - $s->{b_margin};

			$g->string($s->{xlf}, $tx, $ty, $s->{x_label}, $s->{lci});
		}

		# Y labels
		if ($s->{ylfh1}) 
		{
			# TODO Need more control for placement
			my $tx = $s->{l_margin};
			my $ty = 
				($s->{bottom}+$s->{top})/2 + 
				length($s->{y1_label}) * $s->{ylfw}/2;

			$g->stringUp($s->{ylf}, $tx, $ty, $s->{y1_label}, $s->{lci});
		}
		if ( $s->{two_axes} && $s->{ylfh2} ) 
		{
			# TODO Need more control for placement
			my $tx = $s->{gifx} - $s->{ylfh} - $s->{r_margin};
			my $ty = 
				($s->{bottom} + $s->{top})/2 + 
				length($s->{y2_label}) * $s->{ylfw}/2;

			$g->stringUp($s->{ylf}, $tx, $ty, $s->{y2_label}, $s->{lci});
		}
	}
 
	sub draw_axes($) # GD::Image
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;

		my ($l, $r, $b, $t) = 
			( $s->{left}, $s->{right}, $s->{bottom}, $s->{top} );
 
		if ( $s->{box_axis} ) 
		{
			$g->rectangle($l, $t, $r, $b, $s->{fgci});
		}
		else
		{
			$g->line($l, $t, $l, $b, $s->{fgci});
			$g->line($l, $b, $r, $b, $s->{fgci}) 
				unless ($s->{zero_axis_only});
			$g->line($r, $b, $r, $t, $s->{fgci}) 
				if ($s->{two_axes});
		}

		if ($s->{zero_axis} or $s->{zero_axis_only})
		{
			my ($x, $y) = $s->val_to_pixel(0, 0, 1);
			$g->line($l, $y, $r, $y, $s->{fgci});
		}
	}
 
	sub draw_ticks($$) # GD::Image, \@data
	{
		my $s = shift;
		my $g = shift;
		my $d = shift;

		#
		# Ticks and values for y axes
		#
		my $t;
		foreach $t (0..$s->{y_tick_number}) 
		{
			my $a;
			foreach $a (1 .. ($s->{two_axes} + 1)) 
			{
				my $label = 
					$s->{y_labels}[$a][$t];
			#		$s->{y_min}[$a] + 
			#		$t * 
			#		($s->{y_max}[$a] - $s->{y_min}[$a])/$s->{y_tick_number};
				
				my ($x, $y) = $s->val_to_pixel( 
					($a-1) * ($s->{numpoints} + 2), 
					$label, 
					$a 
				);

				if ($s->{long_ticks}) 
				{
					$g->line( 
						$x, $y, 
						$x + $s->{right} - $s->{left}, $y, 
						$s->{fgci} 
					) unless ($a-1);
				} 
				else 
				{
					$g->line( 
						$x, $y, 
						$x + (3-2*$a)*$s->{tick_length}, $y, 
						$s->{fgci} 
					);
				}

				next 
					if ( $t%($s->{y_label_skip}) || ! $s->{y_plot_values} );

				$x -=
					(2-$a) * length($label) * $s->{yafw} + 
					(3 - 2 * $a) * $s->{axis_space};
				$y -= $s->{yafh}/2;
				$g->string($s->{yaf}, $x, $y, $label, $s->{alci});
			}
		}

		return 
			unless ( $s->{x_plot_values} );

		#
		# Ticks and values for X axis
		#
		my $i;
		for $i (0.. $s->{numpoints}) 
		{
			my ($x, $y) = $s->val_to_pixel($i + 1, 0, 1);

			$y = $s->{bottom} unless ($s->{zero_axis_only});

			if ($s->{x_ticks})
			{
				if ($s->{long_ticks})
				{
					$g->line( 
						$x, $s->{bottom}, $x, 
						$s->{top},
						$s->{fgci} 
					);
				}
				else
				{
					$g->line( $x, $y, $x, $y - $s->{tick_length},
							  $s->{fgci} );
				}
			}

			next 
				if ( $i%($s->{x_label_skip}) and $i != $s->{numpoints} );

			$x -= $s->{xafw} * length($$d[0][$i])/2;
			my $yt = $y + $s->{text_space}/2;
			$g->string($s->{xaf}, $x, $yt, $$d[0][$i], $s->{alci});
		}
	}
 
	# draw_data is in sub classes
	sub draw_data()
	{
		# ABSTRACT
		my $s = shift;
		$s->die_abstract( "sub draw_data missing, ");
	}
 
	# Figure out the maximum values for the vertical exes, and calculate
	# a more or less sensible number for the tops.

	sub set_max_min($)
	{
		my $s = shift;
		my $d = shift;

		my @max_min;

		# First, calculate some decent values

		if ( $s->{two_axes} ) 
		{
			my $i;
			for $i (1..2) 
			{
				$s->{y_max}[$i] = up_bound( get_max_y(@{$$d[$i]}) );
				$s->{y_min}[$i] = down_bound( get_min_y(@{$$d[$i]}) );
			}
		} 
		else 
		{
			@max_min = $s->get_max_min_y_all($d);
			$s->{y_max}[1] = up_bound( $max_min[0] );
			$s->{y_min}[1] = down_bound( $max_min[1] );
		}

		# Make sure bars and area always have a zero offset

		if ($s->{y_min}[1] >= 0)
		{
			if (ref($s) eq 'GIFgraph::bars' or ref($s) eq 'GIFgraph::area')
			{
				$s->{y_min}[1] = 0; 
			}
		}

		# Overwrite these with any user supplied ones

		if ( $s->{y_min_value} ) 
		{
			my $i;
			for $i (1 .. 2)
			{
				$s->{y_min}[$i] = $s->{y_min_value};
			}
		}

		if ( $s->{y_max_value} ) 
		{
			my $i;
			for $i (1 .. 2)
			{
				$s->{y_max}[$i] = $s->{y_max_value};
			}
		}

		$s->{y_min}[1] = $s->{y1_min_value}
			if ( $s->{y1_min_value} );

		$s->{y_max}[1] = $s->{y1_max_value}
			if ( $s->{y1_max_value} );

		$s->{y_min}[2] = $s->{y2_min_value}
			if ( $s->{y2_min_value} );

		$s->{y_max}[2] = $s->{y2_max_value}
			if ( $s->{y2_max_value} );

		# Check to see if we have sensible values

		if ( $s->{two_axes} ) 
		{
			my $i;
			for $i (1 .. 2)
			{
				die "Minimum for y" . $i . " too large\n"
					if ( $s->{y_min}[$i] > get_min_y(@{$$d[$i]}) );
				die "Maximum for y" . $i . " too small\n"
					if ( $s->{y_max}[$i] < get_max_y(@{$$d[$i]}) );
			}
		} 
		else 
		{
			die "Minimum for y too large\n"
				if ( $s->{y_min}[1] > $max_min[1] );
			die "Maximum for y too small\n"
				if ( $s->{y_max}[1] < $max_min[0] );
		}
	}
 
	# return maximum value from an array
 
	sub get_max_y(@) # array
	{
		my $max = undef;

		my $i;
		foreach $i (@_) 
		{ 
			next if (!defined($i));
			$max = (defined($max) && $max >= $i) ? $max : $i; 
		}

		return $max;
	}

	sub get_min_y(@) # array
	{
		my $min = undef;

		my $i;
		foreach $i (@_) 
		{ 
			next if (!defined($i));
			$min = ( defined($min) and $min <= $i) ? $min : $i;
		}

		return $min;
	}
 
	# get maximum y value from the whole data set
 
	sub get_max_min_y_all($) # \@data
	{
		my $s = shift;
		my $d = shift;

		my $max = undef;
		my $min = undef;

		if ($s->{overwrite} == 2) 
		{
			my $i;
			for $i (0..$s->{numpoints}) 
			{
				my $sum = 0;

				my $j;
				for $j (1..$s->{numsets}) 
				{ 
					$sum += $$d[$j][$i]; 
				}

				$max = _max( $max, $sum );
				$min = _min( $min, $sum );
			}
		}
		else 
		{
			my $i;
			for $i ( 1 .. $s->{numsets} ) 
			{
				$max = _max( $max, get_max_y(@{$$d[$i]}) );
				$min = _min( $min, get_min_y(@{$$d[$i]}) );
			}
		}

		return ($max, $min);
	}
 
	# Return a more or less nice top axis value, given a value
	sub _bound($$) # value, offset
	{
		my $val = shift;
		my $offset = shift;

		my $ss = undef;
		($val, $ss) = ($val >= 0) ? ($val, 1) : (-$val, -1);

		return 0
			if ($val == 0);

		my $exp = 10**( int(log($val)/log(10)) );
		my $ret = (int($val/$exp) + $offset) * $exp;

		return $ss * $ret;
	}

	sub up_bound($)
	{
		my $val = shift;

		my $offset = ($val < 0) ? -1 : 1;

		return _bound($val, $offset);
	}

	sub down_bound($)
	{
		my $val = shift;

		my $offset = ($val < 0) ? 1 : -1;

		return _bound($val, $offset);
	}

	# Convert value coordinates to pixel coordinates on the canvas.
 
	sub val_to_pixel($$$)	# ($x, $y, $i) in real coords ($Dataspace), 
	{						# return [x, y] in pixel coords
		my $s = shift;
		my ($x, $y, $i) = @_;

		my $y_min = 
			($s->{two_axes} && $i == 2) ? $s->{y_min}[2] : $s->{y_min}[1];

		my $y_max = 
			($s->{two_axes} && $i == 2) ? $s->{y_max}[2] : $s->{y_max}[1];

		my $y_step = ($s->{bottom} - $s->{top})/($y_max - $y_min);

		return ( 
			_round( $s->{left} + $x * $s->{x_step} ),
			_round( $s->{bottom} - ($y - $y_min) * $y_step )
		);
	}

	#
	# Legend
	#

	sub setup_legend()
	{
		my $s = shift;

		return unless defined($s->{legend});

		my $maxlen = 0;
		my $num = 0;

		my $legend;
		foreach $legend (@{$s->{legend}})
		{
			if (defined($legend) and $legend ne "")
			{
				my $len = length($legend);
				$maxlen = ($maxlen > $len) ? $maxlen : $len;
				$num++;
			}
			last if ($num >= $s->{numsets});
		}

		$s->{lg_num} = $num;

		# calculate the height and width of each element

		my $text_width = $maxlen * $s->{lgfw};
		my $legend_height = _max($s->{lgfh}, $s->{legend_marker_height});

		$s->{lg_el_width} = 
			$text_width + $s->{legend_marker_width} + 
			3 * $s->{legend_spacing};
		$s->{lg_el_height} = $legend_height + 2 * $s->{legend_spacing};

		my ($lg_pos, $lg_align) = split(//, $s->{legend_placement});

		if ($lg_pos eq 'R')
		{
			# Always work in one column
			$s->{lg_cols} = 1;
			$s->{lg_rows} = $num;

			# Just for completeness, might use this in later versions
			$s->{lg_x_size} = $s->{lg_cols} * $s->{lg_el_width};
			$s->{lg_y_size} = $s->{lg_rows} * $s->{lg_el_height};

			# Adjust the right margin for the rest of the graph
			$s->{r_margin} += $s->{lg_x_size};

			# Set the x starting point
			$s->{lg_xs} = $s->{gifx} - $s->{r_margin};

			# Set the y starting point, depending on alignment
			if ($lg_align eq 'T')
			{
				$s->{lg_ys} = $s->{t_margin};
			}
			elsif ($lg_align eq 'B')
			{
				$s->{lg_ys} = $s->{gify} - $s->{b_margin} - $s->{lg_y_size};
			}
			else # default 'C'
			{
				my $height = $s->{gify} - $s->{t_margin} - $s->{b_margin};

				$s->{lg_ys} = 
					int($s->{t_margin} + $height/2 - $s->{lg_y_size}/2) ;
			}
		}
		else # 'B' is the default
		{
			# What width can we use
			my $width = $s->{gifx} - $s->{l_margin} - $s->{r_margin};

			(!defined($s->{lg_cols})) and 
				$s->{lg_cols} = int($width/$s->{lg_el_width});
			
			$s->{lg_cols} = _min($s->{lg_cols}, $num);

			$s->{lg_rows} = 
				int($num/$s->{lg_cols}) + (($num % $s->{lg_cols}) ? 1 : 0);

			$s->{lg_x_size} = $s->{lg_cols} * $s->{lg_el_width};
			$s->{lg_y_size} = $s->{lg_rows} * $s->{lg_el_height};

			# Adjust the bottom margin for the rest of the graph
			$s->{b_margin} += $s->{lg_y_size};

			# Set the y starting point
			$s->{lg_ys} = $s->{gify} - $s->{b_margin};

			# Set the x starting point, depending on alignment
			if ($lg_align eq 'R')
			{
				$s->{lg_xs} = $s->{gifx} - $s->{r_margin} - $s->{lg_x_size};
			}
			elsif ($lg_align eq 'L')
			{
				$s->{lg_xs} = $s->{l_margin};
			}
			else # default 'C'
			{
				$s->{lg_xs} =  
					int($s->{l_margin} + $width/2 - $s->{lg_x_size}/2);
			}

		}
	}

	sub draw_legend($) # (GD::Image)
	{
		my $s = shift;
		my $g = shift;

		return unless defined($s->{legend});

		my $xl = $s->{lg_xs} + $s->{legend_spacing};
		my $y = $s->{lg_ys} + $s->{legend_spacing} - 1;
		
		my $i = 0;
		my $row = 1;
		my $x = $xl;	# start position of current element

		my $legend;
		foreach $legend (@{$s->{legend}})
		{
			$i++;
			last if ($i > $s->{numsets});

			my $xe = $x;	# position within an element

			next if (!defined($legend) or $legend eq "");

			$s->draw_legend_marker($g, $i, $xe, $y);

			$xe += $s->{legend_marker_width} + $s->{legend_spacing};
			my $ys = int($y + $s->{lg_el_height}/2 - $s->{lgfh}/2);

			$g->string($s->{lgf}, $xe, $ys, $legend, $s->{fgci});

			$x += $s->{lg_el_width};

			if (++$row > $s->{lg_cols})
			{
				$row = 1;
				$y += $s->{lg_el_height};
				$x = $xl;
			}
		}
	}

	# This will be virtual; every sub class should define their own
	# if this one doesn't suffice
	sub draw_legend_marker($$$$) # (GD::Image, data_set_number, x, y)
	{
		my $s = shift;
		my $g = shift;
		my $n = shift;
		my $x = shift;
		my $y = shift;

		my $ci = $s->set_clr( $g, $s->pick_data_clr($n) );

		$y += int($s->{lg_el_height}/2 - $s->{legend_marker_height}/2);

		$g->filledRectangle(
			$x, $y, 
			$x + $s->{legend_marker_width}, $y + $s->{legend_marker_height},
			$ci
		);

		$g->rectangle(
			$x, $y, 
			$x + $s->{legend_marker_width}, $y + $s->{legend_marker_height},
			$s->{acci}
		);

	}

} # End of package GIFgraph::axestype
 
1;
