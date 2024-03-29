#!/usr/bin/perl
#
# show_ticket.pl -- retrieve an RT ticket.

use strict;
use warnings;

use Try::Tiny;
use RT::Client::REST;
use RT::Client::REST::Attachment;
use RT::Client::REST::Ticket;

unless ( @ARGV >= 3 ) {
    die "Usage: $0 username password ticket_id\n";
}

my $rt =
  RT::Client::REST->new( server => ( $ENV{RTSERVER} || 'http://rt.cpan.org' ),
  );
$rt->login(
    username => shift(@ARGV),
    password => shift(@ARGV),
);

my $ticket = RT::Client::REST::Ticket->new( rt => $rt, id => shift(@ARGV) );

my $results;
try {
    $results = $ticket->attachments;
}
catch {
    die $_ unless blessed $_ && $_->can('rethrow');
    if ( $_->isa('Exception::Class::Base') ) {
        die ref($_), ": ", $_->message || $_->description, "\n";
    }
};

my $count = $results->count;
print "There are $count results that matched your query\n";

my $iterator = $results->get_iterator;
while ( my $att = &$iterator ) {
    print "Id: ", $att->id, "; Subject: ", $att->subject, "\n";
}
