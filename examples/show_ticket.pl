#!/usr/bin/perl
#
# show_ticket.pl -- retrieve an RT ticket.

use strict;
use warnings;

use Try::Tiny;
use RT::Client::REST;
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

RT::Client::REST::Object->use_single_rt($rt);
RT::Client::REST::Object->use_autoget(1);
RT::Client::REST::Object->use_autosync(1);

my $ticket;
my $id = shift(@ARGV);
try {
    $ticket = RT::Client::REST::Ticket->new( id => $id, );
}
catch {
    die $_ unless blessed $_ && $_->can('rethrow');
    if ( $_->isa('RT::Client::REST::UnauthorizedActionException') ) {
        die "You are not authorized to view ticket #$id\n";
    }
    if ( $_->isa('Exception::Class::Base') ) {
        die ref($_), ": ", $_->message || $_->description, "\n";
    }
};

use Data::Dumper;
print Dumper($ticket);

for my $cf ( sort $ticket->cf ) {
    print "Custom field '$cf'=", $ticket->cf($cf), "\n";
}
