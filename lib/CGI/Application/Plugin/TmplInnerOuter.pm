package CGI::Application::Plugin::TmplInnerOuter;
use strict;
use warnings;
use LEOCHARRE::DEBUG;
use HTML::Template::Default 'get_tmpl';
#$HTML::Template::Default::DEBUG =1;
use Exporter;
use Carp;
use vars qw($VERSION @ISA @EXPORT);
@ISA = qw/ Exporter /;
$VERSION = sprintf "%d.%02d", q$Revision: 1.2 $ =~ /(\d+)/g;
@EXPORT = (qw(
_feed_merge
_feed_vars
_feed_vars_all
_get_tmpl_default
_get_tmpl_name
_get_vars
_set_tmpl_default
_set_vars
_tmpl
_tmpl_inner
_tmpl_outer
tmpl
tmpl_main
tmpl_output
tmpl_set
));

=pod

=head1 NAME

CGI::Application::Plugin::TmplInnerOuter

=head1 SYNOPSIS

   use CGI::Application::Plugin::TmplInnerOuter;

=head1 DESCRIPTION

GOAL 1: INNER OUTER CONCEPT
   Have 1 main template, into which the other templates for each runmode are inserted
   I dont want to have to stick TMPL_INCLUDE for a header and footer
   So for runmode 'daisy', i want to use daisy.html but also main.html into which daisy.html goes.

GOAL 2: HARD CODED TEMPLATES WITH OPTION TO OVERRIDE
   I want to define a template hard coded, and offer the option to override by the user- by simply
   making the template exist where we suspect to find it.
   This is done with HTML::Template::Default

GOAL 3:
   Provide a means via which we store all parameters that will go into the template later, and at the last
   state output to browser.


=head2 OUTER

The outer template should hold the things that are present in every page, in every runmode view.
Your header, logout buttons, navigation, footer etc.

First you can to define your main template.

main.html:

   <html>
   <head>
   <title><TMPL_VAR TITLE></title>
   </head>
   <body>
   
   <TNPL_VAR NAME=BODY>
   
   </body>
   </html>

This can either be saved as 'main.html' or it can be Set Hard Coded.
If you set it hard coded into your app, if the main.html file exists, it overrides the hard coded version.
This is how you can include your template code in your modules but still let people override them.

How you would Set Hard Coded, main.html:

  $self->_set_tmpl_default(
   q{<html>
   <head>
   <title><TMPL_VAR TITLE></title>
   </head>
   <body>
   
   <TMPL_VAR NAME=BODY>
   
   </body>
   </html>}, 
   'main.html'
  );

The very basic template shown above for main is already included.
You can override it as shown above.
This means you can safely code whatever inside guts, and change the look and feel of the app
radically by creating a main.html file on disk, and doing what you want with it!

=head2 INNER

Then you have to set an inner template, this is the template relevant to your current runmode.
If your runmode is 'continue' then template sought is 'continue.html'
When setting a default inner template, the name argument does not need be provided.

   sub continue : Runmode {
      my $self = shift;
      $self->_set_tmpl_default( q{<h1>Would you like to continue?</h1>} );

      return $self->tmpl_output;
   }

Another example; your runmode being 'jimmy'.. this is what you would do:

   sub Jimmy : Runmode {
      my $self = shift;
      my $default = q{<p> I said: <TMPL_VAR BLABLA> </p>};
      
      $self->_set_tmpl_default($default);      
      

      
      $self->_set_vars(   BLABLA => 'This is what I said.' );
      # or
      $self->tmpl->param( BLABLA => 'This is what I said.' );

      return $self->tmpl_output;
   }

If you have Jimmy.html file in TMPL_PATH, then it is used as the inner template, regardless if you hard code it.

=cut



sub tmpl {
   my $self = shift;
   return $self->_tmpl_inner;
}

sub tmpl_main {
   my $self = shift;
   return $self->_tmpl_outer;
}

sub _tmpl_outer {
   my $self = shift;
   return $self->_tmpl('main.html');
}

sub _tmpl_inner {
   my $self = shift;
   return $self->_tmpl;
}

sub _tmpl {
   my($self,$name) = @_;
   $name ||= $self->_get_tmpl_name;

   $self->{_tmpl} ||= {};

   unless( $self->{_tmpl}->{$name} ) {      
      my $tmpl = get_tmpl($name,$self->_get_tmpl_default($name)) or warn("cant get [$name] template");
      $self->{_tmpl}->{$name} = $tmpl;       
   }
   
   return $self->{_tmpl}->{$name};
}

sub _set_tmpl_default {
   my $self = shift;
   my ($default,$name) = @_;
   defined $default or confess('missing template code arg');
   $name ||= $self->_get_tmpl_name;   
   $self->{_tmpl_default} ||= {};
   $self->{_tmpl_default}->{$name} = \$default;
   return 1;
}

sub _get_tmpl_name {
   my $self = shift; defined $self or croak;
   $self->get_current_runmode or warn('no runmode, returning undef') and return;
   my $name = $self->get_current_runmode.'.html';
   return $name;   
}

sub _get_tmpl_default {
   my $self = shift; 
   my $name = shift;
   $name ||= $self->_get_tmpl_name;
   $self->{_tmpl_default} ||={};

   if ($name eq 'main.html' and ! defined $self->{_tmpl_default}->{'main.html'}){
      debug("main.html was not defined, using default.\n");
      $self->_set_tmpl_default(
      q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
      <head>
      <title><TMPL_VAR NAME=TITLE></title>
      <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
      </head>
      <body>
      <TMPL_VAR NAME=BODY>
      </body>
      </html>},'main.html');
   }
   
   return $self->{_tmpl_default}->{$name};
}

=head1 METHODS

All methods are exported.

=cut

=head2 _set_tmpl_default()

argument is your html template code.
this is what would go in HTML::Template::Default::get_tmpl();

optional argument is a name of the template, such as 'main.html'.
If you do not specifiy a page name, it is assumed you are setting the inner template's default code.
The runmode appended by .html is the page name.

To set outer (main) template:

   $self->_set_tmpl_default( $maincode, 'main.html' );

=head2 tmpl(), _inner_tmpl(), _tmpl()

returns inner template HTML::Template object. 
You can use this, but I suggest you instead set variables via _set_vars()
tmpl_output() will later insert them, and insert the inner template output into the main template.

_tmpl_inner() also returns inner template, so would _tmpl() with no arguments.

=head2 tmpl_main(), _outer_tmpl(), _tmpl('main.html')

returns outer template HTML::Template object.
So would _tmpl_outer() and _tmpl('main.html')


=head2 _get_tmpl_name()

if your runmode is goop, this returns goop.html


=cut






#TODO there has to be another way to do this
sub tmpl_set {   
   my $self = shift;
   $self->_set_vars(@_);  
}

sub _set_vars {
   my $self = shift;
   my %vars = @_;
   
   $self->{_tmpl_vars} ||={};

   for ( keys %vars ){
      $self->{_tmpl_vars}->{$_} = $vars{$_};
   };

   return 1;   
}

sub _get_vars {
   my $self = shift;
   $self->{_tmpl_vars} ||={};
   return $self->{_tmpl_vars};
}

sub _feed_vars {
   my $self = shift;
   my $tmpl = shift;
   defined $tmpl or confess('missing arg');

   my $vars = $self->_get_vars;
   VARS : for( keys %$vars){ 
			my $key = $_; 
         my $val = $vars->{$key} or next VARS;			
			debug("[$key:$val]\n");			
			$tmpl->param( $_ => $vars->{$_} );
	}
   return 1;
}



=head1 METHODS FOR HTML TEMPLATE VARIABLES

these are exported, you do not have to use them

=head2 _set_vars(), tmpl_set()

argument is hash
sets variables that later will be inserted into templates
tmpl_set() is an alias for _set_vars()

instead of use tmpl->param( KEY => VAL ) ... use...

   $self->_set_vars( 
      USER  => 'Joe',
      TODAY => time_format('yyyy/mm/dd', time)
   );
   
And then

   $self->_feed_vars( $tmpl);

=head2 _get_vars()

returns array ref of vars set with _set_vars()

=head2 _feed_vars()

argument is HTML::Template object
feeds vars into template

   $self->_feed_vars($tmpl_object);
   $self->_feed_vars($self->tmpl);
   $self->_feed_vars($self->tmpl_main);


=head1 OUTPUT

=head2 tmpl_output()

combines the inner and outer templates, feeds variables, returns output.
this should be the last thing called by every runmode
You may want to override the default output method, to insert other things into it.

=head3 Example 1:

   sub show_cactus : Runmode {
      my $self = shift;      
      
      my $html = q{
       <h1><TMPL_VAR TITLE></h1>
       <p>your html template code.</p>
       <small><TMLP_VAR MESSAGE></small>
      };

      $self->_set_tmpl_default($html);   
      
      $self->_set_vars( 
         TITLE => 'This is the title, sure.'
         MESSAGE => 'Ok, this is text.',
      );

      $self->_feed_vars($self->tmpl);
      $self->_feed_vars($self->tmpl_main);

      # every runmode that shows output should use this:
      return $self->tmpl_output;
      
   }

=head3 Example 2:

The next example does the same exact thing, imagining you have a show_cactus.html template on disk,
in TMPL_PATH (see L<CGI::Application>).

   sub show_cactus : Runmode {
      my $self = shift;      
            
      $self->_set_vars( 
         TITLE => 'This is the title, sure.'
         MESSAGE => 'Ok, this is text.',
      );
      
      return $self->tmpl_output;      
   }

The arguments to _set_vars are fed to both the inner template (show_cactus.html) 
and the outer template (main.html).
All of the code of the inner template will be inserted into the <TMPL_VAR BODY> tag of the
outer template. So, your inner template should not have html start and end tags, body tags etc.


=head2 Overriding default tmpl_output()

The default out simply feeds output to the inner and outer templates.
At any point in the application from any method you can call _set_vars() to preset variables
that will be sent to both inner and outer templates (harmless with this system).
Maybe you have a navigation loop for example that you want to insert just at the last moment.

If so.. here is one example:


   sub tmpl_output {
   	     my $self = shift;
      
           $self->_set_vars( NAVIGATION_LOOP => $self->my_navigation_loop_method );
      
           $self->_feed_vars_all;  
           $self->_feed_merge;

           return $self->_tmpl_outer->output;
      
      # or return $self->tmpl_main->output;
      
      # or return $self->_tmpl('main.html')->output;     
   }

This way all runmodes returning tmpl_output() don't need to change anything about them.

=head2 _feed_vars_all()

takes no argument
feeds any vars set with _set_vars() into both inner and outer templates
returns true.

=head2 _feed_merge()

inserts output of inner template into outer template.
(inserts output of runmode template into main template.)
returns true.

=cut

sub tmpl_output {
	my $self = shift;
   $self->_feed_vars_all;  
   $self->_feed_merge;   
   return $self->_tmpl_outer->output;
}

sub _feed_vars_all {
   my $self = shift;
   $self->_feed_vars( $self->_tmpl_inner );   
   $self->_feed_vars( $self->_tmpl_outer);   
   return 1;
}

sub _feed_merge {
	my $self = shift;
   $self->_tmpl_outer->param( BODY => $self->_tmpl_inner->output );
   return 1;
}



=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 SEE ALSO

HTML::Template
HTML::Template::Default
CGI::Application
LEOCHARRE::DEBUG

=cut


1;
