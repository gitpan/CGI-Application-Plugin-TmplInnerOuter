use ExtUtils::MakeMaker;
WriteMakefile(
   NAME => 'CGI::Application::Plugin::TmplInnerOuter',
   VERSION_FROM => 'lib/CGI/Application/Plugin/TmplInnerOuter.pm',
   PREREQ_PM =>{
      'Test::Simple' => 0,
      'LEOCHARRE::DEBUG' => '1.02',
      'HTML::Template::Default' => '1.02',
   },
);
