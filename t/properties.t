#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Test::More;

eval 'use Graph::Nauty qw(orbits)';
plan skip_all => 'no Graph::Nauty' if $@;

my @cases = (
    [  1,  1,  1,  1, '', 2, trigonal pyramid ],
    [ '',  1, '', '', '', 2, square pyramid ],
    [  1, '', '', '', '', 2, truncated icosahedron ],
    [  1,  1, '', '',  1, 2, rectified octahedron ],
    [  1,  1,  1,  1, '', 0, torus( 6, 4 ) ],
);

plan tests => 6 * scalar @cases;

for my $case (@cases) {
    my( $is_isogonal, $is_isotoxal, $is_isohedral, $is_regular, $is_quasiregular, $Euler_characteristic, $figure ) = @$case;
    is $figure->is_isogonal,          $is_isogonal;
    is $figure->is_isotoxal,          $is_isotoxal;
    is $figure->is_isohedral,         $is_isohedral;
    is $figure->is_regular,           $is_regular;
    is $figure->is_quasiregular,      $is_quasiregular;
    is $figure->Euler_characteristic, $Euler_characteristic;
}
