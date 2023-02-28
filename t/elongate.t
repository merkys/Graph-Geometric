#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More tests => 6;

my $pyramid = pentagonal bipyramid;
$pyramid = $pyramid->_elongate;

is scalar( $pyramid->vertices ), 12;
is scalar( $pyramid->edges ),    25;
is scalar( $pyramid->faces ),    15;

my $bifrustum5 = pentagonal bifrustum;
my $prism5 = pentagonal prism;
my( $face5 ) = grep { scalar @$_ == 5 } $prism5->faces;
$prism5->_elongate( $face5 );

is scalar( $prism5->vertices ), scalar( $bifrustum5->vertices );
is scalar( $prism5->edges ),    scalar( $bifrustum5->edges );
is scalar( $prism5->faces ),    scalar( $bifrustum5->faces );
