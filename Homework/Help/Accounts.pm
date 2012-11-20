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
        "select user, pass from profiles
            where user=\"$opts{user}\"
                and pass=\"$opts{pass}\";",
        { Slice => {} }
    );

    $dbh->disconnect;

    foreach my $user ( @{$profiles} ) {
        if (    $opts{user} eq $user->{user}
            and $opts{pass} eq $user->{pass} )
        {
            return $opts{user};
        }
    }
}

sub create_account {
    my ( $self, %opts ) = @_;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $sth = $dbh->prepare(
        "insert into profiles values (
            null, \"$opts{username}\", \"$opts{password}\"
        )"
    );

    $sth->execute;

    $sth = $dbh->prepare(
        "create table $opts{username} (
            id integer primary key autoincrement,
            name varchar(255),
            type varchar(255),
            date varchar(255),
            earned varchar(255),
            possible varchar(255),
            grade varchar(255)
        );"
    );

    $sth->execute or return 'account not created for some reason. how you screwed up creating an account, i have no idea';
    $dbh->disconnect;
    return 'account created';
}

1;
