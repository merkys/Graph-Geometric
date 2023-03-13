#!/usr/bin/perl

use strict;
use warnings;

use Graph::Geometric;
use Set::Scalar;
use Test::More;

my @cases = (
    [ [ 'ABCD' ], 'ABCD' ],
    [ [ 'ABCD', 'ABEF' ], 'ADCBFE' ],
    [ [ 'ABCD', 'ABEF', 'BCFG' ], 'ADCGFE' ],
    [ [ 'ABCD', 'ABEF', 'BCFG', 'CDGH' ], 'ADHGFE' ],
);

plan tests => scalar @cases;

for my $case (@cases) {
    my( $faces, $result ) = @$case;

    my $cube = square prism;
    is join( '', $cube->_face_perimeter( [ map { [ split '', $_ ] } @$faces ] ) ), $result;
}
