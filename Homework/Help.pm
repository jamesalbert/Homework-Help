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
        'select name, type, date, earned, possible, grade
            from assignments;', { Slice => {} }
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
    my ( $self, $assignment, $type, $date, $earned, $possible ) = @_;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $individual_grade = $earned / $possible;
    my $sth = $dbh->prepare(
        "insert into assignments values (
            null, \"$assignment\", \"$type\", \"$date\", \"$earned\", \"$possible\", \"$individual_grade\"
        );"
    );
    $sth->execute;
    $dbh->disconnect;
    return $self;
}

sub clear_table {
    my $self = shift;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $sth = $dbh->prepare(
        "delete from assignments;"
    );
    $sth->execute;
    $dbh->disconnect;
    return "table destroyed";
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

sub get_graph {
    my $self = shift;
    my (
        @amount_of_tests,
        @amount_of_homeworks,
        @amount_of_quizes,
        @amount_of_projects,
        @amount_of_extras
    );
    my (
        $total_test_points,
        $total_homework_points,
        $total_quiz_points,
        $total_project_points,
        $total_extra_points
    ) = 0;
    my (
        $overall_test_grade,
        $overall_homework_grade,
        $overall_quiz_grade,
        $overall_project_grade,
        $overall_extra_grade
    );
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=schooldb'
    );
    my $test_groups = $dbh->selectall_arrayref(
        "select earned, possible from assignments
            where type=\"test\";", { Slice => {} }
    );
    my $homework_groups = $dbh->selectall_arrayref(
        "select earned, possible from assignments
            where type=\"homework\";", { Slice => {} }
    );
    my $quiz_groups = $dbh->selectall_arrayref(
        "select earned, possible from assignments
            where type=\"quiz\";", { Slice => {} }
    );
    my $project_groups = $dbh->selectall_arrayref(
        "select earned, possible from assignments
            where type=\"project\";", { Slice => {} }
    );
    my $extra_credit_groups = $dbh->selectall_arrayref(
        "select earned, possible from assignments
            where type=\"extra credit\";", { Slice => {} }
    );
    foreach my $test ( @{$test_groups} ) {
        push @amount_of_tests, "$test->{earned}...$test->{possible}";
        $total_test_points += $test->{earned} / $test->{possible};
    }
    foreach my $homework ( @{$homework_groups} ) {
        push @amount_of_homeworks, "$homework->{earned}...$homework->{possible}";
        $total_homework_points += $homework->{earned} / $homework->{possible};
    }
    foreach my $quiz ( @{$quiz_groups} ) {
        push @amount_of_quizes, "$quiz->{earned}...$quiz->{possible}";
        $total_quiz_points += $quiz->{earned} / $quiz->{possible};
    }
    foreach my $project ( @{$project_groups} ) {
        push @amount_of_projects, "$project->{earned}...$project->{possible}";
        $total_project_points += $project->{earned} / $project->{possible};
    }
    foreach my $extra ( @{$extra_credit_groups} ) {
        push @amount_of_extras, "$extra->{earned}...$extra->{possible}";
        $total_extra_points += $extra->{earned} / $extra->{possible};
    }
    if ($total_test_points != 0) {
        $overall_test_grade = $total_test_points / scalar @amount_of_tests;# if $total_test_points != 0;
    }
    else {
        $overall_test_grade = 0;
    }
    if ($total_homework_points != 0) {
        $overall_homework_grade = $total_homework_points / scalar @amount_of_homeworks;
    }
    else {
        $overall_homework_grade = 0;
    }
    if ($total_quiz_points != 0) {
        $overall_quiz_grade = $total_quiz_points / scalar @amount_of_quizes;
    }
    else {
        $overall_quiz_grade = 0;
    }
    if ($total_project_points != 0) {
        $overall_project_grade = $total_project_points / scalar @amount_of_projects;
    }
    else {
        $overall_project_grade = 0;
    }
    if ($total_extra_points != 0) {
        $overall_extra_grade = $total_extra_points / scalar @amount_of_extras;
    }
    else {
        $overall_extra_grade = 0;
    }
    my @grade_array;
    push @grade_array, $overall_test_grade;
    push @grade_array, $overall_homework_grade;
    push @grade_array, $overall_quiz_grade;
    push @grade_array, $overall_project_grade;
    push @grade_array, $overall_extra_grade;
    return @grade_array;
}

1;
