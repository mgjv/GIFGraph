use GIFgraph::pie;
use strict;

print STDERR "Processing sample 9-3\n";

my @data = ( 
	[ qw( 1st 2nd 3rd 4th 5th 6th 7th ) ],
	[ sort { $b <=> $a} (5.6, 2.1, 3.03, 4.05, 1.34, 0.2, 2.56) ]
);

my $my_graph = new GIFgraph::pie( 200, 200 );

$my_graph->set( 
	start_angle => 90,
	'3d' => 0
);

$my_graph->plot_to_gif( "sample93.gif", \@data );

exit;

