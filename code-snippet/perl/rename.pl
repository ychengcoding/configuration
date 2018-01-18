#!/usr/bin/perl

use Getopt::Std;

$usage = <<USAGE;
rename - renames files via a Perl expression. Adapted from Larry Wall's
         program in the first (pink) edition of the Camel book.

usage: rename [options] '<perl expr>' files
options:
    -n:   test - show how the renaming would be done, but don't do it
    -h:   help - print this message

The Perl expression is mandatory. A variable, $n, can be used in the Perl
expression to insert a sequence number into the new name. The files can
be listed on the command line, piped in through STDIN, or given in a file,
one per line.
USAGE

# Process options.
getopts('nh', \%opt);
die $usage if ($opt{h});

# Make sure there's a perl expression.
($perlexpr = shift) || die $usage;

# Handle the different ways of getting the file names.
chomp(@ARGV = <STDIN>) unless @ARGV;

# Set up a one-based file counting variable.
$n = 1;

# Do the renaming or show how it would be done.
foreach (@ARGV) {
  $old = $_;
  eval $perlexpr;
  die $@ if $@;
  if ($opt{n}) {
    print "$old => $_\n";
  }
  else {
    rename($old, $_) unless $old eq $_;
  }
  $n++;
}
