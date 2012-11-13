#!/usr/bin/env perl

use strict;
use warnings;
use Mojolicious::Lite;
use Homework::Help;

get '/home' => sub {
    my $self = shift;
    $self->render( 'home' );
};

get '/homejs' => sub {
    my $self = shift;
    $self->render( 'homejs' );
};

get '/get/grades' => sub {
    my $self         = shift;
    my $work_sheet;
    my $user         = Homework::Help->new;
    my @response     = $user->get_assignments;
    foreach my $attribute ( @response ) {
        $work_sheet .= $attribute;
    }
    $self->render( text => $work_sheet );
};

get '/submit/assignment' => sub {
    my $self       = shift;
    my $user       = Homework::Help->new;
    my $assignment = $self->param( 'a' );
    my $date       = $self->param( 'd' );
    my $earned     = $self->param( 'e' );
    my $possible   = $self->param( 'p' );
    $user->submit_assignment(
        $assignment, $date, $earned, $possible
    );
    $self->render( text => 'assignment submitted' );
};

get '/get/grade' => sub {
    my $self           = shift;
    my $total_points;
    my $user           = Homework::Help->new;
    my @two_points     = $user->get_grade;
    foreach my $points ( @two_points ) {
        $total_points .= $points;
    }
    $self->render( text => $total_points );
};

app->start;

__DATA__

@@ home.html.ep

<!DOCTYPE html>
<html>
<head>

<script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
<script src="/homejs"></script>

</head>
<body>
<style>
input {position: absolute;left: 175px}
</style>
<h4>Grade Checker</h4>

Assignment: <input id="assignment" type="text"></input></br>
Date: <input id="date" type="text"></input></br>
Points Earned: <input id="earned" type="text"></input></br>
Points Possible: <input id="possible" type="text"></input></br>
<button id="submit_assignment" type="button">Submit Assignment</button>

<table id="grade_sheet" border="1">
<tr>
<th>ASSIGNMENT</th>
<th>DATE</th>
<th>POINTS EARNED</th>
<th>POINTS POSSIBLE</th>
</tr>
</table></br>

<input id="grade" type="text" value="0"></input>

</body>
</html>

@@ homejs.html.ep

$(document).ready(function() {
    $.get('http://localhost:3000/get/grades',
    function(assignments) {
        var record = assignments.split('[NEWITEM]');
        var list_length = record.length;
        for (var i = 0;i < list_length - 1;i++) {
            var attribute = record[i].split('[ITEMBREAK]');
            $('#grade_sheet').append(
                '<tr><th>'+attribute[0]+'</th><th>'+attribute[1]+'</th><th>'+attribute[2]+'</th><th>'+attribute[3]+'</th></tr>'
            );
        }
    });
    $.get('http://localhost:3000/get/grade',
    function(response) {
        var grade;
        if (response > 100) {
            grade = "A++";
        }
        else if (response >= .90 && response <= 100) {
            grade = "A";
        }
        else if (response >= .80 && response < .90) {
            grade = "B";
        }
        else if (response >= .70 && response < .80) {
            grade = "C";
        }
        else if (response >= .60 && response < .70) {
            grade = "D";
        }
        else {
            grade = "F";
        }
        $('#grade').val(grade+' '+response)
            .attr('disabled', 'disabled');
    });
    $('#submit_assignment').click(function() {
        var assignment = $('#assignment').val();
        var date = $('#date').val();
        var earned = $('#earned').val();
        var possible = $('#possible').val();
        if ( assignment != '' && date != '' && earned != '' && possible != '' ) {
            $.get('http://localhost:3000/submit/assignment?a='+assignment+'&d='+date+'&e='+earned+'&p='+possible,
            function(status) {
                alert(status);
                alert("The page will now reload");
                window.location.reload();
            });
        }
        else {
            alert('Wrong or no data given');
        }
    });
});
