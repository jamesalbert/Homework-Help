package Homework::Help;

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub get_assignments {
    my $self = shift;
    my @assignments;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $records = $dbh->selectall_arrayref(
        'select name, date, earned, possible
            from assignments;', { Slice => {} }
    );
    foreach my $attribute ( @{$records} ) {
        push @assignments, $attribute->{name} . '[ITEMBREAK]';
        push @assignments, $attribute->{date} . '[ITEMBREAK]';
        push @assignments, $attribute->{earned} . '[ITEMBREAK]';
        push @assignments, $attribute->{possible} . '[NEWITEM]';
    }
    $dbh->disconnect;
    return @assignments;
}

sub submit_assignment {
    my ( $self, $assignment, $date, $earned, $possible ) = @_;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $sth = $dbh->prepare(
        "insert into assignments values (
            null, \"$assignment\", \"$date\", \"$earned\", \"$possible\"
        );"
    );
    $sth->execute;
    $dbh->disconnect;
    return $self;
}

sub get_grade {
    my $self = shift;
    my $total_points;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $earned_possible = $dbh->selectall_arrayref(
        'select earned, possible
            from assignments;', { Slice => {} }
    );
    foreach my $points ( @{$earned_possible} ) {
        $total_points .= $points->{earned} . '[ITEMBREAK]';
        $total_points .= $points->{possible} . '[NEWITEM]';
    }
    my @split_grades = split(/\[NEWITEM\]/, $total_points);
    my @grade_pair;
    my $overall_points = 0;
    my $iterations = scalar @split_grades;
    for (my $i = 0;$i < $iterations;$i++) {
        @grade_pair = split(/\[ITEMBREAK\]/, $split_grades[$i]);
        $overall_points += ($grade_pair[0]/$grade_pair[1]);
    }
    my $grade = $overall_points / $iterations;
    return $grade;
}

1;
