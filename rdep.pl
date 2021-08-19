#!/usr/bin/env perl
#   Copyright 2021 Stephen Connolly
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

use strict; use warnings;

my $argc = $#ARGV + 1;

if ($argc == 0) {
  die "You must provide the name of the R file to output Makefile deps for"
}

my $rfile = $ARGV[0];

my $depfile;
if ($argc == 2) {
    $depfile = $ARGV[1]
} else {
    $depfile = $rfile
}

open(FH, '<', $rfile) or die "Failed to open $rfile: $!\n";

my @deps;

while(my $line = <FH>) {
    # read.*()
    foreach my $x ($line =~ /read\.[^(]+\(["']([^"']+)["'](?:,.*)?\)/g) {
        push @deps, "$x";
    } 
    # source()
    foreach my $x ($line =~ /source\(["']([^"']+)["']\)/g) {
        push @deps, "$x";
    }
}

close(FH);

open(FH, '>', "$rfile.d") or die "Failed to create $rfile.d: $!\n";

print FH"$depfile: @deps $rfile.d\n";

close(FH);
