#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 9;

my $cube;

$cube = tetragonal prism;

is join( ';', sort map { join ',', sort @$_ } $cube->faces ),
   'A,B,C,D;A,B,E,F;A,D,E,H;B,C,F,G;C,D,G,H;E,F,G,H';

$cube->carve_edge( 'A', 'B' );

is scalar( $cube->vertices ), 9;
is scalar( $cube->edges ), 13;
is scalar( $cube->faces ), 6;

is join( ';', sort map { join ',', sort @$_ } $cube->faces ),
   'A,AB,B,C,D;A,AB,B,E,F;A,D,E,H;B,C,F,G;C,D,G,H;E,F,G,H';

$cube = tetragonal prism;

$cube->carve_face( 'A', 'C' );

is scalar( $cube->vertices ), 8;
is scalar( $cube->edges ), 13;
is scalar( $cube->faces ), 7;

is join( ';', sort map { join ',', sort @$_ } $cube->faces ),
   'A,B,C;A,B,E,F;A,C,D;A,D,E,H;B,C,F,G;C,D,G,H;E,F,G,H';
