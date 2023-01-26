package Graph::Geometric;

use strict;
use warnings;
use feature qw(current_sub);

# ABSTRACT: Create and work with geometric graphs
# VERSION

use parent 'Graph::Undirected', 'Exporter';

our @polygon_names = (
    '', 'mono', 'di', 'tri', 'tetra', 'penta', 'hexa', 'hepta', 'octa', 'nona', 'deca',
    'undeca', 'dodeca', 'trideca', 'tetradeca', 'pentadeca', 'hexadeca', 'heptadeca', 'octadeca', 'nonadeca',
    'icosa', 'henicosa', 'docosa', 'tricosa', 'tetracosa', 'pentacosa', 'hexacosa', 'heptacosa', 'octacosa', 'nonacosa',
    'triaconta', 'hentriaconta', 'dotriaconta', 'tritriaconta', 'tetratriaconta', 'pentatriaconta', 'hexatriaconta', 'heptatriaconta',
    'octatriaconta', 'nonatriaconta', 'tetraconta',
);
my @subs = qw(
    antiprism
    bipyramid
    cucurbituril
    cupola
    octahedron
    pentagonal_trapezohedron
    prism
    pyramid
    regular_icosahedron
    rotunda
    stellated
    trapezohedron
    truncated
    truncated_icosahedron
);
push @subs, map { $_ . 'gonal' } @polygon_names[1..$#polygon_names];

our @EXPORT = @subs;

use List::Util qw( sum );
use Set::Scalar;

sub AUTOLOAD {
    our $AUTOLOAD;
    my $call = $AUTOLOAD;
    $call =~ s/.*:://;
    return if $call eq 'DESTROY' || $call !~ /gonal$/;
    my $N = _polygon_name_to_number( $call );
    return unless defined $N;
    $_[0]->($N);
}

=head1 SYNOPSIS

    use Graph::Geometric;

    # Generate a truncated regular icosahedron
    my $g = regular_icosahedron->truncated;

    # Count the faces
    print scalar $g->faces;

=head1 DESCRIPTION

C<Graph::Geometric> is an extension of C<Graph> to support working with geometric (topologic) graphs.
In addition to vertices and edges, C<Graph::Geometric> has a concept of faces to ease handling of geometric graphs.
C<Graph::Geometric> does not provide coordinates for vertices as it is supposed to be used for topology analysis of geometric shapes.

As of now, C<Graph::Geometric> does not allow for arbitrary graph construction.
Geometric graphs have to be built from simple polyhedra (constructors listed below) or derived from them by using modifiers such as stellation or truncation.
Removal of vertices and faces is also supported.

=head2 ON THE STABILITY OF API

As C<Graph::Geometric> is in its early stages of development, not much of API stability can be promised.
In particular, method names are likely to be changed for the sake of homogeneity.
Names of generated vertices and order of faces returned by C<faces()> as well are likely to change.
Some syntax sugar may also appear.

=head1 CONSTRUCTORS

=method C<antiprism>

Given N, creates an N-gonal antiprism.
If N is not given, returns a code reference to itself.

=cut

sub antiprism
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my @vertices = _names( $N * 2 );

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
    return bless $self;
}

=method C<bipyramid>

Given N, creates an N-gonal bipyramid.
If N is not given, returns a code reference to itself.

=cut

sub bipyramid
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my $pyramid = pyramid( $N );
    my( $base ) = $pyramid->faces;
    $pyramid->stellate( $base );
    return $pyramid;
}

=method C<cucurbituril>

Given N, creates a geometric graph representing chemical structure of cucurbit[N]uril.
Cucurbiturils do not exacly fit the definition of polyhedra, but have nevertheless interesting structures.
If N is not given, returns a cucurbit[5]uril, the smallest naturally occurring cucurbituril.

=cut

sub cucurbituril
{
    my( $N ) = @_;
    $N = 5 unless defined $N;

    my @vertices = _names( $N * 10 );

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
    return bless $self;
}

=method C<cupola>

Given N, creates an N-gonal cupola.
If N is not given, returns a code reference to itself.

=cut

sub cupola
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my $prism = prism( $N*2 );
    my( $face ) = grep { scalar( @$_ ) == $N*2 } $prism->faces;
    my @face = _face_in_order( $prism, @$face );
    while( @face ) {
        $prism->delete_edge( shift @face, shift @face );
    }
    return $prism;
}

=method C<octahedron>

Creates a regular octahedron.

=cut

sub octahedron()
{
    return bipyramid( 4 );
}

=method C<pentagonal_trapezohedron>

Creates a pentagonal trapezohedron.
This method may be removed later on in favour of more general C<trapezohedron> method.

=cut

sub pentagonal_trapezohedron()
{
    return trapezohedron( 5 );
}

=method C<prism>

Given N, creates an N-gonal prism.
If N is not given, returns a code reference to itself.

=cut

sub prism
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my @vertices = _names( $N * 2 );
    my @F1 = @vertices[0..($N-1)];
    my @F2 = @vertices[$N..$#vertices];

    my $self = Graph::Undirected->new;
    my @faces;
    $self->add_cycle( @F1 );
    $self->add_cycle( @F2 );
    push @faces, Set::Scalar->new( @F1 ), Set::Scalar->new( @F2 );

    for (0..($N-1)) {
        $self->add_edge( $F1[$_], $F2[$_] );
        push @faces, Set::Scalar->new( $F1[$_], $F2[$_],
                                       $F1[($_+1) % $N],
                                       $F2[($_+1) % $N] );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self;
}

=method C<pyramid>

Given N, creates an N-gonal pyramid.
If N is not given, returns a code reference to itself.

=cut

sub pyramid
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my @vertices = _names( $N + 1 );
    my( $apex, @base ) = @vertices;

    my $self = Graph::Undirected->new;
    my @faces;
    $self->add_vertices( @vertices );
    $self->add_cycle( @base );
    push @faces, Set::Scalar->new( @base );

    for (0..($N-1)) {
        $self->add_edge( $apex, $base[$_] );
        push @faces, Set::Scalar->new( $apex,
                                       $base[$_],
                                       $base[($_+1) % $N] );
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return bless $self;
}

=method C<regular_dodecahedron>

Creates a regular dodecahedron.
Word "regular" may in future disappear from method's name.

=cut

sub regular_dodecahedron()
{
    my $pt = pentagonal_trapezohedron;
    $pt->truncate( 'A', 'B' );
    return $pt;
}

=method C<regular_icosahedron>

Creates a regular icosahedron.
Word "regular" may in future disappear from method's name.

=cut

sub regular_icosahedron()
{
    return regular_dodecahedron->dual;
}

=method C<rotunda>

Given N, creates an N-gonal rotunda.
If N is not given, returns a code reference to itself.

=cut

sub rotunda
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my $cupola = cupola( $N );
    my $face;
    for ($cupola->faces) {
        next unless scalar( @$_ ) == $N;
        next unless sum( map { $cupola->degree($_) } @$_ ) == $N*4;
        $face = $_;
        last;
    }
    $cupola->face_dualify( @$face );

    return $cupola;
}

=method C<tetrahedron>

Creates a regular tetrahedron.

=cut

sub tetrahedron()
{
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
    return bless $self; # TODO: Bless with class?
}

=method C<trapezohedron>

Creates an N-gonal trapezohedron.
If N is not given, returns a code reference to itself.

=cut

sub trapezohedron
{
    my( $N ) = @_;
    return __SUB__ unless defined $N;

    my @vertices = _names( $N * 2 + 2 );

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
    return bless $self; # TODO: Bless with class?
}

=method C<truncated_icosahedron>

Creates a truncated icosahedron.

=cut

sub truncated_icosahedron()
{
    return regular_icosahedron->truncate;
}

=head1 ACCESSORS

=method C<faces>

Returns an array of arrays listing vertices in each of polyhedron's faces.
Vertex lists are returned sorted, they do not maintain the order of vertices in faces.

=cut

sub faces
{
    my( $self ) = @_;
    return map { [ sort $_->members ] } @{$self->get_graph_attribute( 'faces' )};
}

=head1 GRAPH METHODS

=method C<deep_copy>

Creates a deep copy of a Graph::Geometric object.

=cut

sub deep_copy
{
    my( $self ) = @_;
    my $copy = $self->SUPER::deep_copy;
    return bless $copy; # FIXME: Bless with the same class
}

=method C<delete_edge>

Deletes an edge by merging its vertices.
Given edge is assumed to exist, a check will be implemented later.
Modifies and returns the original object.

=cut

sub delete_edge
{
    my( $self, $vertex1, $vertex2 ) = @_;
    my @neighbours = ( $self->neighbours( $vertex1 ),
                       $self->neighbours( $vertex2 ) );
    $self->SUPER::delete_vertex( $vertex1 ); # delete_vertices() does not work
    $self->SUPER::delete_vertex( $vertex2 );

    my $vertex = join '', sort ( $vertex1, $vertex2 );

    for (@neighbours) {
        next if $_ eq $vertex1;
        next if $_ eq $vertex2;
        $self->add_edge( $vertex, $_ );
    }

    my @faces;
    for (@{$self->get_graph_attribute( 'faces' )}) {
        if( $_->has( $vertex1 ) ) {
            $_->delete( $vertex1 );
            $_->insert( $vertex );
        }
        if( $_->has( $vertex2 ) ) {
            $_->delete( $vertex2 );
            $_->insert( $vertex );
        }
        push @faces, $_;
    }

    $self->set_graph_attribute( 'faces', \@faces );
    return $self;
}

=method C<delete_face>

Deletes a given face from polyhedra.
A face is defined by an unordered list of vertices.
Given face is assumed to exist, a check will be implemented later.
Modifies and returns the original object.

=cut

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

=method C<delete_vertex>

Handles vertex deletion by merging neighbouring faces.
Modifies and returns the original object.

=cut

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

=head1 GEOMETRIC METHODS

=cut

sub carve_edge
{
    my( $self, @edge ) = @_;

    $self->SUPER::delete_edge( @edge );
    my $vertex = join '', sort @edge;

    # Add new vertex in between the given ones
    $self->add_path( $edge[0], $vertex, $edge[1] );

    # Update all faces containing the edge to also have the new vertex
    for (@{$self->get_graph_attribute( 'faces' )}) {
        next unless $_->has( $edge[0] ) && $_->has( $edge[1] );
        $_->insert( $vertex );
    }

    return $self;
}

sub face_dualify
{
    my( $self, @face ) = @_;

    # Remove the to-be-dualified face
    my @faces;
    for my $face (@{$self->get_graph_attribute( 'faces' )}) {
        next if join( '', sort $face->members ) eq join( '', sort @face );
        push @faces, $face;
    }

    @face = _face_in_order( $self, @face );
    my @new_vertices;
    for (0..$#face) {
        my @edge = sort ( $face[$_], $face[($_+1) % scalar @face] );
        $self->carve_edge( @edge );
        my $vertex = join '', @edge;
        push @new_vertices, join '', @edge;
        push @faces, Set::Scalar->new( $vertex, @edge );
    }
    $self->add_cycle( @new_vertices );
    push @faces, Set::Scalar->new( @new_vertices );

    $self->set_graph_attribute( 'faces', \@faces );
}

=method C<stellate>

Given a polyhedron and a list of faces, performs stellation of specified faces.
If no faces are given, all faces are stellated.
Modifies and returns the original object.

=cut

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

=method C<truncate>

Given a polyhedron and a list of vertices, performs truncation of specified vertices.
If no vertices are given, all vertices are stellated.
Modifies and returns the original object.

=cut

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

    return $self;
}

=method C<dual>

Given a polyhedron, returns its dual as a new object.
The original object is not modified.

=cut

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

=method C<stellated>

Copies the given polyhedron, stellates all its faces and returns the stellated polyhedron.

=cut

sub stellated($)
{
    return $_[0]->deep_copy->stellate;
}

=method C<truncated>

Copies the given polyhedron, truncates all its vertices and returns the truncated polyhedron.

=cut

sub truncated($)
{
    return $_[0]->deep_copy->truncate;
}

sub _face_in_order
{
    my( $graph, @face ) = @_;
    my $subgraph = $graph->subgraph( \@face );
    my @order;
    while( $subgraph->vertices ) {
        my $next;
        ( $next ) = sort grep { $subgraph->degree( $_ ) == 1 } $subgraph->vertices;
        ( $next ) = sort $subgraph->vertices unless $next;
        push @order, $next;
        $subgraph->SUPER::delete_vertex( $next );
    }
    return @order;
}

sub _names
{
    my( $N ) = @_;

    my $n_letters = int( log( $N ) / log( 27 ) ) + 1;
    my $name = 'A' x $n_letters;
    my @names;
    for (1..$N) {
        push @names, $name;
        $name++;
    }

    return @names;
}

# TODO: Implement according to https://en.wikipedia.org/wiki/Polygon#Naming
# Not all synonyms are supported yet.
sub _polygon_name_to_number
{
    my( $name ) = @_;
    $name =~ s/gon(al)?$//;
    my( $number ) = grep { $name eq $polygon_names[$_] } 0..$#polygon_names;
    return $number;
}

1;
