#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 3;

my $cupola5 = pentagonal cupola;
is scalar( $cupola5->vertices ), 15, 'vertices';
is scalar( $cupola5->edges ),    25, 'edges';
is scalar( $cupola5->faces ),    12, 'faces';
