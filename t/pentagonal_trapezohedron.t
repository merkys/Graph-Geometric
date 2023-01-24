#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 3;

my $g = Graph::Geometric->pentagonal_trapezohedron;

is scalar( $g->vertices ), 12;
is scalar( $g->edges ),    20;
is scalar( $g->faces ),    10;
