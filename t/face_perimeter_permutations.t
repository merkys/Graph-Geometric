#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use List::Util qw( uniq );
use Math::Combinatorics;
use Set::Scalar;
use Test::More;

plan tests => 1;

my $cube = square prism;
my @faces = $cube->faces;
my @cycles;

for my $i (1..2**@faces-1) {
    my @selected = map { $faces[$_] } grep { 2 ** $_ & $i } 0..$#faces;
    my $cycle;
    eval { $cycle = join '', $cube->_face_perimeter( \@selected ) };
    push @cycles, $cycle if $cycle;
}

# Cube has 28 unique cycles
is scalar( uniq @cycles ), 28;
