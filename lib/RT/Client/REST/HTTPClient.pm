#!perl
# PODNAME: RT::Client::REST::HTTPClient
# ABSTRACT: Subclass LWP::UserAgent in order to support basic authentication.

use strict;
use warnings;

package RT::Client::REST::HTTPClient;

use base 'LWP::UserAgent';

sub get_basic_credentials {
    my $self = shift;

    if ($self->basic_auth_cb) {
        return $self->basic_auth_cb->(@_);
    } else {
        return;
    }
}

sub basic_auth_cb {
    my $self = shift;

    if (@_) {
        $self->{basic_auth_cb} = shift;
    }

    return $self->{basic_auth_cb};
}

1;
