#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 4;

my $g = Graph::Geometric->truncated_icosahedron;

is scalar( $g->vertices ), 60;
is scalar( $g->edges ), 90;
is scalar( $g->faces ), 32;

is join( ',', sort map { scalar @$_ } $g->faces ), '5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6';
