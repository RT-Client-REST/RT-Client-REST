#!perl
# PODNAME: RT::Client::REST::HTTPClient
# ABSTRACT: Subclass LWP::UserAgent in order to support basic authentication.

use strict;
use warnings;

package RT::Client::REST::HTTPClient;

use base 'LWP::UserAgent';

=head1 METHODS

=over 4

=item get_basic_credentials

Returns basic authentication credentials

=cut

sub get_basic_credentials {
    my $self = shift;

    if ($self->basic_auth_cb) {
        return $self->basic_auth_cb->(@_);
    }
    else {
        return;
    }
}

=item basic_auth_cb

Gets/sets basic authentication callback

=cut

sub basic_auth_cb {
    my $self = shift;

    if (@_) {
        $self->{basic_auth_cb} = shift;
    }

    return $self->{basic_auth_cb};
}

=pod

=back

1;
