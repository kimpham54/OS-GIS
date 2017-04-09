#!/usr/bin/perl

use strict;

use Getopt::Long qw(:config bundling pass_through);
use XML::LibXML;

# Get optional arguments.
my $help;
my $deploy;
my $debug;

GetOptions
  (
  'help' => \$help,
  'deploy=s' => \$deploy,
  'debug' => \$debug
  );
  
die usage()
  if $help;

my @packageNamesToBuild = @ARGV;

my $dom = XML::LibXML->load_xml(location => 'packages.xml');

my @packages;
my %defaultPackageNamesToBuild;

foreach my $package ($dom->findnodes('/packages/package')) 
  {
  my %package =
    (
    name => $package->findvalue('name'),
    license => $package->findvalue('license/@type'),
    bundleid => $package->findvalue('bundleid'),
    version => $package->findvalue('version'),
    source => $package->findvalue('source'),
    options => []
    );
    
  foreach my $option ($package->findnodes('options/option/text()'))
    {
    push @{$package{options}}, $option;
    }
    
  push @packages, \%package;
  
  $defaultPackageNamesToBuild{$package{name}} = 1;
  }
  
@packageNamesToBuild = keys %defaultPackageNamesToBuild
  if not @packageNamesToBuild;

my %packageNamesToBuild = map { $_ => 1 } @packageNamesToBuild;

foreach my $package (@packages)
  {
  next
    if not $packageNamesToBuild{$package->{name}};
    
  build(
    $package->{name},
    $package->{bundleid},
    $package->{version},
    $package->{source},
    @{$package->{options}});
  }

# Use lib2framework to build a package and stuff it into a framework.
sub build
  {
  my $name = shift;
  my $bundleID = shift;
  my $version = shift;
  my $source = shift;
  my @args = @_;

  push @args, "--deploy=$deploy"
    if $deploy;
    
  push @args, "--debug"
    if $debug;
    
  print(qq{lib2framework $name $bundleID $version $source @args\n})
    if $debug;
    
  system(qq{lib2framework $name $bundleID $version $source @args});
  }

# Print usage messages.
sub usage
  {
  my $message = << "EOF";
Usage: build.sh [options] [package(s)]

  where [options] can be:
    --deploy=<target macOS version>
    --debug For debugging statements
    
  and [package(s)] is an optional list of packages to build. 
EOF

  return $message;
  }
  
