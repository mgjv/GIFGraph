#==========================================================================
#              Copyright (c) 1995 Martien Verbruggen
#              Copyright (c) 1996 Commercial Dynamics Pty Ltd
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::utils.pm
#
#	Description:
#		Package of general utilities.
#
# $Id: utils.pm,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
#
# $Log: not supported by cvs2svn $
# Revision 1.1  1997/02/14 02:32:49  mgjv
# Initial revision
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
$GIFgraph::utils::prog_rcs_rev = '$Revision: 1.1.1.1 $';
$GIFgraph::utils::prog_version = 
	($GIFgraph::utils::prog_rcs_rev =~ /\s+(\d*\.\d*)/) ? $1 : "0.0";

{
    sub _max { 
        my ($a, $b) = @_; 
        ( $a >= $b ) ? $a : $b; 
    }

    sub _min { 
        my ($a, $b) = @_; 
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
