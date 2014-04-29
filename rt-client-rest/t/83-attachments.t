#!/usr/bin/perl
#
# This script tests whether submited data looks good

use strict;
use warnings;

use Test::More;

use Error qw(:try);
use IO::Socket;
use RT::Client::REST;
use HTTP::Response;
use File::Spec::Functions;
use File::Temp qw(tempfile);
use Data::Dumper;
use Encode;

plan( skip_all => 'This test fails on Windows -- skipping' ) if $^O eq 'MSWin32';

use constant SAVE_BODIES => $ENV{'RELEASE_TESTING'};

my $testfile = "test.png";
my $testfile_path = catfile(t => $testfile);

my $server = IO::Socket::INET->new(
    Type => SOCK_STREAM,
    Reuse => 1,
    Listen => 10,
) or die "Could not set up TCP server: $@";

my $port = $server->sockport;

my $binary_string;
{
    open (my $fh, "<", $testfile_path) or die "Couldn't open $testfile_path $!";
    $binary_string = do { local $/; <$fh>; };
    close $fh;
}

my ($reply_header, $reply_body) = do {
    my $length = length($binary_string);
    $binary_string =~ s/\n/\n         /sg;
    $binary_string .= "\n\n";
    my $body = <<"EOF";
id: 873
Subject: 
Creator: 12
Created: 2013-11-06 07:15:36
Transaction: 1457
Parent: 871
MessageId: 
Filename: prova2.png
ContentType: image/png
ContentEncoding: base64

Headers: Content-Type: image/png; name="prova2.png"
         Content-Disposition: attachment; filename="prova2.png"
         Content-Transfer-Encoding: base64
         Content-Length: $length

Content: $binary_string
EOF
    ("RT/4.0.7 200 Ok", $body);
};

if (SAVE_BODIES) {
    my ($fh, $filename) = tempfile;
    $fh->print($reply_body);
    $fh->close;
    diag("saved reply body to be sent to $filename");
}

my $pid = fork;

if ($pid > 0) {
    plan tests => 4;
    my $rt = RT::Client::REST->new(
            server => "http://localhost:$port",
            timeout => 2,
    );

    # avoid need ot login
    $rt->basic_auth_cb(sub { return });
    my $res = $rt->_submit("ticket/130/attachments/873");
    ok($res->content eq $reply_body, "unparsed form came back ok");

    if (SAVE_BODIES) {
	my ($fh, $filename) = tempfile;
	$fh->print($res->content);
	$fh->close;
	diag("saved returned content to $filename");
    }

    $res = $rt->get_attachment(parent_id => 130, id => 873, undecoded => 1);
    ok($res->{Content} eq $binary_string, "binary files match with undecoded option");

    $res = $rt->get_attachment(parent_id => 130, id => 873, undecoded => 0);

    ok($res->{Content} ne encode("latin1", $binary_string), "binary files don't match when decoded to latin1");
    ok($res->{Content} ne encode("utf-8", $binary_string), "binary files don't match when decoded to utf8");
    
}
elsif (defined($pid)) {
    # serve two requests:
    for (1..3) {
        my $client = $server->accept;
        # emulate the header
        $client->write("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\n\r\n" . $reply_header . "\n\n" . $reply_body);
        $client->close;
    }
}

else {
    die "Could not fork: $!";
}
