#==========================================================================
#			   Copyright (c) 1995-2000 Martien Verbruggen
#--------------------------------------------------------------------------
#
#	Name:
#		GIFgraph::Convert.pm
#
# $Id: Convert.pm,v 1.1 1999-12-26 04:39:12 mgjv Exp $
#
#==========================================================================
package GIFgraph::Convert;

use strict;
use Carp;

sub png2gif
{
	my $png  = shift;

	checkImageMagick();

	my $im = Image::Magick->new() or 
		croak 'Cannot create Image::Magick object';
	my $rc = $im->BlobToImage($png);
	carp $rc if $rc;
	$im->Set(format => 'png');
	return $im->ImageToBlob();
}

sub checkImageMagick
{
	eval "require Image::Magick";
	croak <<EOMSG if $@;

	Image::Magick cannot be found. Your version of GD exports PNG format
	graphics, and GIFgraph needs something to convert those to GIF. If
	you want to provide an alternative method, please edit the sub
	png2gif in the file GIFgraph/Convert.pm, and if you're installing,
	Makefile.PL.

EOMSG
}

1;
