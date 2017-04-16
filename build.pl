#!/usr/bin/perl

use strict;

use Cwd;
use Getopt::Long qw(:config bundling pass_through);
use File::Spec;
use XML::LibXML;
use File::Basename;

# Get optional arguments.
my $help;
my $platform;
my $architecture;
my $deployment;
my $debug;

GetOptions
  (
  'help' => \$help,
  'platform=s' => \$platform,
  'architecture=s' => \$architecture,
  'deployment=s' => \$deployment,
  'debug' => \$debug
  );
  
die usage()
  if $help;

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
    source => $package->findvalue('source'),
    prefix => $package->findvalue('prefix'),
    platform => $package->findvalue('platform'),
    architecture => $package->findvalue('architecture'),
    cmake => $package->findvalue('cmake'),
    configure => $package->findvalue('configure'),
    build => $package->findvalue('build'),
    install => $package->findvalue('install'),
    env => {}
    );
    
  # Read the environment variables.
  foreach my $variable ($package->findnodes('env/*'))
    {
    my $name = $variable->findvalue('local-name()');
    my $value = $variable->findvalue('text()');
    
    push @{$package{env}->{$name}}, $value;
    }

  push @packages, \%package;
  
  # Save the package name.
  $defaultPackageNamesToBuild{$package{name}} = 1;
  }
  
# If no packages were specified on the command line, use the default list.
@packageNamesToBuild = keys %defaultPackageNamesToBuild
  if not @packageNamesToBuild;

my %packageNamesToBuild = map { $_ => 1 } @packageNamesToBuild;

# Build the packages.
foreach my $package (@packages)
  {
  next
    if not $packageNamesToBuild{$package->{name}};
    
  build($package);
  }

# Build a package.
sub build
  {
  my $package = shift;
  
	print "*** Building $package->{name} ***\n";

  my $name = $package->{name};
  my $source = $package->{source};
  my %env = %{$package->{env}};

  # Set a default SDK.
  my $sdk = 
    $package->{platform}
      ? $package->{platform}
      : $platform;
      
  $sdk = 'macosx'
    if not $sdk;

  # Set a default architecture.
  my $arch = 
    $package->{architecture}
      ? $package->{architecture}
      : $architecture;
      
  $arch = 'x86_64'
    if not $arch;

  my $root = getcwd();
  
  my $prefix = 
    $package->{prefix}
      ? File::Spec->join($root, $package->{prefix})
      : File::Spec->join($root, 'platforms', $sdk, $arch);
      
  # Setup the executable search path.
  my $path = File::Spec->join($root, 'usr/bin');
  
  $ENV{PATH} = "$ENV{PATH}:$path";
    
  my $platformPath = File::Spec->join($root, 'platforms', $sdk, $arch, 'bin');
  
  $ENV{PATH} = "$ENV{PATH}:$platformPath";

  # Setup the dynamic library search path.
  my $platformLib = File::Spec->join($root, 'platforms', $sdk, $arch, 'lib');
  
  $ENV{DYLD_LIBRARY_PATH} = "$ENV{DYLD_LIBRARY_PATH}:$platformLib";

  # Setup pkg-config.
  my $pkgConfigPath = File::Spec->join($prefix, 'lib/pkgconfig');
  
  $ENV{PKG_CONFIG_PATH} = "$ENV{PKG_CONFIG_PATH}:$pkgConfigPath";

  # Add extra parameters.    
	my @configureargs;
	my @cmakeargs;
	
  # Make sure prefix is set.
  push @configureargs, "--prefix=$prefix";
  push @cmakeargs, "-DCMAKE_INSTALL_PREFIX=$prefix";
  
  $ENV{PREFIX} = $prefix;
  
  # Set environment variables.
  while(my ($variable, $values) = each %env)
    {
    $ENV{$variable} = "@{$values}";
    }
    
	my $dir;

	if(!-e $source)
		{
		printf("Source archive/directory '$source' not found\n");
		die usage();
		}
	
	my $archive = basename($source);

	my $tmpdir = File::Spec->join('/tmp', $archive);

	# If the archive is a directory, copy it to /tmp to work on it.
	if(-d $source)
		{
		$dir = $tmpdir;
	
		runsystem(qq{/bin/rm -Rf "$dir"});
		runsystem(qq{/bin/cp -R "$source" "$dir"});
		}
	else
		{
		runsystem(qq{/bin/rm -Rf "$tmpdir"});
		runsystem(qq{/bin/mkdir -p "$tmpdir"});

		if($archive =~ /\.tgz|\.tar\.gz$|\.tar\.xz/)
			{
			runsystem(qq{/usr/bin/tar xf "$source" "-C$tmpdir"});
			} 
		elsif($archive =~ /\.tbz|\.tar\.bz2$/)
			{
			runsystem(qq{/usr/bin/tar xf "$source" "-C/tmp/$archive"});
			}
		elsif($archive =~ /\.zip$/)
			{
			runsystem(qq{/usr/bin/unzip "$source" -d "/tmp/$archive"});
			}

		$dir = `/usr/bin/find $tmpdir -mindepth 1 -maxdepth 1`;
	
		chomp $dir;
		}

  chdir($dir);
  
	# Set a default deployment.  
	if(not $deployment)
		{
		$deployment = `xcrun --sdk $sdk --show-sdk-version`;

		chomp $deployment;
		}
  
	# Setup the SDKROOT. Hopefully this will handle most situations.
	my $sdkroot = `/usr/bin/xcrun --sdk $sdk --show-sdk-path`;
  
	chomp $sdkroot;

	$ENV{SDKROOT} = $sdkroot;
	
	my $minversion = '';

	# Configure for iPhone.
	if($sdk =~ /^iphoneos/i)
		{
		$minversion = sprintf('-miphoneos-version-min=%s', $deployment);
		
		$ENV{IPHONEOS_DEPLOYMENT_TARGET} = $deployment;
	
		push @configureargs, qw(--build=x86_64-apple-darwin12 --host=arm-apple-darwin10);
		
		my $toolchain = File::Spec($root, 'iOS.cmake');
		push @cmakeargs, "-DCMAKE_TOOLCHAIN_FILE=$toolchain";
		push @cmakeargs, '-DIOS_PLATFORM=OS';
		}
  
	# Configure for iPhone simulator.
	elsif($sdk =~ /^iphonesimulator/i)
		{
		$minversion = sprintf('-mios-simulator-version-min=%s', $deployment);

		$ENV{IPHONEOS_DEPLOYMENT_TARGET} = $deployment;
		
		my $toolchain = File::Spec($root, 'iOS.cmake');
		push @cmakeargs, "-DCMAKE_TOOLCHAIN_FILE=$toolchain";
		push @cmakeargs, '-DIOS_PLATFORM=SIMULATOR';
		}
	
	# Configure for MacOS X.
	elsif($sdk =~ /^macosx/i)
		{
		$minversion = sprintf('-mmacosx-version-min=%s', $deployment);

		$ENV{MACOSX_DEPLOYMENT_TARGET} = $deployment;
		}

	# Setup the isysroot command-line parameters and PATH, if necessary.
	$ENV{PATH} = sprintf(
		'%s:%s:/usr/bin:/bin:/usr/sbin:/sbin',
		$sdkroot,
		'/Applications/Xcode.app/Contents/Developer/usr/bin')
	if $sdk && ($sdk =~ /^iphone/i);

  my $cflags = '';
  my $cxxflags = '';
  
  $cflags .= "-arch $arch "
    if $architecture;

  $cxxflags .= "-arch $arch "
    if $architecture;

  $cflags .= "-isysroot $sdkroot "
    if $sdkroot;

  $cxxflags .= "-isysroot $sdkroot "
    if $sdkroot;

  $cflags .= "$minversion "
    if $minversion;

  $cxxflags .= "$minversion "
    if $minversion;

  # Setup compiler flags.
  my $includePath = File::Spec->join($prefix, 'include');
  
  my $cppflags = "-I$includePath ";

  $ENV{CPPFLAGS} = $cppflags;
	$ENV{CFLAGS} = $cflags;
	$ENV{CXXFLAGS} = $cxxflags;

  my $linkPath = File::Spec->join($prefix, 'lib');

	$ENV{LDFLAGS} = "-L$linkPath ";

  # Debug statements.
  if($debug)
    {
		print(qq{PKG_CONFIG_PATH=$ENV{PKG_CONFIG_PATH}\n});
		print(qq{PATH=$ENV{PATH}\n});
		print(qq{DYLD_LIBRARY_PATH=$ENV{DYLD_LIBRARY_PATH}\n});
		print(qq{PREFIX=$ENV{PREFIX}\n});
		print(qq{SDKROOT=$ENV{PREFIX}\n});
		print(qq{IPHONEOS_DEPLOYMENT_TARGET=$ENV{IPHONEOS_DEPLOYMENT_TARGET}\n});
		print(qq{MACOSX_DEPLOYMENT_TARGET=$ENV{MACOSX_DEPLOYMENT_TARGET}\n});
		print(qq{CPPFLAGS=$ENV{CPPFLAGS}\n});
		print(qq{CFLAGS=$ENV{CFLAGS}\n});
		print(qq{CXXFLAGS=$ENV{CXXFLAGS}\n});
		print(qq{LDFLAGS=$ENV{LDFLAGS}\n});
		
    foreach my $env (keys %env)
      {
      print(qq{$env=$ENV{$env}\n})
      }
    }
    
	runsystem(qq{$package->{cmake} @cmakeargs})
		if $package->{cmake};

	runsystem(qq{$package->{configure} @configureargs})
		if $package->{configure};

	runsystem(qq{$package->{build}})
		if $package->{build};

  runsystem(qq{$package->{install}})
	  if $package->{install};
	  
	chdir($root);
	
	runsystem(qq{rm -Rf $tmpdir})
	  if not $debug;
	  
	print "*** Done building $package->{name} ***\n";
  }

sub debug
  {
  my @args = @_;
  
  print("DEBUG: @args\n")
    if $debug;
  }
  
sub runsystem
  {
  debug(@_);
    
  system(@_);
  }

# Print usage messages.
sub usage
  {
  my $message = << "EOF";
Usage: build.pl [options] [package(s)]

  where [options] can be:
    --help This help text
    --platform=macosx|iphoneos|iphonesimulator
    --architecture=i386|x86_64|arm7|arm64
    --deployment=<deployment version>
    --debug For debugging statements
    
  and [package(s)] is an optional list of packages to build. 
EOF

  return $message;
  }
  
