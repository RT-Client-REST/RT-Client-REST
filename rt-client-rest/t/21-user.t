use strict;
use warnings;

use Test::More tests => 26;
use Test::Exception;

use constant METHODS => (
    'new', 'to_form', 'from_form',
    'rt_type', 'id',
    
    # attributes:
    'name', 'password', 'real_name', 'gecos',
    'priveleged', 'email_address',  'comments', 'organization',
    'address_one', 'address_two', 'city', 'state', 'zip', 'country',
    'home_phone', 'work_phone', 'cell_phone', 'pager'
);

BEGIN {
    use_ok('RT::Client::REST::User');
}

my $user;

lives_ok {
    $user = RT::Client::REST::User->new;
} 'User can get successfully created';

for my $method (METHODS) {
    can_ok($user, $method);
}

ok('user' eq $user->rt_type);

# vim:ft=perl:
