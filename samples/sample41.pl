use GIFgraph::linespoints;

print STDERR "Processing sample 4-1\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    5,   12,   24,   33,   19,    8,    6,    15,    21],
    [    1,    2,    5,    6,    3,  1.5,    1,     3,     4]
);

$my_graph = new GIFgraph::linespoints( );

$my_graph->set( 'x_label' => 'X Label',
                'y_label' => 'Y label',
                'title' => 'A Lines and Points Graph',
                'y_max_value' => 40,
                'y_tick_number' => 8,
                'y_label_skip' => 2 );

$my_graph->plot_to_gif( "sample41.gif", \@data );

exit;

