#!/usr/bin/perl

use strict;

use Getopt::Long qw(:config bundling pass_through);
use File::Spec;
use XML::LibXML;

# Get optional arguments.
my $help;
my $prefix;
my $deploy;
my $debug;

GetOptions
  (
  'help' => \$help,
  'prefix=s' => \$prefix,
  'deploy=s' => \$deploy,
  'debug' => \$debug
  );
  
die usage()
  if $help;

$prefix = File::Spec->join($ENV{HOME}, 'Library')
  if not $prefix;

# Read packages to build, if any, from the command line.
my @packageNamesToBuild = @ARGV;

my $dom = XML::LibXML->load_xml(location => 'packages.xml');

my @packages;
my %defaultPackageNamesToBuild;

# Parse the XML.
foreach my $package ($dom->findnodes('/packages/package')) 
  {
  my %package =
    (
    name => $package->findvalue('name'),
    license => $package->findvalue('license/@type'),
    bundleid => $package->findvalue('bundleid'),
    version => $package->findvalue('version'),
    source => $package->findvalue('source'),
    options => [],
    env => {},
    dependencies => []
    );
    
  # Read the options.
  foreach my $option ($package->findnodes('options/option/text()'))
    {
    push @{$package{options}}, $option;
    }
    
  # Read the environment variables.
  foreach my $variable ($package->findnodes('env/*'))
    {
    my $name = $variable->findvalue('local-name()');
    my $value = $variable->findvalue('text()');
    
    push @{$package{env}->{$name}}, $value;
    }

  # Read the dependencies.
  my @dependencies = $package->findnodes('dependencies/dependency/text()');
  
  foreach my $dependency (@dependencies)
    {
    push @{$package{dependencies}}, $dependency;
    }

  # Save the package.
  push @packages, \%package;
  
  # Save the package name.
  $defaultPackageNamesToBuild{$package{name}} = 1;
  }
  
# If no packages were specified on the command line, use the default list.
@packageNamesToBuild = keys %defaultPackageNamesToBuild
  if not @packageNamesToBuild;

my %packageNamesToBuild = map { $_ => 1 } @packageNamesToBuild;

# Add dependencies.
foreach my $package (@packages)
  {
  next
    if not $packageNamesToBuild{$package->{name}};
    
  foreach my $dependency (@{$package->{dependencies}})
    {
    my $dependencyFramework = 
      File::Spec->join($prefix, "Frameworks", "$dependency.framework");
    
    $packageNamesToBuild{$dependency} = 1
      if not -d $dependencyFramework;
    }
  }

# Build the packages.
foreach my $package (@packages)
  {
  next
    if not $packageNamesToBuild{$package->{name}};
    
  build($package);
  }

# Use lib2framework to build a package and stuff it into a framework.
sub build
  {
  my $package = shift;
  
  my $name = $package->{name};
  my $bundleID = $package->{bundleid};
  my $version = $package->{version};
  my $source = $package->{source};
  my %env = %{$package->{env}};
  my @args = @{$package->{options}};

  # I know my dependencies will exist at this point, but I need to build a 
  # PKG_CONFIG_PATH variable with all of them included.
  # I should go ahead and add any executables to PATH too.
  foreach my $dependency (@{$package->{dependencies}})
    {
    # Do the path first since I need to be extra careful with pkg-config.
    my $dependencyFramework = 
      File::Spec->join($prefix, "Frameworks", "$dependency.framework");
    
    my $dependencyPath = File::Spec->join($dependencyFramework, "Programs");
        
    $ENV{PATH} = "$ENV{PATH}:$dependencyPath";
    
    my $pkgConfigPath = 
      File::Spec->join(
        $dependencyFramework, "Versions/Current/unix/lib/pkgconfig");
    
    next
      if not -d $pkgConfigPath;
      
    $ENV{PKG_CONFIG_PATH} = "$ENV{PKG_CONFIG_PATH}:$pkgConfigPath";
    }
    
	$ENV{PKG_CONFIG} = 
		File::Spec->join(
			$prefix, 
			"Frameworks", 
			"pkg-config.framework/Versions/Current/unix/bin/pkg-config");

  push @args, "--deploy=$deploy"
    if $deploy;
    
  push @args, "--debug"
    if $debug;
    
  push @args, "--prefix=$prefix";
  
  $ENV{PREFIX} = $prefix;
  
  while(my ($variable, $values) = each %env)
    {
    $ENV{$variable} = "@{$values}";
    }
    
  print(qq{PKG_CONFIG_PATH=$ENV{PKG_CONFIG_PATH}\n})
    if $debug;
  print(qq{PKG_CONFIG=$ENV{PKG_CONFIG}\n})
    if $debug;
  print(qq{PATH=$ENV{PATH}\n})
    if $debug;
  
  if($debug)
    {
    foreach my $env (keys %env)
      {
      print(qq{$env=$ENV{$env}\n})
      }
    }
    
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
    --help This help text
    --prefix=<installation path>
    --deploy=<target macOS version>
    --debug For debugging statements
    
  and [package(s)] is an optional list of packages to build. 
EOF

  return $message;
  }
  
