use GIFgraph::lines;

print STDERR "Processing sample 5-2\n";

@data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    1,    2,    5,    6,    3,  1.5,    1,     3,     4],
    [    5,    3,    1,    1,    3,  1.5,    2,     1,     0],
    [    9,    8,    9,  8.4,  9.1,  7.5,    8,    10,     9],
	[  0.1,  0.2,  0.5,  0.4,  0.3,  0.5,  0.1,     0,   0.4],
);

$my_graph = new GIFgraph::lines( );

$my_graph->set( 'x_label' => 'X Label',
                'y_label' => 'Y label',
                'title' => 'A Multiple Line Graph',
                'y_max_value' => 10,
                'y_tick_number' => 10,
                'y_label_skip' => 2 );

$my_graph->plot_to_gif( "sample52.gif", \@data );

exit;

