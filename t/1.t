use Test::Simple 'no_plan';
use strict;
use lib './lib';
use warnings;
use lib './t';
use TestOne;
$TestOne::DEBUG = 1;
ok(1);
$ENV{CGI_APP_RETURN_ONLY} = 1;

my $t = new TestOne;

ok($t,' instanced');
ok(ref $t,'object is ref');



#use Data::Dumper;
#my %modes = $t->run_modes;
#printf STDERR " runmodes %s\n\n", Data::Dumper::Dumper(\%modes);


 $t->start_mode('test2');

ok( $t->_set_vars( V1 => 'THIS IS A TITLE' ), 'set vars');
ok( $t->tmpl_set( V2 => 'THIS IS A TITLE 2' ), 'tmpl_set');

ok( $t->_set_tmpl_default(q{var1 <TMPL_VAR V1><br>var2 <TMPL_VAR V2>},'test2.html'), 'set default template');

my $tmpl = $t->_tmpl('test2.html');

ok( ref $tmpl, '_tmpl returns ref');


ok( $t->run );


ok( $t->_tmpl_inner, 'tmpl inner returns inner');



ok( $t->_tmpl('test2.html'), '_tmpl returns object');



