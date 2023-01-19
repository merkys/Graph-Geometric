package Graph::Geometric;

use strict;
use warnings;

use parent 'Graph::Undirected';

use Set::Scalar;

sub antiprism
{
    my( $class, $N ) = @_;

    my $n_letters = int( log( $N * 2 ) / log( 27 ) ) + 1;
    my $name = 'A' x $n_letters;
    my @vertices;
    for (1..($N*2)) {
        push @vertices, $name;
        $name++;
    }

    # Cap faces
    my @F1 = map { $vertices[$_] } grep { !($_ % 2) } 0..($N*2-1);
    my @F2 = map { $vertices[$_] } grep {   $_ % 2  } 0..($N*2-1);

    my $self = Graph::Undirected->new;
    $self->add_vertices( @vertices );

    $self->add_cycle( @F1 );
    $self->add_cycle( @F2 );
    $self->add_cycle( @vertices );

    my @faces = ( Set::Scalar->new( @F1 ), Set::Scalar->new( @F2 ) );
    for my $i (0..($N-1)) {
        push @faces, Set::Scalar->new( map { $vertices[($i*2+$_) % ($N*2)] } 0..2 );
        push @faces, Set::Scalar->new( map { $vertices[($i*2+$_) % ($N*2)] } 1..3 );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self, $class;
}

sub bipyramid
{
    my( $class, $N ) = @_;
    my $pyramid = $class->pyramid( $N );
    my( $base ) = $pyramid->faces;
    $pyramid->stellate( $base );
    return $pyramid;
}

sub cucurbituril
{
    my( $class, $N ) = @_;
    $N = 5 unless defined $N;

    my $n_letters = int( log( $N * 10 ) / log( 27 ) ) + 1;
    my $name = 'A' x $n_letters;
    my @vertices;
    for (1..($N*10)) {
        push @vertices, $name;
        $name++;
    }

    my $self = Graph::Undirected->new;
    $self->add_vertices( @vertices );

    # Cap faces
    my( @CAP1, @CAP2 );

    my @faces;

    # For each of the clycouril units
    for (0..($N-1)) {
        my @F51 = ( @vertices[($_*10)   .. ($_*10+4)] );
        my @F52 = ( @vertices[($_*10+4) .. ($_*10+7)], $vertices[$_*10] );
        my @F8  = ( @vertices[($_*10+3) .. ($_*10+5)],
                    $vertices[$_*10+9],
                    $vertices[(($_+1)*10+7) % ($N * 10)],
                    $vertices[(($_+1)*10)   % ($N * 10)],
                    $vertices[(($_+1)*10+1) % ($N * 10)],
                    $vertices[$_*10+8] );
        $self->add_cycle( @F51 );
        $self->add_cycle( @F52 );
        $self->add_cycle( @F8 );
        push @faces, Set::Scalar->new( @F51 ),
                     Set::Scalar->new( @F52 ),
                     Set::Scalar->new( @F8 );

        push @CAP1, @vertices[($_*10+1)..($_*10+3)], $vertices[$_*10+8];
        push @CAP2, $vertices[$_*10+9], @vertices[($_*10+5)..($_*10+7)];
    }

    @faces = ( Set::Scalar->new( @CAP1 ),
               Set::Scalar->new( @CAP2 ),
               @faces );

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self, $class;
}

sub pentagonal_trapezohedron
{
    my( $class ) = @_;
    return $class->trapezohedron( 5 );
}

sub pyramid
{
    my( $class, $N ) = @_;

    my $n_letters = int( log( $N + 1 ) / log( 27 ) ) + 1;
    my $name = 'A' x $n_letters;
    my @vertices;
    for (1..($N+1)) {
        push @vertices, $name;
        $name++;
    }

    my $self = Graph::Undirected->new;
    my @faces;
    $self->add_vertices( @vertices );
    $self->add_cycle( @vertices[1..-1] );
    push @faces, Set::Scalar->new( @vertices[1..-1] );

    for (1..$N) {
        $self->add_edge( $vertices[0], $vertices[$_] );
        push @faces, Set::Scalar->new( $vertices[0],
                                       $vertices[$_],
                                       $vertices[($_+1) % ($N+1)] );
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

sub tetrahedron
{
    my( $class ) = @_;

    my @vertices = 'A'..'D';

    my $self = Graph::Undirected->new;
    $self->add_vertices( @vertices );

    my @faces;
    for my $v1 (@vertices) {
        for my $v2 (@vertices) {
            next if $v1 eq $v2;
            $self->add_edge( $v1, $v2 );
        }

        push @faces, Set::Scalar->new( grep { $_ ne $v1 } @vertices );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self, $class;
}

sub trapezohedron
{
    my( $class, $N ) = @_;

    my $n_letters = int( log( $N * 2 + 2 ) / log( 27 ) ) + 1;
    my $name = 'A' x $n_letters;
    my @vertices;
    for (1..($N * 2 + 2)) {
        push @vertices, $name;
        $name++;
    }

    my $self = Graph::Undirected->new;
    $self->add_vertices( @vertices );
    my( $apex1, $apex2, @equator ) = @vertices;
    $self->add_cycle( @equator );

    for (0..$#equator) {
        $self->add_edge( $equator[$_],
                         (($_+1) % 2 ? $apex1 : $apex2) );
    }

    my @faces;
    for my $i (0..$N-1) {
        push @faces, Set::Scalar->new( $apex1,
                                       map { $equator[($i*2+$_) % ($N*2)] } 0..2 );
        push @faces, Set::Scalar->new( $apex2,
                                       map { $equator[($i*2+$_) % ($N*2)] } 1..3 );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self, $class;
}

sub truncated_icosahedron
{
    my( $class ) = @_;
    my $rt = $class->regular_icosahedron;
    $rt->truncate;
    return $rt;
}

sub faces
{
    my( $self ) = @_;
    return map { [ sort $_->members ] } @{$self->get_graph_attribute( 'faces' )};
}

# Deletes a face by replacing it with a single new vertex.
# FIXME: Assumes such face exists.
sub delete_face
{
    my( $self, $face ) = @_;

    my $vertex = join '', sort @$face;
    $self->add_vertex( $vertex );

    for my $member (@$face) {
        for my $neighbour ($self->neighbours( $member )) {
            $self->add_edge( $neighbour, $vertex );
        }
    }

    $self->SUPER::delete_vertices( @$face );

    my $face_set = Set::Scalar( @$face );
    my @faces = grep { !$face_set->is_equal( $_ ) }
                     @{$self->get_graph_attribute( 'faces' )};
    for (@faces) {
        next if $face_set->is_disjoint( $_ );
        $_->delete( @$face );
        $_->insert( $vertex );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return $self;
}

# Handles vertex deletion by merging containing faces
sub delete_vertex
{
    my( $self, $vertex ) = @_;
    $self->SUPER::delete_vertex( $vertex );

    my @containing_faces = grep {  $_->has( $vertex ) }
                                @{$self->get_graph_attribute( 'faces' )};
    my @other_faces      = grep { !$_->has( $vertex ) }
                                @{$self->get_graph_attribute( 'faces' )};

    my $new_face = sum( @containing_faces );
    $new_face->delete( $vertex );

    $self->set_graph_attribute( 'faces', [ @other_faces, $new_face ] );

    return $self;
}

sub stellate
{
    my( $self, @faces ) = @_;
    @faces = $self->faces unless @faces;

    my @faces_now;
    for my $face ($self->faces) {
        if( grep { join( '', sort @$face ) eq join( '', sort @$_ ) } @faces ) {
            # This face has been requested to be stellated
            my $center = join '', @$face;
            $self->add_vertex( $center );
            for my $vertex (@$face) {
                $self->add_edge( $center, $vertex );
            }

            for my $edge ($self->subgraph( $face )->edges) {
                push @faces_now, Set::Scalar->new( $center, @$edge );
            }
        } else {
            # This face has not been requested to be stellated
            push @faces_now, Set::Scalar->new( @$face );
        }
    }

    $self->set_graph_attribute( 'faces', \@faces_now );
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
        $self->SUPER::delete_vertex( $vertex );
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

    my @dual_faces;
    for my $vertex ($self->vertices) {
        my @faces = grep { $_->has( $vertex ) }
                         @{$self->get_graph_attribute( 'faces' )};
        push @dual_faces,
             Set::Scalar->new( map { join '', sort $_->members } @faces );
    }

    $dual->set_graph_attribute( 'faces', \@dual_faces );

    return bless $dual; # TODO: Bless with a class
}

1;
