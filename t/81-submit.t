#!perl
# vim:ft=perl:
#
# This script tests whether submited data looks good

use strict;
use warnings;

use Test::More;

use IO::Socket;
use RT::Client::REST;

my $server = IO::Socket::INET->new(
    Type   => SOCK_STREAM,
    Reuse  => 1,
    Listen => 10,
) or die "Could not set up TCP server: $@";

my $port = $server->sockport;

my $pid = fork;
die "cannot fork: $!" unless defined $pid;

if ( 0 == $pid ) {    # Child
    my $buf;
    my $client = $server->accept;
    $client->write(
        "RT/42foo 200 this is a fake successful response header
header line 1
header line 2

response text"
    );
    exit;
}

plan tests => 1;
my $rt = RT::Client::REST->new(
    server  => "http://127.0.0.1:$port",
    timeout => 2,
);
my $res = $rt->_submit(
    'ticket/1',
    undef,
    {
        user => 'a',
        pass => 'b',
    }
);
unlike(
    $res->{_content},
    qr/this is a fake successful response header/,
    'Make sure response content doesn\'t contain headers'
);

