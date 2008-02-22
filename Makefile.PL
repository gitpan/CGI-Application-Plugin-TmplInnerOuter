use ExtUtils::MakeMaker;
WriteMakefile(
   NAME => 'CGI::Application::Plugin::TmplInnerOuter',
   VERSION_FROM => 'lib/CGI/Application/Plugin/TmplInnerOuter.pm',
   # gen /usr/bin/pmused by Fri Feb 22 10:13:30 EST 2008
   PREREQ_PM => {
      'Data::Dumper' => '2',
      'HTML::Template::Default' => '1',
      'Test::Simple' => '0',
      'Exporter' => '5',
      'LEOCHARRE::DEBUG' => '1',
      'CGI::Application' => '4',
   },

);
