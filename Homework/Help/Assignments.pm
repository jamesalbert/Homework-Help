package Homework::Help::Assignments;

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub get_assignments {
    my ( $self, %opts ) = @_;
    my @assignments;
    my $dbh     = DBI->connect( 'dbi:SQLite:dbname=schooldb' );
    my $records = $dbh->selectall_arrayref(
        "select name, type, date, earned, possible, grade
            from $opts{table};", { Slice => {} }
    );
    foreach my $attribute ( @{$records} ) {
        push @assignments, $attribute->{name} . '[ITEMBREAK]';
        push @assignments, $attribute->{type} . '[ITEMBREAK]';
        push @assignments, $attribute->{date} . '[ITEMBREAK]';
        push @assignments, $attribute->{earned} . '[ITEMBREAK]';
        push @assignments, $attribute->{possible} . '[ITEMBREAK]';
        push @assignments, $attribute->{grade} . '[NEWITEM]';
    }
    $dbh->disconnect;
    return @assignments;
}

sub submit_assignment {
    my ( $self, $table, $assignment, $type, $date, $earned, $possible ) = @_;
    my $dbh              = DBI->connect( 'dbi:SQLite:dbname=schooldb' );
    my $individual_grade = $earned / $possible;
    my $sth              = $dbh->prepare(
        "insert into $table values (
            null, \"$assignment\", \"$type\", \"$date\", \"$earned\", \"$possible\", \"$individual_grade\"
        );"
    );
    $sth->execute;
    $dbh->disconnect;
    return $self;
}

sub clear_table {
    my $self = shift;
    my $dbh  = DBI->connect( 'dbi:SQLite:dbname=schooldb' );
    my $sth  = $dbh->prepare( "delete from assignments;" );
    $sth->execute;
    $dbh->disconnect;
    return "table destroyed";
}

1;
