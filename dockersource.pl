#!/usr/bin/perl
use strict;
use warnings;

require v5.6.0;
use Getopt::Long;
use Data::Dumper;

use version;
our $VERSION = '1.0.1';
print "$0 Version: $VERSION$/$/";

my $from_regex = qr/^FROM\s+(\S+)/i;

my @whitelist = ();
my @blacklist = ();
my @files = ();
my $help = 0;
my $debug = 0;

GetOptions (
    "whitelist=s" => \@whitelist,
    "blacklist=s" => \@blacklist,
    "file=s" => \@files,
    "help" => \$help,
    "debug" => \$debug,
    )
  or die("Error in command line arguments$/");

usage() if @whitelist+@blacklist == 0 || $help || @files == 0;

exit main();

sub usage{
    print <<EOF;
Usage: $0 (--whitelist 'regex'|--blacklist 'regex') --file /path/to/Dockerfile [--debug] [--help]

--whitelist         specify a Perl RegEx to whitelist Docker images used in FROM clause
--blacklist         specify a Perl RegEx to blacklist Docker images used in FROM clause

Return codes:
      0 - No violations found
    >=1 - Number of violations found

Examples:
    $0 --whitelist '^my-private-registry.org\/.*' --file /path/to/Dockerfile --file /path/to/another/Dockerfile
    $0 --whitelist '^openjdk' --whitelist 'openjdk' --file /path/to/Dockerfile
    $0 --whitelist '^openjdk:.*-alpine' --file /path/to/Dockerfile
    $0 --blacklist '^wildhacker\/.*' --file /path/to/Dockerfile

EOF
    exit 1;
}

sub compile_patterns{
    foreach my $pattern (@whitelist, @blacklist){
        my $item = {
            string => $pattern,
            regex => qr/$pattern/i,
        };
        $pattern = $item;
    }
    return 0;
}

sub check_line{
    my $image_name = shift;
    my @violated_rules = ();

    print "check_line: Checking image: \"$image_name\"",$/;

    foreach my $rule (@whitelist){
        if($image_name =~ $rule->{regex}){
            print STDERR "(DEBUG) check_line: =>(whitelist) match $rule->{string}",$/
                if $debug;
            print "check_line: PASS",$/;
            return ();
        }
    }
    foreach my $rule (@blacklist){
        push @violated_rules, $rule
            if $image_name =~ $rule->{regex};
    }
    if(@violated_rules == 0){
        print "check_line: PASS",$/
    }
    else{
        print "check_line: FAIL",$/
    }
    return @violated_rules;
}

sub main{
    if(@whitelist > 0){
        print "main: adding '.' to blacklist because it's empty and whitelist is specified",$/;
        push @blacklist, '.'
    }
    compile_patterns();
    my $return_code = 0;
    foreach my $file (@files){
        open my $fh, '<', $file
            or die "Can't open file $file: $!";
        my @file_content = <$fh>;
        close $fh;
        my $line_num = 1;
        foreach my $line (@file_content){
            if($line =~ $from_regex){
                my $image_name = $1;
                my @violated_rules = check_line($image_name);
                if(@violated_rules > 0){
                    $return_code++;
                    my @violated_rules_strings = ();
                    foreach my $rule (@violated_rules){
                        push @violated_rules_strings, $rule->{string};
                    }
                    print "Violated blacklists: $file ($line_num): ".join(', ',@violated_rules_strings).$/;
                }
            }
            $line_num++;
        }
    }
    return $return_code;
}
