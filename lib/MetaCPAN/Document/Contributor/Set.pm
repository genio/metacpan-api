package MetaCPAN::Document::Contributor::Set;

use strict;
use warnings;

use Moose;

extends 'ElasticSearchX::Model::Document::Set';

sub find_release_contributors {
    my ( $self, $author, $name ) = @_;

    my $query = +{
        bool => {
            must => [
                { term => { release_author => $author } },
                { term => { release_name   => $name } },
            ]
        }
    };

    my $res = $self->es->search(
        index => 'contributor',
        type  => 'contributor',
        body  => {
            query => $query,
            size  => 999,
        }
    );
    $res->{hits}{total} or return {};

    return +{
        contributors => [ map { $_->{_source} } @{ $res->{hits}{hits} } ]
    };
}

sub find_author_contributions {
    my ( $self, $pauseid ) = @_;

    my $query = +{ term => { pauseid => $pauseid } };

    my $res = $self->es->search(
        index => 'contributor',
        type  => 'contributor',
        body  => {
            query => $query,
            size  => 999,
        }
    );
    $res->{hits}{total} or return {};

    return +{
        contributors => [ map { $_->{_source} } @{ $res->{hits}{hits} } ]
    };
}

__PACKAGE__->meta->make_immutable;
1;
