use GIFgraph::bars;
use GD;
use strict;

print STDERR "Processing sample 1-4\n";

my $strf = gdTinyFont;

my @data = ( 
    ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
    [    5,   12,   24,   33,   19,    8,    6,    15,    21],
    [    1,    2,    5,    6,    3,  1.5,    1,     3,     4]
);

my $my_graph = new GIFgraph::bars( );

$my_graph->set( 
	x_label => 'X Label',
	y1_label => 'Y1 label',
	y2_label => 'Y2 label',
	title => 'Using two axes',
	y1_max_value => 40,
	y2_max_value => 8,
	y_tick_number => 8,
	y_label_skip => 2,
	long_ticks => 1,
	two_axes => 1,
	legend_placement => 'RT',
	x_labels_vertical => 1,
	x_label_position => 1/2,

	bar_spacing => 2,

	logo => 'logo.gif',
	logo_position => 'BR',

	# Leave some room for the text that I will be putting on later
	b_margin => $strf->height(),
);

$my_graph->set_title_font(gdGiantFont);

# And some funky colours
$my_graph->set_text_clr('lyellow');
$my_graph->set_fg_clr('dyellow');
$my_graph->set(
	bgclr		=> 'gray',
	accentclr	=> 'black',
	#legendclr  => 'white',
	tickclr => 'dgreen',
	axisclr => 'green',
	labelclr => 'lgray',
	axislabelclr => 'lgray',
	#textclr => 'white',

	dclrs => [qw(lred lgreen)],
);

$my_graph->set_legend( 'left axis', 'right axis');

# Get the gd object to do some more stuff
#
my $gd = $my_graph->plot_to_gd(\@data);

my $ci;
# Allocate a colour
if ( ($ci = $gd->colorExact(0,0,0)) < 0 ) 
{
	# if not, allocate a new one, and return it's index
	$ci = $gd->colorAllocate(0,0,0);
} 

# Just for kicks, add a copyright notice to the bottom right of the image.
my $str1 = "Copyright";
my $str2 = "Martien Verbruggen";

$gd->string(
	$strf, 
	0, 
	$my_graph->{gify} - $strf->height, 
	$str1, $ci
);
$gd->string(
	$strf, 
	$my_graph->{gifx} - length($str2) * $strf->width, 
	$my_graph->{gify} - $strf->height, 
	$str2, $ci
);

open(OUT, ">sample14.gif") || die "Cannot open sample14.gif for write: $!";
binmode(OUT); # NT and DOS
print OUT $gd->gif();
close(OUT);

exit;

