use GIFgraph::lines;
use strict;

print STDERR "Processing sample 5-5\n";

# The reverse is in here, because I thought the falling line was
# depressing, but I was too lazy to retype the data set

my @x = map {$_ * 3 * 3.14159/100} (0 .. 100);
my @y = map sin, @x;
my @z = map cos, @x;

my @data = (\@x,\@y,\@z);

my $my_graph = new GIFgraph::lines();

$my_graph->set(
	x_label 			=> 'Angle (Radians)',
	y_label 			=> 'Trig Function Value',
	x_tick_number 		=> 'auto',
	y_tick_number 		=> 'auto',
	title 				=> 'Sine and Cosine',
	line_width 			=> 1,
	x_label_position 	=> 1/2,
	r_margin 			=> 15,
);

$my_graph->set_legend('Thanks to Scott Prahl');

$my_graph->plot_to_gif( "sample55.gif", \@data );

exit;

sub read_data
{
	my $fn = shift;
	my @d = ();

	open(ZZZ, $fn) || return ();

	while (<ZZZ>)
	{
		chomp;
		my @row = split;

		for (my $i = 0; $i <= $#row; $i++)
		{
			undef $row[$i] if ($row[$i] eq 'undef');
			push @{$d[$i]}, $row[$i];
		}
	}

	close (ZZZ);

	return @d;
}

