#!/usr/bin/perl
#
# This script tests whether submited data looks good

use strict;
use warnings;

use Test::More;

use Error qw(:try);
use IO::Socket;
use RT::Client::REST;

my $server = IO::Socket::INET->new(
    Type => SOCK_STREAM,
    Reuse => 1,
    Listen => 10,
) or die "Could not set up TCP server: $@";

my $port = $server->sockport;

my $pid = fork;
if ($pid > 0) {
    plan tests => 1;
    my $buf;
    my $client = $server->accept;
    my $data;
    while (<$client>) {
        $data .= $_;
    }
    unlike($data, qr/ARRAY\(/, "Avoid stringify objects when sending a request");

    $client->write(
"RT/42foo 200 this is a fake successful response header
header line 1
header line 2

response text");
} elsif (defined($pid)) {
    my $rt = RT::Client::REST->new(
            server => "http://localhost:$port",
            timeout => 2,
    );
    my $res = $rt->_submit("ticket/1", "aaaa", {
            user => 'a',
            pass => 'b',
        });
} else {
    die "Could not fork: $!";
}

# vim:ft=perl:
