package TestOne;
use base 'CGI::Application';
use strict;
use warnings;
use CGI::Application::Plugin::TmplInnerOuter;
use LEOCHARRE::DEBUG;
sub setup {
   my $self = shift;
   $self->start_mode('test2');
   $self->run_modes({
      test => 'rm_test',
      test2 => 'rm_test2',
   });


}


sub rm_test {
   my $self = shift;

   debug("stared test runmode\n");
   
   
   $self->_set_tmpl_default(q{
      <h1>Test</h1>
      
      <p>Var ONE <TMPL_VAR ONE></p>
      <p>Var TWO <TMPL_VAR TWO></p>
   });

   debug("set template\n");
   
   debug("returning output\n");

   $self->_set_vars(
      ONE => 'this is 1',
      TWO => 'this is 2',
   );


   return $self->tmpl_output;

   
}

sub rm_test2 {
   my $self = shift;

   debug("stared test2 runmode\n");
   return $self->tmpl_output;

}





1;
