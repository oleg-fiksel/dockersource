#!/usr/bin/perl

my @files=`find . -type f -name 'Dockerfile'`;
my $exit_code = 0;

foreach my $file (@files){
  chomp $file;
  print "Running test for $file",$/;
  my $cmd='perl ../dockersource.pl --debug "'.$file.'"';
  my $params = "";
  {
    # Get the second directory up from the Dockerfile
    my $params_dir = ($file =~ m:^(.+/[^/]+)/[^/]+/[^/]+:)[0];
    my $params_file = $params_dir.'/params';
    if(-r $params_file){
      open(my $fh, '<', $params_file);
      $params = join('', <$fh>);
      close($fh);
    }
  }
  $cmd .= " $params";
  if($file =~ /negative/i){
    $cmd = './invert_exitcode.sh '.$cmd;
  }
  print 'Running: ',$cmd;
  my $return_code = system($cmd);
  $exit_code++ if $return_code != 0;
}

exit $exit_code;
