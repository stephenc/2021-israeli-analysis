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
  die "You must provide the name of the tex file to output Makefile deps for"
}

my $texfile = $ARGV[0];

my $depfile;
if ($argc == 2) {
    $depfile = $ARGV[1]
} else {
    $depfile = $texfile
}

open(FH, '<', $texfile) or die "Failed to open $texfile: $!\n";

my @deps;

while(my $line = <FH>) {
    # bibliography
    foreach my $x ($line =~ /\\bibliography\{([^}]+)\}/g) {
        push @deps, "$x.bib";
    }
    # images (hack is the \ escape inside optional will grab the next character always)
    foreach my $x ($line =~ /\\includegraphics(?:\[[^]{]*(?:\{(?:[^\\]*\\.)*[^\\]*\}[^]{]*)*\])?\{([^}]+)\}/g) {
        if (-e "$x.pdf") {
            # if an externally generated PDF then use that
            push @deps, "$x.pdf";
        } elsif (-e "$x.png") {
            # if we have a PNG then use that
            push @deps, "$x.png";
        } elsif (-e "$x.jpg") {
            # if we have a JPG then use that
            push @deps, "$x.jpg";
        } else {
            # assume we will generate the EPS
            push @deps, "$x.eps";
        }
    }
    # include and input
    foreach my $x ($line =~ /\\(?:input|include)\{([^}]+)\}/g) {
        push @deps, "$x.tex";
    }
}

close(FH);

open(FH, '>', "$texfile.d") or die "Failed to create $texfile.d: $!\n";

print FH"$depfile: @deps\n";

close(FH);
