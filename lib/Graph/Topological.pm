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

sub truncate
{
    my( $self, @vertices ) = @_;
    @vertices = $self->vertices unless @vertices;

    for my $vertex (@vertices) {
        # Cut all the edges
        for my $neighbour ($self->neighbours( $vertex )) {
            $self->add_edge( $neighbour, $vertex . $neighbour ); # TODO: Ensure such vertex does not exist
        }

        # Trim all the faces
        for my $face_id (0..scalar( $self->faces ) - 1) {
            my $face = $self->get_graph_attribute( 'faces' )->[$face_id];
            next unless $face->has( $vertex );

            # Find the two neighbours of $vertex in the face
            my( $v1, $v2 ) = grep { $face->has( $_ ) } $self->neighbours( $vertex );

            # Connect the new vertices corresponding to edges with these neighbours
            $self->add_edge( $vertex . $v1, $vertex . $v2 );

            # Adjust the face
            $face->invert( $vertex, $vertex . $v1, $vertex . $v2 );
        }

        # Add new face created by trimming this one
        push @{$self->get_graph_attribute( 'faces' )},
             Set::Scalar->new( map { $vertex . $_ } $self->neighbours( $vertex ) );

        # Remove the vertex
        $self->delete_vertex( $vertex );
    }
}

1;
