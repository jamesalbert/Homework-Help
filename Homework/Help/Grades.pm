package Homework::Help::Grades;

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub get_grade {
    my ( $self, %opts ) = @_;
    my $total_points;
    my $temp_grade;
    my ( @tests, @homeworks, @quizes, @projects, @extras );
    my ($total_test_points,    $total_homework_points, $total_quiz_points,
        $total_project_points, $total_extra_points
    );
    my ($overall_test_grade, $overall_homework_grade,
        $overall_quiz_grade, $overall_project_grade,
        $overall_extra_grade
    );
    my ($weighted_test_grade, $weighted_homework_grade,
        $weighted_quiz_grade, $weighted_project_grade,
        $weighted_extra_grade
    );
    my $total_weighted_grade;
    my $dbh             = DBI->connect( 'dbi:SQLite:dbname=schooldb' );
    my $earned_possible = $dbh->selectall_arrayref(
        "select earned, possible, type
            from $opts{table};", { Slice => {} }
    );
    foreach my $points ( @{$earned_possible} ) {
        $temp_grade = $points->{earned} / $points->{possible};
        if ( $points->{type} eq 'test' ) {
            $total_test_points += $temp_grade;
            push @tests, $temp_grade;
        }
        elsif ( $points->{type} eq 'homework' ) {
            $total_homework_points += $temp_grade;
            push @homeworks, $temp_grade;
        }
        elsif ( $points->{type} eq 'quiz' ) {
            $total_quiz_points += $temp_grade;
            push @quizes, $temp_grade;
        }
        elsif ( $points->{type} eq 'project' ) {
            $total_project_points += $temp_grade;
            push @projects, $temp_grade;
        }
        elsif ( $points->{type} eq 'extra credit' ) {
            $total_extra_points += $temp_grade;
            push @extras, $temp_grade;
        }
    }
    if ( $total_test_points ne 0 ) {
        if ( scalar @tests != 0 ) {
            $overall_test_grade = $total_test_points / scalar @tests;
        }
        else {
            $overall_test_grade = 1;
        }
        $weighted_test_grade = $overall_test_grade * .3;
        $total_weighted_grade += $weighted_test_grade;
    }
    else {
        $overall_test_grade = .3;
        $total_weighted_grade += $weighted_test_grade;

    }

    if ( $total_homework_points ne 0 ) {
        if ( scalar @homeworks != 0 ) {
            $overall_homework_grade
                = $total_homework_points / scalar @homeworks;
        }
        else {
            $overall_homework_grade = 1;
        }
        $weighted_homework_grade = $overall_homework_grade * .1;
        $total_weighted_grade += $weighted_homework_grade;
    }
    else {
        $overall_homework_grade = .1;
        $total_weighted_grade += $weighted_homework_grade;
    }

    if ( $total_quiz_points ne 0 ) {
        if ( scalar @quizes != 0 ) {
            $overall_quiz_grade = $total_quiz_points / scalar @quizes;
        }
        else {
            $overall_quiz_grade = 1;
        }
        $weighted_quiz_grade = $overall_quiz_grade * .2;
        $total_weighted_grade += $weighted_quiz_grade;
    }
    else {
        $overall_quiz_grade = .2;
        $total_weighted_grade += $weighted_quiz_grade;
    }

    if ( $total_project_points ne 0 ) {
        if ( scalar @projects != 0 ) {
            $overall_project_grade = $total_project_points / scalar @projects;
        }
        else {
            $overall_project_grade = 1;
        }
        $weighted_project_grade = $overall_project_grade * .3;
        $total_weighted_grade += $weighted_project_grade;
    }
    else {
        $overall_project_grade = .3;
        $total_weighted_grade += $weighted_project_grade;
    }

    if ( $total_extra_points ne 0 ) {
        if ( scalar @extras != 0 ) {
            $overall_extra_grade = $total_extra_points / scalar @extras;
        }
        else {
            $overall_extra_grade = 1;
        }
        $weighted_extra_grade = $overall_extra_grade * .1;
        $total_weighted_grade += $weighted_extra_grade;
    }
    else {
        $overall_extra_grade = .1;
        $total_weighted_grade += $weighted_extra_grade;
    }

    return $total_weighted_grade;
}

sub get_graph {
    my ( $self, %opts ) = @_;
    my (@amount_of_tests,    @amount_of_homeworks, @amount_of_quizes,
        @amount_of_projects, @amount_of_extras
    );
    my ($total_test_points,    $total_homework_points, $total_quiz_points,
        $total_project_points, $total_extra_points
    ) = 0;
    my ($overall_test_grade, $overall_homework_grade,
        $overall_quiz_grade, $overall_project_grade,
        $overall_extra_grade
    );
    my ($weighted_test_grade, $weighted_homework_grade,
        $weighted_quiz_grade, $weighted_project_grade,
        $weighted_extra_grade,
    ) = 0;
    my $dbh         = DBI->connect( 'dbi:SQLite:dbname=schooldb' );
    my $test_groups = $dbh->selectall_arrayref(
        "select earned, possible from $opts{table}
            where type=\"test\";", { Slice => {} }
    );
    my $homework_groups = $dbh->selectall_arrayref(
        "select earned, possible from $opts{table}
            where type=\"homework\";", { Slice => {} }
    );
    my $quiz_groups = $dbh->selectall_arrayref(
        "select earned, possible from $opts{table}
            where type=\"quiz\";", { Slice => {} }
    );
    my $project_groups = $dbh->selectall_arrayref(
        "select earned, possible from $opts{table}
            where type=\"project\";", { Slice => {} }
    );
    my $extra_credit_groups = $dbh->selectall_arrayref(
        "select earned, possible from $opts{table}
            where type=\"extra credit\";", { Slice => {} }
    );
    foreach my $test ( @{$test_groups} ) {
        push @amount_of_tests, "$test->{earned}...$test->{possible}";
        $total_test_points += $test->{earned} / $test->{possible};
    }
    foreach my $homework ( @{$homework_groups} ) {
        push @amount_of_homeworks,
            "$homework->{earned}...$homework->{possible}";
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
    if ( $total_test_points != 0 ) {
        $overall_test_grade = $total_test_points /
            scalar @amount_of_tests;    # if $total_test_points != 0;
        $weighted_test_grade = $overall_test_grade * .3;
    }
    else {
        $overall_test_grade = 0;
    }
    if ( $total_homework_points != 0 ) {
        $overall_homework_grade
            = $total_homework_points / scalar @amount_of_homeworks;
        $weighted_homework_grade = $overall_homework_grade * .1;
    }
    else {
        $overall_homework_grade = 0;
    }
    if ( $total_quiz_points != 0 ) {
        $overall_quiz_grade  = $total_quiz_points / scalar @amount_of_quizes;
        $weighted_quiz_grade = $overall_quiz_grade * .2;
    }
    else {
        $overall_quiz_grade = 0;
    }
    if ( $total_project_points != 0 ) {
        $overall_project_grade
            = $total_project_points / scalar @amount_of_projects;
        $weighted_project_grade = $overall_project_grade * .3;
    }
    else {
        $overall_project_grade = 0;
    }
    if ( $total_extra_points != 0 ) {
        $overall_extra_grade = $total_extra_points / scalar @amount_of_extras;
        $weighted_extra_grade = $overall_extra_grade * .1;
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
