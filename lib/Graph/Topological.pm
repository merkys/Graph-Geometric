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

sub regular_dodecahedron
{
    my( $class ) = @_;
    my $pt = $class->pentagonal_trapezohedron;
    $pt->truncate( 'A', 'B' );
    return $pt;
}

sub regular_icosahedron
{
    my( $class ) = @_;
    return $class->regular_dodecahedron->dual;
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

sub dual
{
    my( $self ) = @_;

    my $dual = Graph::Undirected->new;

    # All faces become vertices
    $dual->add_vertices( map { join '', @$_ } $self->faces );

    for my $face1_id (0..scalar( $self->faces ) - 1) {
        my $face1 = $self->get_graph_attribute( 'faces' )->[$face1_id];

        my $edges = {};
        for ($self->subgraph( [$face1->members] )->edges) {
            my @edges = sort @$_;
            $edges->{$edges[0]}{$edges[1]} = 1;
        }

        for my $face2_id ($face1_id+1..scalar( $self->faces ) - 1) {
            my $face2 = $self->get_graph_attribute( 'faces' )->[$face2_id];

            # If faces share an edge, they are connected in the dual
            for ($self->subgraph( [$face2->members] )->edges) {
                my @edges = sort @$_;
                next unless $edges->{$edges[0]}{$edges[1]};

                $dual->add_edge( join( '', sort $face1->members ),
                                 join( '', sort $face2->members ) );
                last;
            }
        }
    }

    # TODO: Find cycles

    return bless $dual; # TODO: Bless with a class
}

1;
