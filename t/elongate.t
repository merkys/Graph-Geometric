#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 3;

my $pyramid = pentagonal bipyramid;
$pyramid = $pyramid->_elongate;

is scalar( $pyramid->vertices ), 12;
is scalar( $pyramid->edges ),    25;
is scalar( $pyramid->faces ),    15;
