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
    my $type       = $self->param( 't' );
    my $date       = $self->param( 'd' );
    my $earned     = $self->param( 'e' );
    my $possible   = $self->param( 'p' );
    $user->submit_assignment(
        $assignment, $type, $date, $earned, $possible
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

get '/get/graph' => sub {
    my $self     = shift;
    my $user     = Homework::Help->new;
    my @response = $user->get_graph;
    my $grade_list;
    foreach my $grade ( @response ) {
        $grade_list =~ s/((\d+)\.(\d\d))\d+/$1/
            if $grade_list =~ m/((\d+)\.(\d\d))\d+/;
        $grade_list .= $grade . ',';
    }
    $self->render( text => $grade_list );
};

get '/test' => sub {
    my $self = shift;
    $self->render( 'slickred' );
};

get '/learnmore' => sub {
    my $self = shift;
    $self->render( 'learnmore' );
};

get '/clear/table' => sub {
    my $self     = shift;
    my $user     = Homework::Help->new;
    my $response = $user->clear_table;
    $self->render( text => $response );
};

app->start;

__DATA__

@@ homejs.html.ep

jQuery(document).ready(function() {
    jQuery.get('http://localhost:3000/get/grades',
    function(assignments) {
        var record = assignments.split('[NEWITEM]');
        var list_length = record.length;
        for (var i = 0;i < list_length - 1;i++) {
            var attribute = record[i].split('[ITEMBREAK]');
            var indi_grade = attribute[5];
            if (indi_grade > 1) {
                indi_grade = "A++";
            }
            else if (indi_grade >= .90 && indi_grade <= 1) {
                indi_grade = "A";
            }
            else if (indi_grade >= .80 && indi_grade < .90) {
                indi_grade = "B";
            }
            else if (indi_grade >= .70 && indi_grade < .80) {
                indi_grade = "C";
            }
            else if (indi_grade >= .60 && indi_grade < .70) {
                indi_grade = "D";
            }
            else {
                indi_grade = "F";
            }
            jQuery('#grade_sheet').append(
                '<tr><th>'+attribute[0]+'</th><th>'+attribute[1]+'</th><th>'+attribute[2]+'</th><th>'+attribute[3]+'</th><th>'+attribute[4]+'</th><th>'+indi_grade+'</th></tr>'
            );
        }
    });
    jQuery.get('http://localhost:3000/get/grade',
    function(response) {
        var grade;
        if (response > 1) {
            grade = "A++";
        }
        else if (response >= .90 && response <= 1) {
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
        jQuery('#grade').val(grade+' '+response)
            .attr('disabled', 'disabled');
    });
    jQuery('#submit_assignment').click(function() {
        var assignment = jQuery('#assignment').val();
        var type = jQuery('#type').val();
        var date = jQuery('#date').val();
        var earned = jQuery('#earned').val();
        var possible = jQuery('#possible').val();
        if ( assignment != '' && type != '' && date != '' && earned != '' && possible != '' ) {
            jQuery.get('http://localhost:3000/submit/assignment?a='+assignment+'&t='+type+'&d='+date+'&e='+earned+'&p='+possible,
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
    jQuery.get('http://localhost:3000/get/graph',
    function(grade_list) {
        var grade = grade_list.split(',');
        var layout = new PlotKit.Layout("bar", {});
        layout.addDataset("sqrt", [[0, grade[0]], [1, grade[1]], [2, grade[2]], [3, grade[3]], [4, grade[4]]]);
        layout.evaluate();
        var canvas = MochiKit.DOM.getElement("graph");
        var plotter = new PlotKit.SweetCanvasRenderer(canvas, layout, {});
        plotter.render();
    });
    jQuery('#clear_table').click(function() {
        jQuery.get('http://localhost:3000/clear/table',
        function(response) {
            alert(response);
            window.location.reload();
        });
    });
});

@@ home.html.ep

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Bootstrap, from Twitter</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <!-- TODO: add bootstrap or boottheme generated css file beow -->
    <link href="/boottheme.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
      .sidebar-nav {
        padding: 9px 0;
      }
    </style>
    <link href="http://twitter.github.com/bootstrap/assets/css/bootstrap-responsive.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Fav and touch icons -->
    <link rel="shortcut icon" href="../assets/ico/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png">
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="#">MojoVicious Grade Pro</a>
          <div class="nav-collapse collapse">
            <p class="navbar-text pull-right">
              Logged in as <a href="#" class="navbar-link">Username</a>
            </p>
            <ul class="nav">
              <li class="active"><a href="#">Home</a></li>
              <li><a href="#about">About</a></li>
              <li><a href="#contact">Contact</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span3">
        </div><!--/span-->
        <div class="span9">
          <div class="hero-unit">
            <h1>Easy Grade Tracker</h1>
            <p>a simple grade checker written in PERL created to prevent any late semester surprises.</p>
          </div>
          <div class="row-fluid">
            <div class="span4">
              <h2>Submit An Assignment</h2>
                Assignment: <input id="assignment" type="text"></input></br>
                Type: <select id="type">
                    <option id="test" value="test">Test</option>
                    <option id="quiz" value="quiz">Quiz</option>
                    <option id="homework" value="homework">Homework</option>
                    <option id="project" value="project">Project</option>
                    <option id="extra_credit" value="extra credit">Extra Credit</option>
                </select></br>
                Date: <input id="date" type="text"></input></br>
                Points Earned: <input id="earned" type="text"></input></br>
                Points Possible: <input id="possible" type="text"></input></br>
                <button id="submit_assignment" type="button">Submit Assignment</button>
                <button id="clear_table" type="button">Clear Grade Sheet</button>
                <table id="grade_sheet" border="1">
                    <tr>
                        <th>ASSIGNMENT</th>
                        <th>TYPE</th>
                        <th>DATE</th>
                        <th>POINTS EARNED</th>
                        <th>POINTS POSSIBLE</th>
                        <th>GRADE</th>
                    </tr>
                </table></br>
                <input id="grade" type="text" value="0"></input>
                <div style="position: absolute;left: 850px;top: 1000px">
                    <h3>key</h3>
                    <p>0 - TESTS</p>
                    <p>1 - HOMEWORK</p>
                    <p>2 - QUIZES</p>
                    <p>3 - PROJECTS</p>
                    <p>4 - EXTRA CREDIT</p>
                </div>
                <div><canvas id="graph" height="300" width="300"></canvas></div>
            </div><!--/span-->
          </div><!--/row-->
        </div><!--/span-->
      </div><!--/row-->

      <hr>

      <footer>
        <p>&copy; James Albert 2012</p>
      </footer>

    </div><!--/.fluid-container-->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
    <script src="http://twitter.github.com/bootstrap/assets/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/MochiKit-1.4.2/lib/MochiKit/MochiKit.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Base.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Layout.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Canvas.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/SweetCanvas.js"></script>
    <script src="/homejs"></script>
  </body>
</html>
