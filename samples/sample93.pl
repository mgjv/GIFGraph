use GIFgraph::pie;

print STDERR "Processing sample 9-3\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th"],
    [    4,    2,    3,    4,    3,  3.5]
);

$my_graph = new GIFgraph::pie( 200, 200 );

$my_graph->set( 'start_angle' => 60,
                '3d' => 0 );

$my_graph->plot_to_gif( "sample93.gif", \@data );

exit;

