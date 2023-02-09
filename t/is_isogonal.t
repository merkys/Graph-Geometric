#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More;

eval 'use Graph::Nauty qw(orbits)';
plan skip_all => 'no Graph::Nauty' if $@;

my @cases = (
    [ 1,   1, trigonal pyramid ],
    [ '',  1, square pyramid ],
    [ 1,  '', truncated icosahedron ],
);

plan tests => 2 * scalar @cases;

for my $case (@cases) {
    my( $is_isogonal, $is_isotoxal, $figure ) = @$case;
    is $figure->is_isogonal, $is_isogonal;
    is $figure->is_isotoxal, $is_isotoxal;
}
