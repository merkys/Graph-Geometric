package Graph::Topological;

use strict;
use warnings;

use parent 'Graph::Undirected';

use Set::Scalar;

sub pentagonal_trapezohedron
{
    my( $class ) = @_;

    my $self = Graph::Undirected->new;
    $self->add_vertices( 'A', 'B' ); # the axial vertices
    my @equatorial_vertices = ( 'C'..'L' );

    $self->add_vertices( @equatorial_vertices );
    for (0..$#equatorial_vertices) {
        $self->add_edge( $equatorial_vertices[$_],
                         ($_ % 2 ? 'B' : 'A') );
        $self->add_edge( $equatorial_vertices[$_],
                         $equatorial_vertices[($_+1) % 10] );
    }

    my @faces;
    for my $i (0..4) {
        push @faces, Set::Scalar->new( 'A',
                                       map { $equatorial_vertices[($i*2+$_) % 10] } 0..2 );
        push @faces, Set::Scalar->new( 'B',
                                       map { $equatorial_vertices[($i*2+$_) % 10] } 1..3 );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self, $class;
}

sub faces
{
    my( $self ) = @_;
    return map { [ sort $_->members ] } @{$self->get_graph_attribute( 'faces' )};
}

1;
