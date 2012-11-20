package Homework::Help::Accounts;

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub get_user {
    my ( $self, %opts ) = @_;
    my $try_again = 'Wrong username or password';
    my $dbh       = DBI->connect( 'dbi:SQLite:dbname=schooldb' );

    my $profiles = $dbh->selectall_arrayref(
        "select name, password from users
            where name=\"$opts{user}\"
                and password=\"$opts{pass}\";",
        { Slice => {} }
    );

    $dbh->disconnect;

    foreach my $user ( @{$profiles} ) {
        if (    $opts{user} eq $user->{name}
            and $opts{pass} eq $user->{password} )
        {
            return $opts{user};
        }
    }
}

sub create_account {
    my ( $self, %opts ) = @_;
    my $available = 0;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );

    my $users = $dbh->selectall_arrayref(
        'select name from users;', { Slice => {} }
    );

    foreach my $unavailable_user ( @{$users} ) {
        if ( $opts{username} eq $unavailable_user->{name} ) {
            return 'username already taken';
            $available = 0;
            last;
        }
        else {
            $available = 1;
        }
    }

    if ( $available == 1 ) {
        my $sth = $dbh->prepare(
            "insert into users values (
                null, \"$opts{username}\", \"$opts{password}\"
            )"
        );
        $sth->execute or return 'account not created for some reason. how you screwed up creating an account, i have no idea';
        $dbh->disconnect;
        return 'account created';
    }
    else {
        $dbh->disconnect;
        return 'account not created';
    }
}

1;
