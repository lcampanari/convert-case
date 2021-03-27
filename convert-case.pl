#/user/bin/perl
use strict;
use warnings;
use Data::Dumper;
use File::Copy qw(move);
use Getopt::Long 2.24 qw( :config bundling no_ignore_case no_auto_abbrev );

my %opts = (
  run => {},
  cases => {}
);

my %cases = (
  'kebab' => \&kebab_case,
  'snake' => \&snake_case,
  'camel' => \&camel_case,
  'pascal' => \&pascal_case,
  'title' => \&title_case,
  'sentence' => \&sentence_case
);

GetOptions(
  't|test|dry-run' => \$opts{'run'}{'dry-run'},

  map { $_ => \$opts{'cases'}{$_} } keys %cases
) or die "Invalid options passed to $0\n";

main();

# Functions
sub main {
  my $transform_case = get_case();
  my @files = <*>;
  foreach my $file (@files) {
    execute($file, $transform_case);
  }
}

sub snake_case {
  my $string = shift;
  $string =~ s/([\w\d]+)([A-Z])/$1_$2/g; # account for camel/pascal case
  $string =~ s/[\s\-\_]+/_/g; # replace connectors
  $string =~ s/(.*)/\L$1/g; # lowercase
  $string =~ s/^[\s\-\_]+|[\s\-\_]+(?=\.)|[\s\-\_]+$//g; # trim spaces, - and _
  return $string;
}

sub kebab_case {
  my $string = shift;
  $string = snake_case($string);
  $string =~ s/_/-/g;
  return $string;
}

sub camel_case {
  my $string = shift;
  $string = snake_case($string);
  $string =~ s/_(.)/\U$1/g;
  return $string;
}

sub pascal_case {
  my $string = shift;
  $string = camel_case($string);
  $string =~ s/(^.)/\U$1/g;
  return $string;
}

sub sentence_case {
  my $string = shift;
  $string = snake_case($string);
  $string =~ s/_/ /g;
  $string =~ s/(^.)/\U$1/g;
  return $string;
}

sub title_case {
  my $string = shift;
  $string = snake_case($string);
  $string =~ s/_(.)/ \U$1/g;
  $string =~ s/^(.)/\U$1/g;
  return $string;
}

sub get_case {
  foreach my $key (keys %{ $opts{'cases'} }) {
    if($opts{'cases'}{$key}) {
      return $key;
    }
  }
}

sub execute {
  my $file = shift;
  my $transform_case = shift;
  my $new_file = $cases{$transform_case}($file);
  
  if($opts{'run'}{'dry-run'}) {
    print "$file --> $new_file\n";
  } else {
    move $file, $new_file;
    print "Renamed $new_file\n";
  }
}