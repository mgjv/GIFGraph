#==========================================================================
#              Copyright (c) 1995 Martien Verbruggen
#              Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph.pm
#
#	Description:
#               Module to create graphs from a data set, outputting
#		GIF format graphics.
#
#		Package of a number of graph types:
#		GIFgraph::bars
#		GIFgraph::lines
#		GIFgraph::points
#		GIFgraph::linespoints
#		GIFgraph::area
#		GIFgraph::pie
#
# $Id: GIFgraph.pm,v 1.1.1.2 1999-10-10 12:07:03 mgjv Exp $
#
#==========================================================================

require 5.003;

#use strict qw(vars refs subs);
use strict qw(vars refs);

# Use Lincoln Stein's GD and Thomas Boutell's libgd.a
use GD;

#
# GIFgraph
#
# Parent class containing data all graphs have in common.
#

package GIFgraph;

$GIFgraph::prog_name    = 'GIFgraph.pm';
$GIFgraph::prog_rcs_rev = '$Revision: 1.1.1.2 $';
$GIFgraph::prog_version = 
	($GIFgraph::prog_rcs_rev =~ /\s+(\d*\.\d*)/) ? $1 : "0.0";

$GIFgraph::VERSION = '0.94';

# Some tools and utils
use GIFgraph::colour qw(:colours);

my $OS;

# Let's guess what the OS is
# (from CGI.pm by Lincoln Stein)
# OVERRIDE THE OS HERE IF THE GUESS IS WRONG

# $OS = 'UNIX';
# $OS = 'MACINTOSH';
# $OS = 'WINDOWS';
# $OS = 'VMS';
# $OS = 'OS2';

# FIGURE OUT THE OS WE'RE RUNNING UNDER
# Some systems support the $^O variable.  If not
# available then require() the Config library
unless ($OS) {
    unless ($OS = $^O) {
        require Config;
        $OS = $Config::Config{'osname'};
    }
	if ($OS=~/Win/i) {
		$OS = 'WINDOWS';
	} elsif ($OS=~/vms/i) {
		$OS = 'VMS';
	} elsif ($OS=~/Mac/i) {
		$OS = 'MACINTOSH';
	} elsif ($OS=~/os2/i) {
		$OS = 'OS2';
	} else {
		$OS = 'UNIX';
	}
}

$GIFgraph::needs_binmode = $OS=~/^(WINDOWS|VMS|OS2)/;

# Start of the package methods
{
	#
	# GIF size
	#

	my %GIFsize = ( 'x' => 400, 'y' => 300 );

	my %Defaults = (

		# Set the top, bottom, left and right margin for the GIF. These 
		# margins will be left empty.

		't_margin'      => 0,
		'b_margin'      => 0,
		'l_margin'      => 0,
		'r_margin'      => 0,

		# Set the factor with which to resize the logo in the GIF (need to
		# automatically compute something nice for this, really), set the 
		# default logo file name, and set the logo position (UR, BR, UL, BL)

		'logo_resize'   => 1.0,
		'logo'          => undef,
		'logo_position' => 'LR',

		# Write a transparent GIF?

		'transparent'   => 1,

		# Write an interlaced GIF?

		'interlaced'    => 1,

		# Set the background colour, the default foreground colour (used 
		# for axes etc), the textcolour, the colour for labels, the colour 
		# for numbers on the axes, the colour for accents (extra lines, tick
		# marks, etc..)

		'bgclr'         => 'white',
		'fgclr'         => 'dblue',
		'textclr'       => 'dblue',
		'labelclr'      => 'dblue',
		'axislabelclr'  => 'dblue',
		'accentclr'     => 'gray',

		# number of pixels to use as text spacing

		'text_space'    => 8,
	);

    #
    # PUBLIC methods, documented in pod.
    #
    sub new 
	{ # [ width, height ] optional;

        my $type = shift;
        my $self = {};
        bless $self, $type;

        if (@_) 
		{
            # If there are any parameters, they should be the size
            $self->{gifx} = shift;

            # If there's an x size, there should also be a y size.
            die "Usage: GIFgraph::<type>::new( [x_size, y_size] )\n" unless @_;
            $self->{gify} = shift;
        } 
		else 
		{
            # There were obviously no parameters, so use defaults
            $self->{gifx} = $GIFsize{'x'};
            $self->{gify} = $GIFsize{'y'};
        }

        # Initialise all relevant parameters to defaults
        # These are defined in the subclasses. See there.
        $self->initialise( );

        return $self;
    }

    sub set 
	{
        my $s = shift;
        my %args = @_;

        foreach (keys %args) 
		{ 
			$s->{$_} = $args{$_}; 
		}
    }

    # These should probably not be used, or be rewritten to 
    # accept some keywords. Problem is that GD is very limited 
    # on fonts, and this routine just accepts GD font names. 
    # But.. it's not nice to require the user to include GD.pm
    # just because she might want to change the font.

    sub set_title_font 
	{ # fontname
        my $self = shift;

        $self->{tf} = shift;
        $self->set( 
			'tfw' => $self->{tf}->width,
			'tfh' => $self->{tf}->height,
		);
    }

    sub set_text_clr 
	{ # colour name
        my $s = shift;
        my $c = shift;

        $s->set(
            'textclr'       => $c,
            'labelclr'      => $c,
            'axislabelclr'  => $c,
        );
    }

    sub plot_to_gif 
	{ # "file.gif", \@data
        my $s = shift;
        my $file = shift;
        my $data = shift;

        open (GIFPLOT,">$file") || do 
		{ 
			warn "Cannot open $file for writing: $!";
			return 0; 
		};
		binmode GIFPLOT if ($GIFgraph::needs_binmode);
        print GIFPLOT $s->plot( $data );
        close(GIFPLOT);
    }

    # Routine to read GNU style data files
	# NOT USEABLE

    sub ReadFile 
	{
        my $file = shift; 
		my @cols = @_; 
		my (@out, $i, $j);

        @cols = 1 if ( $#cols < 1 );

        open (DATA, $file) || do { 
			warn "Cannot open file: $file"; 
			return []; 
		};

        $i=0; 
        while (defined(<DATA>)) 
		{ 
            s/^\s+|\s+$//;
            next if ( /^#/ || /^!/ || /^[ \t]*$/ );
            @_ = split(/[ \t]+/);
            $out[0][$i] = $_[0];
            $j=1;
            foreach (@cols) 
			{
                if ( $_ > $#_ ) { 
					warn "Data column $_ not present"; 
					return []; 
				}
                $out[$j][$i] = $_[$_]; $j++;
            }
            $i++;
        }
        close(DATA);

        return @out;

    } # ReadFile

    #
    # PRIVATE methods
    #

    # Set defaults that apply to all graph/chart types. 
    # This is called by the default initialise methods 
    # from the objects further down the tree.

    sub defaults 
	{
        my $self = shift;

		foreach (keys %Defaults) 
		{
			$self->set( $_ => $Defaults{$_} );
		}

        $self->set_title_font(GD::gdLargeFont);
    }


    # Check the integrity of the submitted data
    #
    # Checks are done to assure that every input array 
    # has the same number of data points, it sets the variables
    # that store the number of sets and the number of points
    # per set, and kills the process if there are no datapoints
    # in the sets, or if there are no data sets.

    sub check_data 
	{ # \@data
        my $self = shift;
        my $data = shift;

        $self->set('numsets' => $#$data);
        $self->set('numpoints' => $#{@$data[0]});

        ( $self->{numsets} < 1 || $self->{numpoints} < 0 ) && die "No Data";

        for my $i ( 1..$self->{numsets} ) 
		{
			die "Data array $i: length misfit"
				unless ( $self->{numpoints} == $#{@$data[$i]} );
        }
    }

    # Open the graph output canvas by creating a new GD object.

    sub open_graph 
	{
        my $self = shift;
        my $graph = new GD::Image($self->{gifx}, $self->{gify});
        return $graph;
    }

    # Initialise the graph output canvas, setting colours (and getting back
    # index numbers for them) setting the graph to transparent, and 
    # interlaced, putting a logo (if defined) on there.

    sub init_graph 
	{ # GD::Image
        my $self = shift;
        my $graph = shift;

        $self->{bgci} = $self->set_clr( $graph, _rgb($self->{bgclr}) );
        $self->{fgci} = $self->set_clr( $graph, _rgb($self->{fgclr}) );
        $self->{tci}  = $self->set_clr( $graph, _rgb($self->{textclr}) );
        $self->{lci}  = $self->set_clr( $graph, _rgb($self->{labelclr}) );
        $self->{alci} = $self->set_clr( $graph, _rgb($self->{axislabelclr}) );
        $self->{acci} = $self->set_clr( $graph, _rgb($self->{accentclr}) );
        $graph->transparent($self->{bgci}) if $self->{transparent};
        $graph->interlaced($self->{interlaced});
        $self->put_logo($graph);
    }

    # read in the logo, and paste it on the graph canvas

    sub put_logo 
	{ # GD::Image
        my $self = shift;
        my $graph = shift;

		return unless(defined($self->{logo}));

        my ($x, $y, $glogo);
        my $r = $self->{logo_resize};

        open(GIFLOGO, $self->{logo}) || return;
		binmode(GIFLOGO) if ($GIFgraph::needs_binmode);
        unless ( $glogo = newFromGif GD::Image(GIFLOGO) ) 
		{
            warn "Problems reading $self->{logo}"; 
			close(GIFLOGO); 
			return;
        }
        close(GIFLOGO);

        my ($w, $h) = $glogo->getBounds;
        LOGO: for ($self->{logo_position}) {
            /UL/i && do {
                $x = $self->{l_margin};
                $y = $self->{t_margin};
                last LOGO;
            };
            /UR/i && do {
                $x = $self->{gifx} - $self->{r_margin} - $w * $r;
                $y = $self->{t_margin};
                last LOGO;
            };
            /LL/i && do {
                $x = $self->{l_margin};
                $y = $self->{gify} - $self->{b_margin} - $h * $r;
                last LOGO;
            };
            # default "LR"
            $x = $self->{gifx} - $self->{r_margin} - $r * $w;
            $y = $self->{gify} - $self->{b_margin} - $r * $h;
            last LOGO;
        }
        $graph->copyResized($glogo, $x, $y, 0, 0, $r * $w, $r * $h, $w, $h);
        undef $glogo;
    }

    # Set a colour to work with on the canvas, by rgb value. 
    # Return the colour index in the palette

    sub set_clr 
	{ # GD::Image, r, g, b
        my $s = shift; 
		my $g = shift; 
		my $i;

        # Check if this colour already exists on the canvas
        if ( ( $i = $g->colorExact( @_ ) ) < 0 ) 
		{
            # if not, allocate a new one, and return it's index
            return $g->colorAllocate( @_ );
        } 
        return $i;
    }
    
    # Set a colour, disregarding wether or not it already exists.

    sub set_clr_uniq 
	{ # GD::Image, r, g, b
        my $s=shift; 
        my $g=shift; 

        $g->colorAllocate( @_ ); 
    }

    # Return an array of rgb values for a colour number

    sub pick_data_clr 
	{ # number
        my $s = shift;

        return _rgb( $s->{dclrs}[ $_[0] % (1+$#{$s->{dclrs}}) -1 ] );
    }

    # DEBUGGING
	# Obsolete now, use Data::Dumper

    # Return the gif contents

    sub gifdata 
	{
        my $s = shift;

        return $s->{graph}->gif;
    }

    sub version 
	{
        return $GIFgraph::prog_version;
    }

} # End of package GIFgraph

$GIFgraph::prog_name;

__END__

=head1 NAME

GIFgraph - Graph Plotting Module for Perl 5

=head1 SYNOPSIS

use GIFgraph::moduleName;

=head1 DESCRIPTION

B<GIFgraph> is a I<perl5> module to create and display GIF output 
for a graph.
The following classes for graphs with axes are defined:

=over 4

=item C<GIFgraph::lines>

Create a line chart.

=item C<GIFgraph::bars>

Create a bar chart.

=item C<GIFgraph::points>

Create an chart, displaying the data as points.

=item C<GIFgraph::linespoints>

Combination of lines and points.

=item C<GIFgraph::area>

Create a graph, representing the data as areas under a line.

=back

Additional types:

=over 4

=item C<GIFgraph::pie>

Create a pie chart.

=back

=head1 USAGE

Fill an array of arrays with the x values and the values of the data sets.
Make sure that every array is the same size.
B<NB.> Necessary to extend with a function setting the values in [x,y1,y2..] 
sets?

    @data = ( 
        ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
        [    1,    2,    5,    6,    3,  1.5,    1,     3,     4]
    );

Create a new Graph object by calling the C<new> 
operator on the graph type you want to create 
(C<chart> is C<bars, lines, points, linespoints>
or C<pie>).

    $my_graph = new GIFgraph::chart( );

Set the graph options. 

    $my_graph->set( 'x_label'           => 'X Label',
                    'y_label'           => 'Y label',
                    'title'             => 'A Simple Line Graph',
                    'y_max_value'       => 8,
                    'y_tick_number'     => 8,
                    'y_label_skip'      => 2 );

Output the graph

    $my_graph->plot_to_gif( "sample01.gif", \@data );

=head1 METHODS AND FUNCTIONS

=head2 Methods for all graphs

=over 4

=item new GIFgraph::chart([width,height])

Create a new object $graph with optional width and heigth. 
Default width = 400, default height = 300. C<chart> is either
C<bars, lines, points, linespoints, area> or C<pie>.

=item set_text_clr( <colour name> )

Set the colour of the text.

=item set_title_font( <fontname> )

Set the font that will be used for the title of the chart.  Possible
choices are defined in GD. 
B<NB.> If you want to use this function, you'll
need to use GD. At some point I'll rewrite this, so you can give this a
number from 1 to 4, or a string like 'large' or 'small'

=item plot( <\@data> )

Plot the chart, and return the GIF data.

=item plot_to_gif( <"filename", \@data> )

Plot the chart, and write the GIF data to I<filename>.

=cut

# =item ReadFile ( <"filename">, I<some array of columns?> )
# 
# Read data from I<filename>, which must be a data file formatted for
# GNUplot.
# B<NB.> Have to figure out how to call the function.

=item set( I<key1 => value1, key2 => value2 ....> )

Set chart options. See OPTIONS section.

=back

=head2 Methods for Pie charts

=over 4

=item set_label_font( I<fontname> )

=item set_value_font( I<fontname> )

Set the font that will be used for the vabel of the pie or the 
values on the pie.  Possible choices are defined in GD. 
B<NB.> If you want to use this function, you'll
need to use GD. At some point I'll rewrite this, so you can give this a
number from 1 to 4, or a string like 'large' or 'small'

=back


=head2 Methods for charts with axes.

=over 4

=item set_x_label_font ( I<font name> )

=item set_y_label_font ( I<font name> )

=item set_x_axis_font ( I<font name> )

=item set_y_axis_font ( I<font name> )

Set the font for the x and y axis label, and for the x and y axis value labels.
B<NB.> If you want to use this function, you'll
need to use GD. At some point I'll rewrite this, so you can give this a
number from 1 to 4, or a string like 'large' or 'small'

=back

=head1 OPTIONS

=head2 Options for all graphs

=over 4

=item gifx, gify

The width and height of the gif file in pixels
Default: 400 x 300.

=item t_margin, b_margin, l_margin, r_margin

Top, bottom, left and right margin of the GIF. These margins will be left blank.
Default: 0 for all.

=item logo

Name of the logo file. This should be a GIF file. 
Default: no logo.

=item logo_resize, logo_position

Factor to resize the logo by, and the position on the canvas of the
logo. Possible values for logo_position are 'LL', 'LR', 'UL', and 'UR'.
(lower and upper left and right). 
Default: 'LR'.

=item transparent

If 1, the produced GIF will have the background colour marked as
transparent.  Default: 1.

=item interlaced

If 1, the produced GIF will be interlaced.
Default: 1.

=item bgclr, fgclr, textclr, labelclr, axislabelclr, accentclr

Background, foreground, text, label, axis label and accent colours.

=item dclrs (short for datacolours)

This controls the colours for the bars, lines, markers, or pie slices.
This should be a reference to an array of colour names as defined in
GIFgraph::colour (perldoc GIFgraph::colour for the names available).

$graph->set( 'dclrs' => [ 'green', 'pink', 'blue', 'cyan' ] );

The first (fifth, ninth) data set will be green, the next pink, etc.
Default: ['lred', 'lgreen', 'lblue', 'lyellow', 'lpurple', 'cyan', 'lorange'] 

=back

=head2 Options for graphs with axes.

options for C<bars, lines, points, linespoints> and 
C<area> charts.

=over 4

=item long_ticks, tick_length

If I<long_ticks> = 1, ticks will be drawn the same length as the axes.
Otherwise ticks will be drawn with length I<tick_length>.
Default: long_ticks = 0, tick_length = 4.

=item y_tick_number

Number of ticks to print for the Y axis.
Default: 5.

=item x_ticks

If I<x_ticks> = 1, ticks will be drawm for the x axis. These ticks are
subject to the values of long_ticks and tick_length.  
Default: 1.

=item x_label_skip, y_label_skip

Print every I<x_label_skip>th number under the tick on the x axis, and
every I<y_label_skip>th number next to the tick on the y axis.
Default: 1 for both.

=item x_plot_values, y_plot_values

If set to 1, the values of the ticks on the x or y axes will be plotted
next to the tick. Also see I<x_label_skip, y_label_skip>.
Default: 1 for both.

=item box_axis

Draw the axes as a box, if 1.
Default: 1.

=item two_axes

Use two separate axes for the first and second data set. The first data
set will be set against the left axis, the second against the right
axis. If this is set to 1, trying to use anything else than 2 datasets
will generate an error.
Default: 0.

=item zero_axis

If set to a true value, the axis for y values of 0 will always be
drawn. This might be useful in case your graph contains negative
values, but you want it to be clear where the zero value is. (see also
I<zero_axis_only> and I<box_axes>).
Default: 1.

=item zero_axis_only

If set to a true value, the zero axis will be drawn (see
I<zero_axis>), and no axis at the bottom of the graph will be drawn.
The labels for X values will be placed on the zero exis.
Default: 1.

=cut

# Removed for now
#
# =item line_width
#
# The width of the line used in I<lines> and I<linespoints> graphs, in pixels.
# Default: 2.

=item axis_space

This space will be left blank between the axes and the text.
Default: 4.

=item overwrite

If set to 0 bars of different data sets will be drawn next to each
other. If set to 1, they will be drawn in front of each other. If set
to 2 they will be drawn on top of each other.
Default: 0.

If you have negative values in your data sets, setting overwrite to 2
might produce odd results. Of course, the graph itself would be quite
meaningless, because overwrite = 2 is meant to show some cumulative
effect.

=item markers

This controls the order of markers in points and linespoints graphs.
This should be a reference to an array of numbers:

$graph->set( 'markers' => [3, 5, 6] );

Available markers are: 1: filled square, 2: open square, 3: horizontal
cross, 4: diagonal cross, 5: filled diamond, 6: open diamond, 7:
filled circle, 8: open circle.

Default: [1,2,3,4,5,6,7,8]

=item marker_size

The size of the markers used in I<points> and I<linespoints> graphs, in pixels.
Default: 4.

=back


=head2 Options for pie graphs

=over 4

=item 3d

If 1, the pie chart will be drawn with a 3d look.
Default: 1.

=item pie_height

The thickness of the pie when I<3d> is 1.
Default: 0.1 x GIF y size.

=item start_angle

The angle at which the first data slice will be displayed, with 0 degrees being "3 o'clock".
Default: 0.

=back

=head1 AUTHOR

Martien Verbruggen

=head2 Contact info 

email: mgjv@comdyn.com.au

=head2 Copyright

Copyright (C) 1996 Martien Verbruggen.
All rights reserved.  This package is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.

=cut

# WWW: http://www.tcp.chem.tue.nl/~tgtcmv/
