#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::axestype.pm
#
# $Id: axestype.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
#
#==========================================================================

use strict qw(vars refs subs);
 
package GIFgraph::axestype;

use GIFgraph;
use GIFgraph::utils qw(:all);

use vars qw( @ISA );
@ISA = qw( GIFgraph );

my %Defaults = (
 
	# Set the length for the 'short' ticks on the axes.
 
	'tick_length'	=> 4,
 
	# Do you want ticks to span the entire width of the graph?
 
	'long_ticks'	=> 0,
 
	# Number of ticks for the y axis
 
	'y_tick_number' => 5,
 
	# Skip every nth label. if 1 will print every label on the axes,
	# if 2 will print every second, etc..
 
	'x_label_skip'	=> 1,
	'y_label_skip'	=> 1,
 
	# Draw axes as a box? (otherwise just left and bottom)
 
	'box_axis'		=> 1,
 
	# Use two different axes for the first and second dataset. The first
	# will be displayed using the left axis, the second using the right
	# axis. You cannot use more than two datasets when this option is on.
 
	'two_axes'		=> 0,
 
	# The size of the marker to use in the points and linespoints graphs
	# in pixels
 
	'marker_size'	=> 4,
 
	# The width of the line to use in the lines and linespoints graphs
	# in pixels
 
	'line_width'	=> 2,
 
	# Print values on the axes?
 
	'x_plot_values' => 1,
	'y_plot_values' => 1,
 
	# Space between axis and text
 
	'axis_space'	=> 4,
 
	# Do you want bars to be drawn on top of each other, or side by side?
 
	'overwrite' 	=> 0
);

{
 
	# PUBLIC
	sub plot { # \@data
		my $self = shift;
		my $data = shift;
 
#		 print STDERR "$#$data\n";
		$self->check_data($data);
		$self->setup_coords($data);
		$self->init_graph($self->{graph});
		$self->draw_text($self->{graph});
		$self->draw_axes($self->{graph}, $data);
		$self->draw_data($self->{graph}, $data);
		return $self->{graph}->gif;
	}
 
	sub set_x_label_font { # fontname
		my $self = shift;
		$self->{xlf} = shift;
		$self->set( 'xlfw' => $self->{xlf}->width,
					'xlfh' => $self->{xlf}->height );
	}
	sub set_y_label_font { # fontname
		my $self = shift;
		$self->{ylf} = shift;
		$self->set( 'ylfw' => $self->{ylf}->width,
					'ylfh' => $self->{ylf}->height );
	}
	sub set_x_axis_font { # fontname
		my $self = shift;
		$self->{xaf} = shift;
		$self->set( 'xafw' => $self->{xaf}->width,
					'xafh' => $self->{xaf}->height );
	}
	sub set_y_axis_font { # fontname
		my $self = shift;
		$self->{yaf} = shift;
		$self->set( 'yafw' => $self->{yaf}->width,
					'yafh' => $self->{yaf}->height );
	}
 
	# PRIVATE
	# called on construction, by new
	# use inherited defaults
 
	sub initialise {
		my $self = shift;
 
		$self->defaults( @_ );
 
	foreach (keys %Defaults) {
		$self->set( $_ => $Defaults{$_} );
	}
 
		$self->set_x_label_font(GD::gdSmallFont);
		$self->set_y_label_font(GD::gdSmallFont);
		$self->set_x_axis_font(GD::gdTinyFont);
		$self->set_y_axis_font(GD::gdTinyFont);
 
		$self->{graph} = $self->open_graph();
	}
 
	# inherit check_data from GIFgraph
 
	sub setup_coords {
		my $s = shift;
		my $data = shift;
 
#		 print STDERR "$data\n";
		$s->{two_axes} = 0 if ( $s->{numsets} != 2 || $s->{two_axes} < 0 );
		$s->{two_axes} = 1 if ( $s->{two_axes} > 1 );
		unless ($s->{two_axes}) { delete $s->{y_label2}; }
		unless ( $s->{title} ) { $s->set( 'tfh' => 0 ); }
		unless ( $s->{x_label} ) { $s->set( 'xlfh' => 0 ); }
		if ( ! $s->{y1_label} && $s->{y_label} ) {
			$s->{y1_label} = $s->{y_label};
		}
		$s->set( 'ylfh1' => ($s->{y1_label})?1:0 );
		$s->set( 'ylfh2' => ($s->{y2_label})?1:0 );
		unless ( $s->{x_plot_values} ) { $s->set( 'xafh' => 0 ); }
		unless ( $s->{y_plot_values} ) {
			$s->set( 'yafh' => 0 );
			$s->set( 'yafw' => 0 );
		}
		my $lbl = ($s->{xlfh})?1:0 + ($s->{xafh})?1:0 ;
#		 print STDERR "ss $s->{xlfh}+$s->{xafh}:$lbl*$s->{text_space}\n";
		$s->{bottom} = $s->{gify} - $s->{b_margin} - 1 -
					 ( ( $s->{xlfh} ) ? $s->{xlfh} : 0 ) -
					 ( ( $s->{xafh} ) ? $s->{xafh}: 0) -
					 ( ( $lbl ) ? $lbl*$s->{text_space} : 0 );
		$s->{top} = $s->{t_margin} +
					( ( $s->{tfh} ) ? $s->{tfh} + $s->{text_space} : 0 );
		$s->{top} = $s->{yafh}/2 if ( $s->{top} == 0 );
 
		$s->set_max($data);
 
#		 print STDERR "em $s->{y_max}[0]:$s->{y_max}[1]:$s->{y_max}[2]:$s->{two_axes}\n";
 
		my $ls = $s->{yafw}*length($s->{y_max}[1]);
		$s->{left} = $s->{l_margin} +
					 ( ( $ls ) ? $ls + $s->{axis_space} : 0 ) +
					 ( ( $s->{ylfh1} ) ? $s->{ylfh}+$s->{text_space} : 0 );
		$ls = $s->{yafw}*length($s->{y_max}[2]) if $s->{two_axes};
		$s->{right} = $s->{gifx} - $s->{r_margin} - 1 -
					  $s->{two_axes}* (
						  ( ( $ls ) ? $ls + $s->{axis_space} : 0 ) +
						  ( ( $s->{ylfh2} ) ? $s->{ylfh}+$s->{text_space} : 0 )
					  );
 
		$s->{x_step} = ($s->{right}-$s->{left})/($s->{numpoints} + 2);
 
		if ( ($s->{bottom} - $s->{top}) <= 0 ) {
			die "Vertical Gif size too small";
		}
		if ( ($s->{right} - $s->{left}) <= 0 ) {
			die "Horizontal Gif size too small";
		}
 
		# set up the data colour list if it doesn't exist yet.
		unless ( exists $s->{dclrs} ) {
#			 my @colours=Colour::sorted_list($s->{numpoints} + 1);
#			 shift @colours;
			$s->set( 'dclrs' => [ 'lred', 'lgreen', 'lblue', 'lyellow',
								  'lpurple', 'cyan', 'lorange' ] );
		}
 
		$s->{x_label_skip} = 1 if ( $s->{x_label_skip} < 1 );
		$s->{y_label_skip} = 1 if ( $s->{y_label_skip} < 1 );
		$s->{y_tick_number} = 1 if ( $s->{y_tick_number} < 1 );
	}
 
	# inherit open_graph from GIFgraph
 
	sub draw_text { # GD::Image
		my $s = shift;
		my $g = shift;
 
		if ($s->{tfh}) {
			my $tx = $s->{gifx}/2 - length($s->{title})*$s->{tfw}/2;
			my $ty = $s->{top} - $s->{text_space} - $s->{tfh};
			$g->string($s->{tf}, $tx, $ty, $s->{title}, $s->{tci});
		}
		if ($s->{xlfh}) {
			my $tx = 3*($s->{left}+$s->{right})/4 - 
					 length($s->{x_label})*$s->{xlfw}/2;
			my $ty = $s->{gify} - $s->{xlfh} - $s->{b_margin};
			$g->string($s->{xlf}, $tx, $ty, $s->{x_label}, $s->{lci});
		}
		if ($s->{ylfh1}) {
			my $tx = $s->{l_margin};
			my $ty = ($s->{bottom}+$s->{top})/2 + 
					 length($s->{y1_label})*$s->{ylfw}/2;
			$g->stringUp($s->{ylf}, $tx, $ty, $s->{y1_label}, $s->{lci});
		}
		if ( $s->{two_axes} && $s->{ylfh2} ) {
			my $tx = $s->{gifx} - $s->{ylfh} - $s->{r_margin};
			my $ty = ($s->{bottom}+$s->{top})/2 + 
					 length($s->{y2_label})*$s->{ylfw}/2;
			$g->stringUp($s->{ylf}, $tx, $ty, $s->{y2_label}, $s->{lci});
		}
	}
 
	sub draw_axes { # GD::Image
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my ($l, $r, $b, $t) = ( $s->{left},	$s->{right}, 
								$s->{bottom}, $s->{top} );
 
		$s->draw_ticks( $g, $d );
 
#		 print STDERR "$l: $r: $b: $t: $s->{fgci}, $s->{box_axis}\n";
		if ( $s->{box_axis} ) {
			$g->rectangle($l, $t, $r, $b, $s->{fgci});
			return;
		}
		$g->line($l, $t, $l, $b, $s->{fgci});
		$g->line($l, $b, $r, $b, $s->{fgci});
		$g->line($r, $b, $r, $t, $s->{fgci}) if ( $s->{box_axis} );
	}
 
	sub draw_ticks { # GD::Image, \@data
		my $s = shift;
		my $g = shift;
		my $d = shift;
		my ($a, $t);
 
		foreach $t (0..$s->{y_tick_number}) {
			foreach $a (1..($s->{two_axes}+1)) {
				my $label = $t*$s->{y_max}[$a]/$s->{y_tick_number};
				my ($x, $y) = $s->val_to_pixel( ($a-1)*($s->{numpoints}+2) , 
												$label, $a );
				if ($s->{long_ticks}) {
					$g->line( $x, $y, $x+$s->{right}-$s->{left}, 
							  $y, $s->{fgci} )
						unless ($a-1);
				} else {
					$g->line( $x, $y, $x+(3-2*$a)*$s->{tick_length}, 
							  $y, $s->{fgci} );
				}
				next if ( $t%($s->{y_label_skip}) || ! $s->{y_plot_values} );
				$x -=	(2-$a)*length($label)*$s->{yafw} + 
						(3-2*$a)*$s->{axis_space};
				$y -= $s->{yafh}/2;
				$g->string($s->{yaf}, $x, $y, $label, $s->{alci});
			}
		}
		return unless ( $s->{x_plot_values} );
		for (0.. $s->{numpoints}) {
			next if ( $_%($s->{x_label_skip}) && $_ != $s->{numpoints} );
			my ($x, $y) = $s->val_to_pixel($_ + 1, 0, 1);
			$x -= $s->{xafw}*length( $$d[0][$_] )/2;
			$y = $s->{bottom} + $s->{text_space}/2;
			$g->string($s->{xaf}, $x, $y, $$d[0][$_], $s->{alci});
		}
	}
 
	# draw_data is in sub classes
 
	# Figure out the maximum values for the vertical exes, and calculate
	# a more or less sensible number for the tops.
 
	sub set_max {
		my $s = shift;
		my $d = shift;
		my $jump = 0;
 
		if ( $s->{y_max_value} ) {
			$s->{y_max}[1] = $s->{y_max_value};
			$s->{y_step}[1] = ($s->{bottom}-$s->{top})/$s->{y_max}[1];
			$s->{y_max}[2] = $s->{y_max_value};
			$s->{y_step}[2] = ($s->{bottom}-$s->{top})/$s->{y_max}[2];
			$jump=1;
		}
		if ( $s->{y1_max_value} ) {
			$s->{y_max}[1] = $s->{y1_max_value};
			$s->{y_step}[1] = ($s->{bottom}-$s->{top})/$s->{y_max}[1];
			$s->{y_max}[2] = $s->{y1_max_value};
			$s->{y_step}[2] = ($s->{bottom}-$s->{top})/$s->{y_max}[1];
			$jump = 1;
		}
		if ( $s->{y2_max_value} ) {
			$s->{y_max}[2] = $s->{y2_max_value};
			$s->{y_step}[2] = ($s->{bottom}-$s->{top})/$s->{y_max}[2];
			$jump = 1;
		}
		if ($jump) {
			if ( $s->{two_axes} ) {
				die "Maximum for y1 too small\n"
					if ( $s->{y_max}[1] < get_max_y(@{$$d[1]}) );
				die "Maximum for y2 too small\n"
					if ( $s->{y_max}[2] < get_max_y(@{$$d[2]}) );
			} else {
				die "Maximum for y too small\n"
					if ( $s->{y_max}[1] < get_max_y(@{$$d[1]}) );
			}
			return;
		}
		if ( $s->{two_axes} ) {
			for (1..2) {
				$s->{y_max}[$_] = up_bound( get_max_y(@{$$d[$_]}) );
				$s->{y_step}[$_] = ($s->{bottom}-$s->{top})/$s->{y_max}[$_];
			}
		} else {
			$s->{y_max}[1] = up_bound( get_max_y_all($d) );
			$s->{y_step}[1] = ($s->{bottom}-$s->{top})/$s->{y_max}[1];
		}
	}
 
	# return maximum value from an array
 
	sub get_max_y { # array
		my @array=sort by_value @_;
		return $array[$#array];
		sub by_value { $a <=> $b; }
	}
 
	# get maximum y value from the whole data set
 
	sub get_max_y_all { # \@data
		my $d = shift;
		my $max = 0;
		for ( 1..$#$d ) {
			$max = _max( $max, get_max_y(@{$$d[$_]}) );
		}
		return $max;
	}
 
	# Return a more or less nice top axis value, given a highest value
	sub up_bound { # value
		my $val = shift;
		my $dum = 10**( int( log($val)/log(10) ) );
		return ( int ( $val / $dum ) + 1 ) * $dum;
	}
 
	# Pick a marker type
 
	sub pick_marker { # number
		my $s = shift;
		if ( exists $s->{markers} ) {
			return $s->{markers}[ $_[0] % (1+$#{$s->{markers}}) -1 ];
		}
		return $_[0]%8;
	}
 
	# Draw a marker
 
	sub marker { # $graph, $xp, $yp, type (1-7), $colourindex
		my $self = shift;
		my ($graph, $xp, $yp, $mtype, $mclr)=@_;
	#	 print STDERR "Marker: $xp, $yp, type: $mtype\n";
		my $l = $xp - $self->{marker_size};
		my $r = $xp + $self->{marker_size};
		my $b = $yp + $self->{marker_size};
		my $t = $yp - $self->{marker_size};
		MARKER: {
			($mtype == 1) && do { # Square, filled
				$graph->filledRectangle( $l, $t, $r, $b, $mclr );
				last MARKER;
			};
			($mtype == 2) && do { # Square, open
				$graph->rectangle( $l, $t, $r, $b, $mclr );
				last MARKER;
			};
			($mtype == 3) && do { # Cross, horizontal
				$graph->line( $l, $yp, $r, $yp, $mclr );
				$graph->line( $xp, $t, $xp, $b, $mclr );
				last MARKER;
			};
			($mtype == 4) && do { # Cross, diagonal
				$graph->line( $l, $b, $r, $t, $mclr );
				$graph->line( $l, $t, $r, $b, $mclr );
				last MARKER;
			};
			($mtype == 5) && do { # Diamond, filled
				$graph->line( $l, $yp, $xp, $t, $mclr );
				$graph->line( $xp, $t, $r, $yp, $mclr );
				$graph->line( $r, $yp, $xp, $b, $mclr );
				$graph->line( $xp, $b, $l, $yp, $mclr );
				$graph->fill( $xp, $yp, $mclr );
				last MARKER;
			};
			($mtype == 6) && do { # Diamond, open
				$graph->line( $l, $yp, $xp, $t, $mclr );
				$graph->line( $xp, $t, $r, $yp, $mclr );
				$graph->line( $r, $yp, $xp, $b, $mclr );
				$graph->line( $xp, $b, $l, $yp, $mclr );
				last MARKER;
			};
			($mtype == 7) && do { # Circle, filled
				$graph->arc( $xp, $yp, 2*$self->{marker_size},
							 2*$self->{marker_size}, 0, 360, $mclr );
				$graph->fill( $xp, $yp, $mclr );
				last MARKER;
			};
			($mtype == 8) && do { # Circle, open
				$graph->arc( $xp, $yp, 2*$self->{marker_size},
							 2*$self->{marker_size}, 0, 360, $mclr );
				last MARKER;
			};
		}
	}
 
	# Convert value coordinates to pixel coordinates on the canvas.
 
	sub val_to_pixel {	# ($x, $y, $i) in real coords ($Dataspace), 
						# return [x, y, $i] in pixel coords
		my $s = shift;
		my ($x, $y, $i)=@_;
		my ($xs, $ys);
		if ( $s->{two_axes} && $i >= 2 ) {
			$ys = $s->{y_step}[2];
		} else {
			$ys = $s->{y_step}[1];
		}
#		 print STDERR "val_to_pixel: $x, $y, $i\n";
		return ( _round($s->{left}+$x*$s->{x_step}),
				 _round($s->{bottom}-$y*$ys) );
	}
 
} # End of package GIFgraph::axestype
 
1;
