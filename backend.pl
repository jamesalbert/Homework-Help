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

get '/get/assignments' => sub {
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
    my $grade          = $user->get_grade;
    $self->render( text => $grade );
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

get '/signin' => sub {
    my $self     = shift;
    my $username = $self->param( 'username' );
    my $password = $self->param( 'password' );
    my $user     = Homework::Help->new;
    my $response = $user->sign_in( $username, $password );
    $self->render( text => $response );
};

get '/contact' => sub {
    my $self = shift;
    $self->render( text => 'James Albert <james.albert72@gmail.com>' );
};

app->start;

__DATA__

@@ homejs.html.ep

jQuery(document).ready(function() {
    jQuery('#add_assignment').focus();
    jQuery.get('http://localhost:3000/get/assignments',
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
        if (grade[0] < .225 && grade[0] != 0) {
            jQuery('#tips').append(
                '<p>you need to work on your tests. try to study more.</p></br>'
            );
        };
        if (grade[1] < .075 && grade[1] != 0) {
            jQuery('#tips').append(
                '<p>you need to work on your homework. try to get into a routine.</p></br>'
            );
        };
        if (grade[2] < .15 && grade[2] != 0) {
            jQuery('#tips').append(
                '<p>you need to work on your quizes. be ready for any pop quizes.</p></br>'
            );
        };
        if (grade[3] < .225 && grade[3] != 0) {
            jQuery('#tips').append(
                '<p>you need to work on your projects. take your time.</p></br>'
            );
        };
        if (grade[4] < .075 && grade[4] != 0) {
            jQuery('#tips').append(
                '<p>How can you mess up on extra credit??!!</p></br>'
            );
        };
        plotter.render();
    });
    var username = jQuery.cookie("username");
    jQuery('h1').append(username);
    jQuery('#clear_table').click(function() {
        jQuery.get('http://localhost:3000/clear/table',
        function(response) {
            alert(response);
            window.location.reload();
        });
    });
    jQuery('#sign_in').click(function() {
        var username = prompt('Username');
        var password = prompt('Password');
        jQuery.get('http://localhost:3000/signin?username='+username+'&password='+password,
        function(response) {
            if ( response != '' ) {
                jQuery.cookie("username", response);
                window.location.reload();
            }
            else {
                jQuery.cookie("username", null);
                window.location.reload();
            }
        });
    });
    jQuery(function() {
        var assignment = jQuery( "#assignment" ),
            type = jQuery( "#type" ),
            date = jQuery( "#date" ),
            earned = jQuery( "#earned" ),
            possible = jQuery( "#possible" ),
            allFields = jQuery( [] )
                .add( assignment )
                .add( type )
                .add( date )
                .add( earned )
                .add( possible ),
            tips = jQuery( ".validateTips" );

        jQuery( "#dialog-form" ).dialog({
            autoOpen: false,
            resizable: false,
            modal: true,
            buttons: {
                "Submit Assignment": function() {
                    var assignment = jQuery('#assignment').val();
                    var type = jQuery('#type').val();
                    var date = jQuery('#date').val();
                    var earned = jQuery('#earned').val();
                    var possible = jQuery('#possible').val();
                    if ( assignment != '' && type != '' && date != '' && earned != '' && possible != '' ) {
                        jQuery.get('http://localhost:3000/submit/assignment?a='+assignment+'&t='+type+'&d='+date+'&e='+earned+'&p='+possible,
                        function(status) {
                            window.location.reload();
                        });
                    }
                    else {
                        alert('Wrong or no data given');
                    }
                    jQuery( this ).dialog( "close" );
                }
            }
        });
    });
    jQuery('#add_assignment').click(function() {
        jQuery('#dialog-form').dialog('open');
    });
});

@@ home.html.ep

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>MojoVicious</title>
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

    <div id="dialog-form" title="Create new user">
        <p class="validateTips">All form fields are required.</p>

        <form>
        <fieldset>
            <label for="assignment">Assignment</label>
            <input type="text" name="assignment" id="assignment" class="text ui-widget-content ui-corner-all" />
            <label for="type">Type</label>
            <select name="type" id="type" value="" class="text ui-widget-content ui-corner-all">
                <option id="test" value="test">Test</option>
                <option id="homework" value="homework">Homework</option>
                <option id="quiz" value="quiz">Quiz</option>
                <option id="project" value="project">Project</option>
                <option id="extra credit" value="extra credit">Extra Credit</option>
            </select>
            <label for="date">Date</label>
            <input type="text" name="date" id="date" value="" class="text ui-widget-content ui-corner-all" />
            <label for="earned">Earned</label>
            <input type="text" name="earned" id="earned" value="" class="text ui-widget-content ui-corner-all" />
            <label for="possible">possible</label>
            <input type="text" name="possible" id="possible" value="" class="text ui-widget-content ui-corner-all" />
        </fieldset>
        </form>
    </div>

    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="/home">MojoVicious Grade Pro</a>
          <div class="nav-collapse collapse">
            <p class="navbar-text pull-right">
              Logged in as <a href="#" id="user_disp" class="navbar-link">Username</a>
            </p>
            <ul class="nav">
              <li class="active"><a href="#">Home</a></li>
              <li id="sign_in"><a href="#">Sign-In</a></li>
              <li><a href="mailto:james.albert72@gmail.com" target="_blank">Contact</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span9">
          <div class="hero-unit">
            <h1>Welcome </h1>
            <p>to a simple grade checker written in perl created to prevent any late semester surprises.</p>
          </div>
          <div class="row-fluid">
            <div class="span4">
              <h2>Submit An Assignment</h2>
                <button id="add_assignment" type="button">Add Assignment</button>
                <button id="clear_table" type="button">Clear Grade Sheet</button></br>
                </br>
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
                <div>
                    <h3>key</h3>
                    <p>0 - TESTS</p>
                    <p>1 - HOMEWORK</p>
                    <p>2 - QUIZES</p>
                    <p>3 - PROJECTS</p>
                    <p>4 - EXTRA CREDIT</p>
                </div>
                <div><canvas id="graph" height="300" width="300"></canvas></div>
                <div id="tips"></div>
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
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css" />
    <script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
    <script src="http://code.jquery.com/ui/1.9.1/jquery-ui.js"></script>
    <script src="https://raw.github.com/carhartl/jquery-cookie/master/jquery.cookie.js"></script>
    <script src="http://twitter.github.com/bootstrap/assets/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/MochiKit-1.4.2/lib/MochiKit/MochiKit.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Base.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Layout.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Canvas.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/SweetCanvas.js"></script>
    <script src="/homejs"></script>
    <!--<link rel="stylesheet" href="/resources/demos/style.css" />-->
  </body>
</html>
