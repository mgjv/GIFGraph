#==========================================================================
#              Copyright (c) 1995 Martien Verbruggen
#              Copyright (c) 1996 Commercial Dynamics Pty Ltd
#              Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::colour.pm
#
#	Description:
#		Package of colour manipulation routines, to be used 
#		with GIFgraph.
#
# $Id: colour.pm,v 1.1.1.2 1999-10-10 12:07:06 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.3  1997/12/16 05:23:51  mgjv
# final check in for 0.94
#
# Revision 1.2  1997/12/16 00:20:50  mgjv
# cleaned up
#
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
#
#==========================================================================

 
use strict qw( vars refs subs );

package GIFgraph::colour;

use vars qw( @ISA @EXPORT_OK %EXPORT_TAGS );

require Exporter;
@ISA = qw( Exporter );

$GIFgraph::colour::prog_name    = 'GIFgraph::colour.pm';
$GIFgraph::colour::prog_rcs_rev = '$Revision: 1.1.1.2 $';
$GIFgraph::colour::prog_version = 
	($GIFgraph::colour::prog_rcs_rev =~ /\s+(\d*\.\d*)/) ? $1 : "0.0";

@EXPORT_OK = qw( _rgb _luminance _hue colour_list sorted_colour_list);
%EXPORT_TAGS = ( 
		colours => [qw(_rgb _luminance _hue)],
		lists => [qw(colour_list sorted_colour_list)]
	);

{
    my %rgb = (
        white	=> [0xFF,0xFF,0xFF], 
        lgray	=> [0xBF,0xBF,0xBF], 
		gray	=> [0x7F,0x7F,0x7F],
		dgray	=> [0x3F,0x3F,0x3F],
		black	=> [0x00,0x00,0x00],
        lblue	=> [0x00,0x00,0xFF], 
		blue	=> [0x00,0x00,0xBF],
        dblue	=> [0x00,0x00,0x7F], 
		gold	=> [0xFF,0xD7,0x00],
        lyellow	=> [0xFF,0xFF,0x00], 
        yellow	=> [0xBF,0xBF,0x00], 
		dyellow	=> [0x7F,0x7F,0x00],
        lgreen	=> [0x00,0xFF,0x00], 
        green	=> [0x00,0xBF,0x00], 
		dgreen	=> [0x00,0x7F,0x00],
        lred	=> [0xFF,0x00,0x00], 
		red		=> [0xBF,0x00,0x00],
		dred	=> [0x7F,0x00,0x00],
        lpurple	=> [0xFF,0x00,0xFF], 
        purple	=> [0xBF,0x00,0xBF],
		dpurple	=> [0x7F,0x00,0x7F],
        lorange	=> [0xFF,0xB7,0x00], 
		orange	=> [0xFF,0x7F,0x00],
        pink	=> [0xFF,0xB7,0xC1], 
		dpink	=> [0xFF,0x69,0xB4],
        marine	=> [0x7F,0x7F,0xFF], 
		cyan	=> [0x00,0xFF,0xFF],
        lbrown	=> [0xD2,0xB4,0x8C], 
		dbrown	=> [0xA5,0x2A,0x2A],
    );

    sub colour_list { # number of colours
        my $n = ( $_[0] ) ? $_[0] : keys %rgb;
		return (keys %rgb)[0..$n-1]; 
    }

    sub sorted_colour_list { # number of colours
        my $n = ( $_[0] ) ? $_[0] : keys %rgb;
        return (sort by_luminance keys %rgb)[0..$n-1];
#        return (sort by_hue keys %rgb)[0..$n-1];

        sub by_luminance { luminance(@{$rgb{$b}}) <=> _luminance(@{$rgb{$a}}); }
        sub by_hue { _hue(@{$rgb{$b}}) <=> _hue(@{$rgb{$a}}); }

    }

    sub _luminance { 
		(0.212671*$_[0] + 0.715160*$_[1] + 0.072169*$_[2])/0xFF; 
	}

    sub _hue { 
		($_[0] + $_[1] + $_[2])/(3*0xFF); 
	}

    sub _rgb { 
		@{$rgb{$_[0]}}; 
	}

    sub version {
        return $GIFgraph::colour::prog_version;
    }
 
    $GIFgraph::colour::prog_name;

} # End of package Colour

__END__

=head1 NAME

Colour - Colour manipulation routines for use with GIFgraph

=head1 SYNOPSIS

see functions

=head1 DESCRIPTION

The B<Colour> Package provides a few routines to convert some colour
names to RGB values. Also included are some functions to calculate
the hue and luminance of the colours, mainly to be able to sort them.

=head1 FUNCTIONS

=over 4

=item Colour::list( I<number of colours> )

Returns a list of I<number of colours> colour names known to the package.

=item Colour::sorted_list( I<number of colours> )

Returns a list of I<number of colours> colour names known to the package, 
sorted by luminance or hue.
B<NB.> Right now it always sorts by luminance. Will add an option in a later
stage to decide sorting method at run time.

=item Colour::rgb( I<colour name> )

Returns a list of the RGB values of I<colour name>.

=item Colour::hue( I<[R,G,B]> )

Returns the hue of the colour with the specified RGB values.

=item Colour::luminance( I<[R,G,B]> )

Returns the luminance of the colour with the specified RGB values.

=back 

=head1 COLOUR NAMES

white,
lgray,
gray,
dgray,
black,
lblue,
blue,
dblue,
gold,
lyellow,
yellow,
dyellow,
lgreen,
green,
dgreen,
lred,
red,
dred,
lpurple,
purple,
dpurple,
lorange,
orange,
pink,
dpink,
marine,
cyan,
lbrown,
dbrown.

=cut

