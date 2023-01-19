#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 3;

my $g = Graph::Geometric->truncated_icosahedron;

is scalar( $g->vertices ), 60;
is scalar( $g->edges ), 90;
is scalar( $g->faces ), 32;
