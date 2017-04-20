#/usr/bin/perl

use strict;

my @libs = `find platforms/macosx/x86_64/lib`;

foreach my $lib (@libs)
  {
  next
    if -l $lib;

  next
    if $lib !~ /\.dylib$/;

  system("otool -L $lib");
  }
