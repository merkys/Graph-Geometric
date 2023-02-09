#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More;

eval 'use Graph::Nauty qw(orbits)';
plan skip_all => 'no Graph::Nauty' if $@;

my @cases = (
    [ 1,  trigonal pyramid ],
    [ '', square pyramid ],
);

plan tests => 2 * scalar @cases;

for my $case (@cases) {
    my( $is_isogonal, $figure ) = @$case;
    is $figure->is_isogonal, $is_isogonal;
    is $figure->is_isotoxal, $is_isogonal;
}
