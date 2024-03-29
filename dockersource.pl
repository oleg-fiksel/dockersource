#!/usr/bin/perl
use strict;
use warnings;

require v5.6.0;
use Getopt::Long;
use Data::Dumper;

use version;
our $VERSION = '3.0.0';
print "$0 Version: $VERSION$/";

my $from_regex = qr/^FROM\s+(\S+)/i;

my @whitelist = ();
my @blacklist = ();
my $print_summary = 0;
my @files = ();
my $help = 0;
my $debug = 0;

GetOptions (
    "whitelist=s" => \@whitelist,
    "blacklist=s" => \@blacklist,
    "summary" => \$print_summary,
    "file=s" => \@files,
    "help" => \$help,
    "debug" => \$debug,
    )
  or die("Error in command line arguments$/");

@files = @ARGV;
usage() if @whitelist+@blacklist == 0 || $help || @files == 0;

exit main();

sub usage{
    print <<EOF;
Usage: $0 (--whitelist 'regex'|--blacklist 'regex') [--summary] [--debug] [--help] /path/to/Dockerfile /path/to_another/Dockerfile

--whitelist         Specify a Perl RegEx to whitelist Docker images used in FROM clause
--blacklist         Specify a Perl RegEx to blacklist Docker images used in FROM clause
--summary           Print the whitelist and blacklist summary before the run
--debug             Enable debug output

Return codes:
      0 - No violations found
      0 - No parameters given
    >=1 - Number of violations found

Examples:
    $0 --whitelist '^my-private-registry.org\/.*' /path/to/Dockerfile /path/to/another/Dockerfile
    $0 --whitelist '^openjdk' --whitelist 'openjdk' /path/to/Dockerfile
    $0 --whitelist '^openjdk:.*-alpine' /path/to/Dockerfile
    $0 --blacklist '^wildhacker\/.*' /path/to/Dockerfile

EOF
    exit 0;
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

    print "check_line: Checking image: \"$image_name\"",$/
        if $debug;

    foreach my $rule (@whitelist){
        if($image_name =~ $rule->{regex}){
            print STDERR "(DEBUG) check_line: =>(whitelist) match $rule->{string}",$/
                if $debug;
            print "Image \"$image_name\" \e[1;32mOK\e[0m",$/;
            return ();
        }
    }
    foreach my $rule (@blacklist){
        push @violated_rules, $rule
            if $image_name =~ $rule->{regex};
    }
    if(@violated_rules == 0){
        print "Image \"$image_name\" \e[1;32mOK\e[0m",$/;
    }
    else{
        print "Image \"$image_name\" \e[1;31mNOK\e[0m",$/;
    }
    return @violated_rules;
}

sub check_files_not_readable{
    my @files = @_;
    my @not_readable_files;
    foreach my $file (@files){
        push @not_readable_files, $file
            if !-r $file;
    }
    die "ERROR: Can't read files: ",$/,join($/,@not_readable_files),$/,"Exiting!"
        if @not_readable_files >0;
    return 0;
}

sub print_summary{
    my $listname = shift;
    my $list = shift;
    print "\e[1;30m|===[\e[0m ".$listname." \e[1;30m]\e[0m",$/;
    foreach my $i (@$list){
        print "\e[1;30m+-------[\e[0m ",$i," \e[1;30m]\e[0m",$/;
    }
    return 0;
}

sub main{
    print "main: going to scan the following files: ",$/,join($/, @files),$/
        if $debug;
    check_files_not_readable(@files);
    if(@whitelist > 0){
        print "main: adding '.' to blacklist because whitelist is specified",$/;
        push @blacklist, '.'
    }

    if($print_summary){
        print_summary('Whitelist', \@whitelist);
        print_summary('Blacklist', \@blacklist);
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
