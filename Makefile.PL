# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.1.1.1 1999-10-10 12:01:40 mgjv Exp $
 
#--- Distribution section ---
 
$DISTNAME = 'GIFgraph';
$VERSION  = "0.90";
 
BEGIN { require 5.001 }
 
use ExtUtils::MakeMaker;
 
#--- MY package
 
sub MY::libscan
{
 my($self,$path) = @_;
 
 return '' 
        if($path =~ m:/(RCS|CVS|SCCS)/: ||
           $path =~ m:[~%]$: ||
           $path =~ m:\.(orig|rej|nfs|b[ac]k)$:
          );
 
 $path;
}
 
#--- Write the Makefile
 
my @clean = qw(*% *.html *.b[ac]k *.old);
 
push @clean, map { "*/$_" } @clean;
 
WriteMakefile(
        VERSION   => $VERSION,
        DISTNAME  => $DISTNAME,
        NAME      => $DISTNAME,
 
        'dist'    => {COMPRESS => 'gzip -9f',
                      SUFFIX   => '.gz', 
                      DIST_DEFAULT => 'all tardist',
                     },
 
        'clean'   => {FILES => join(" ", @clean)},
);

