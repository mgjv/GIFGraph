#==========================================================================
#              Copyright (c) 1995 Martien Verbruggen
#              Copyright (c) 1996 Commercial Dynamics Pty Ltd
#              Copyright (c) 1997 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::utils.pm
#
#	Description:
#		Package of general utilities.
#
# $Id: utils.pm,v 1.1.1.2 1999-10-10 12:07:05 mgjv Exp $
#
#==========================================================================
 
use strict qw(vars subs refs);

package GIFgraph::utils;

use vars qw( @ISA @EXPORT_OK %EXPORT_TAGS );
require Exporter;
@ISA = qw( Exporter );
 
@EXPORT_OK = qw( _max _min _round );
%EXPORT_TAGS = ( all => [qw(_max _min _round)],);

$GIFgraph::utils::prog_name    = 'GIFgraph::utils.pm';
$GIFgraph::utils::prog_rcs_rev = '$Revision: 1.1.1.2 $';
$GIFgraph::utils::prog_version = 
	($GIFgraph::utils::prog_rcs_rev =~ /\s+(\d*\.\d*)/) ? $1 : "0.0";

{
    sub _max { 
        my ($a, $b) = @_; 
		return undef	if (!defined($a) and !defined($b));
		return $a 		if (!defined($b));
		return $b 		if (!defined($a));
        ( $a >= $b ) ? $a : $b; 
    }

    sub _min { 
        my ($a, $b) = @_; 
		return undef	if (!defined($a) and !defined($b));
		return $a 		if (!defined($b));
		return $b 		if (!defined($a));
        ( $a <= $b ) ? $a : $b; 
    }

    sub _round { 
        my($n) = shift; 
        int($n + .5 * ($n <=> 0)); 
    }

    sub version {
        return $GIFgraph::utils::prog_version;
    }

    $GIFgraph::utils::prog_name;

} # End of package MVU
