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
    use GD::Graph::bars3d;
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
    ) = 1;
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
    my $overall_test_grade = $total_test_points - 1 / scalar @amount_of_tests if $total_test_points ne 0;
    my $overall_homework_grade = $total_homework_points - 1 / scalar @amount_of_homeworks if $total_homework_points ne 0;
    my $overall_quiz_grade = $total_quiz_points - 1 / scalar @amount_of_quizes if $total_quiz_points ne 0;
    my $overall_project_grade = $total_project_points - 1 / scalar @amount_of_projects if $total_project_points ne 0;
    my $overall_extra_grade = $total_extra_points - 1 / scalar @amount_of_extras if $total_extra_points ne 0;
    my @data = (
        ["tests $overall_test_grade", "homework $overall_homework_grade", "quizes $overall_quiz_grade", "projects $overall_project_grade", "extra credit $overall_extra_grade"],
        [$overall_test_grade, $overall_homework_grade, $overall_quiz_grade, $overall_project_grade, $overall_extra_grade]
        #[100, 200, 300, 400, 500]
    );
    my $graph = GD::Graph::bars3d->new(800, 600);
    $graph->set(
        x_label => "Assignment Types",
        y_label => "Percentile Range",
        title   => "How Good You're Doing In Different Respects",
    );
    my $gd = $graph->plot( \@data );
    open(IMG, '>public/graph.png') or die $!;
    binmode IMG;
    print IMG $gd->png;
}

1;
