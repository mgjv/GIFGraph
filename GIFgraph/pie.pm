#==========================================================================
#			   Copyright (c) 1995 Martien Verbruggen
#			   Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::pie.pm
#
# $Id: pie.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
#==========================================================================

use strict qw(vars refs subs);

package GIFgraph::pie;

use GIFgraph;
use GIFgraph::utils qw(:all);
use GIFgraph::colour qw(:colours :lists);

use vars qw( @ISA );
@ISA = qw( GIFgraph );

my %Defaults = (
 
	# Set the height of the pie.
	# Because of the dependency of this on runtime information, this
	# is being set in GIFgraph::pie::initialise
 
	#   'pie_height' => _round(0.1*${'gifx'}),
 
	# 3D pie?
 
	'3d'         => 1,
 
	# The angle at which to start the first data set
	# 0 is to the right
 
	'start_angle' => 0,
);

{
 
	# PUBLIC methods, documented in pod
	sub plot { # \@data
		my $self = shift;
		my $data = shift;
#		 print STDERR "Plot Pie: $data, @$data\n";
		$self->check_data($data);
		$self->setup_coords();
		my $g = $self->open_graph();
		$self->init_graph($g);
		$self->draw_text($g);
		$self->draw_pie($g);
		$self->draw_data($data, $g);
		return $g->gif;
	}
 
	sub set_label_font { # fontname
		my $self = shift;
		$self->{lf} = shift;
		$self->set( 'lfw' => $self->{lf}->width,
					'lfh' => $self->{lf}->height );
	}
 
	sub set_value_font { # fontname
		my $self = shift;
		$self->{vf} = shift;
		$self->set( 'vfw' => $self->{vf}->width,
					'vfh' => $self->{vf}->height );
	}
 
	# Inherit defaults() from GIFgraph
 
	# PRIVATE
	# called on construction by new.
	sub initialise { # key => value, key => value, etc..
		my $self = shift;
 
		$self->defaults();
 
	foreach (keys %Defaults) {
		$self->set( $_ => $Defaults{$_} );
	}
 
		$self->set( 'pie_height' => _round(0.1*$self->{gify}) );
 
		$self->set_value_font(GD::gdTinyFont);
		$self->set_label_font(GD::gdSmallFont);
 
	}
 
	# inherit checkdata from GIFgraph
 
	# Setup the coordinate system and colours, calculate the
	# relative axis coordinates in respect to the gif size.
 
	sub setup_coords {
		my $s = shift;
 
		# Make sure we're not reserving space we don't need.
		unless ( $s->{title} ) { $s->set( 'tfh' => 0 ); }
		unless ( $s->{label} ) { $s->set( 'lfh' => 0 ); }
		if ( $s->{pie_height} <= 0 ) { $s->set( '3d' => 0 ); }
		unless ( $s->{'3d'} ) { $s->set( 'pie_height' => 0 ); }
 
		$s->{bottom} = $s->{gify} - $s->{pie_height} - $s->{b_margin} -
					 ( ($s->{lfh}) ? $s->{lfh} + $s->{text_space} : 0 );
		$s->{top} = $s->{t_margin} +
				  ( ($s->{tfh}) ? $s->{tfh} + $s->{text_space} : 0 );
		$s->{left} = $s->{l_margin};
		$s->{right} = $s->{gifx} - $s->{r_margin};
		( $s->{w}, $s->{h} ) = ( $s->{right}-$s->{left}, 
								 $s->{bottom}-$s->{top} );
		( $s->{xc}, $s->{yc} ) = ( ($s->{right}+$s->{left})/2, 
								   ($s->{bottom}+$s->{top})/2 );
 
		if ( ($s->{bottom} - $s->{top}) <= 0 ) {
			die "Vertical Gif size too small";
		}
		if ( ($s->{right} - $s->{left}) <= 0 ) {
			die "Horizontal Gif size too small";
		}
		# set up the data colour list if it doesn't exist yet.
		unless ( exists $s->{dclrs} ) {
#			 my @colours=_sorted_list($s->{numpoints} + 1);
#			 shift @colours;
			$s->set( 'dclrs' => [ 'lred', 'lgreen', 'lblue', 'lyellow',
								  'lpurple', 'cyan', 'lorange' ] );
		}
	}
 
	# inherit open_graph from GIFgraph
 
	# Put the text on the canvas.
	sub draw_text { # GD::Image
		my $s = shift;
		my $g = shift;
 
		if ( $s->{tfh} ) {
			my $tx = $s->{xc} - length($s->{title})*$s->{tfw}/2;
			$g->string($s->{tf}, $tx, $s->{t_margin}, $s->{title}, $s->{tci});
		}
		if ( $s->{lfh} ) {
			my $tx = $s->{xc} - length($s->{label})*$s->{lfw}/2;
			my $ty = $s->{gify} - $s->{b_margin} - $s->{lfh};
			$g->string($s->{lf}, $tx, $ty, $s->{label}, $s->{lci});
		}
	}
 
	# draw the pie, without the data slices
 
	sub draw_pie { # GD::Image
		my $s = shift;
		my $g = shift;
		my $left = $s->{xc} - $s->{w}/2;
		$g->arc($s->{xc}, $s->{yc}, $s->{w}, $s->{h},
				0, 360, $s->{acci});
		$g->arc($s->{xc}, $s->{yc} + $s->{pie_height}, $s->{w}, $s->{h},
				0, 180, $s->{acci});
		$g->line($left, $s->{yc},
				 $left, $s->{yc} + $s->{pie_height}, $s->{acci});
		$g->line($left+$s->{w}, $s->{yc},
				 $left+$s->{w}, $s->{yc} + $s->{pie_height}, $s->{acci});
	}
 
	# Draw the data slices
 
	sub draw_data { # \@data, GD::Image
		my $s = shift;
		my $data = shift;
		my $g = shift;
		my $total = 0;
		my $j=1; # for now, only one pie..
 
		for (0..$s->{numpoints}) { $total += $data->[$j][$_]; }
		die "no Total" unless $total;
 
		my $ac = $s->{acci};
		my $pb = $s->{start_angle};
		my $val = 0;
		for ( 0..$s->{numpoints} ) {
			my $dc = $s->set_clr_uniq( $g, $s->pick_data_clr($_) );
			my $pa = $pb;
			$pb += 360*$data->[1][$_]/$total;
			my ($xe, $ye) = cartesian($s->{w}/2, $pa, 
							$s->{xc}, $s->{yc}, $s->{h}/$s->{w});
			$g->line($s->{xc}, $s->{yc}, $xe, $ye, $ac);
			$g->line($xe, $ye, $xe, $ye + $s->{pie_height}, $ac)
				if ( in_front($pa) && $s->{'3d'} );
#			 ($xe, $ye) = cartesian($s->{w}/2, $pb, $s->{xc}, $s->{yc}, $s->{h}/$s->{w});
#			 $g->line($s->{xc}, $s->{yc}, $xe, $ye, $ac);
			($xe, $ye) = cartesian(3*$s->{w}/8, ($pa+$pb)/2,
								   $s->{xc}, $s->{yc}, $s->{h}/$s->{w});
			$g->fill($xe, $ye, $dc);
			$s->put_label($g, $xe, $ye, $$data[0][$_]);
			if ( $s->{'3d'} && ( in_front($pa) || in_front($pb) ) ) {
				($xe, $ye) = cartesian($s->{w}/2, (s_angle($pa)+s_angle($pb))/2,
									   $s->{xc}, $s->{yc}, $s->{h}/$s->{w});
				$g->fill($xe, $ye + $s->{pie_height}/2, $dc)
					if ( $g->getPixel($xe, $ye + $s->{pie_height}/2) != $ac );
			}
		}
	} #GIFgraph::pie::draw_data
 
	# Return a sensible angle
 
	sub s_angle { # angle
		my $a = shift;
		$a = level_angle($a);
		return 0   if ( $a < 10 && $a > -90 );
		return 170 if ( $a < -90 || $a > 170 );
		return $a;
	}
 
	# return true if this angle is on the front of the pie
 
	sub in_front { # angle
		my $a = level_angle( shift );
		( $a > 0 && $a < 180 ) ? 1 : 0;
	}
 
	# return a value for angle between -180 and 180
 
	sub level_angle { # angle
		my $a = shift;
		return level_angle($a-360) if ( $a > 180 );
		return level_angle($a+360) if ( $a <= -180 );
		return $a;
	}
 
	# put the label on the pie
 
	sub put_label { # GD:Image
		my $s = shift;
		my $g = shift;
		my ($x, $y, $label) = @_;
		$x -= length($label)*$s->{vfw}/2;
		$y -= $s->{vfw}/2;
		$g->string($s->{vf}, $x, $y, $label, $s->{alci});
	}
 
	# return x, y coordinates from input
	# radius, angle, center x and y and a scaling factor (height/width)
	sub cartesian {
		my ($r, $phi, $xi, $yi, $cr) = @_; my $PI=4*atan2(1, 1);
		return ($xi+$r*cos($PI*$phi/180), $yi+$cr*$r*sin($PI*$phi/180));
	}
 
	sub pick_data_clr { # number
		my $s = shift;
		return _rgb( $s->{dclrs}[ $_[0] % (1+$#{$s->{dclrs}}) ] );
	}
 
} # End of package GIFgraph::pie
 
1;
