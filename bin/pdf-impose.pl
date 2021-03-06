#!/usr/bin/env perl

# written by Marco Pessotto

use strict;
use warnings;
# use FindBin;
# use lib "$FindBin::Bin/../lib";
use PDF::Imposition;
use Getopt::Long;
use Pod::Usage;

my ($signature, $help, $suffix, $cover);

my $schema = '2up';

my $opts = GetOptions (
                       'signature|sig|s=s' => \$signature,
                       'help|h' => \$help,
                       'suffix=s' => \$suffix,
                       'cover' => \$cover,
                       'schema=s' => \$schema,
                      ) or die;
my ($file, $outfile) = @ARGV;

if ($help) {
    pod2usage("Using PDF::Imposition version " .
              $PDF::Imposition::VERSION . "\n");
    exit 2;
}


die "Missing input" unless $file;
die "$file is not a file" unless -f $file;
my $imposer = PDF::Imposition->new(file => $file, schema => $schema);
if ($signature) {
    $imposer->signature($signature);
}

if ($outfile) {
    $imposer->outfile($outfile);
}
elsif ($suffix) {
    $imposer->suffix('-' . $suffix);
}

if ($cover) {
    $imposer->cover(1);
}

print "Output on " . $imposer->outfile . "\n";
if (-f $imposer->outfile) {
    unlink $imposer->outfile or die "Couldn't remove old output! $!";
}

$imposer->impose;
# and that's all
print "Imposed PDF left in " . $imposer->outfile . "\n";

=head1 NAME

pdf-impose.pl -- script to impose a PDF using the L<PDF::Imposition> class.

=head1 SYNOPSIS

  pdf-impose.pl infile.pdf [outfile.pdf]

This script is a simple wrapper around L<PDF::Imposition>. Refer to
the perldoc documentation (C<perldoc PDF::Imposition>) for details
about the options.

=head2 Options:

=over 4

=item  --schema

Available schemas: C<2up> C<2down> C<2x4x2> C<2side>
C<1x4x2cutfoldbind> C<4up> C<1repeat2top> C<1repeat2side> C<1repeat4>
C<ae4x4> C<1x8x2>

The schema to use: defaults to C<2up>. See C<perldoc PDF::Imposition>
for details about the available schemas.

=item  --cover

Boolean: if the schema supports it, put the last page of the PDF on
the last page of the last signature if there is a need of blank page
padding, so when folding the first page and the last page will match.

For example, for a 2up schema, if you have 6 pages, you will get a
signature of 8 pages, with 2 blank pages at the end. With this option
you get the two blank pages before the last one, which in turn will be
put in the same physical page of the first one.

=item --signature | --sig | -s <num>

<num> must be a multiple of 4 or a range like, e.g. 40-80

=item --suffix <string> 

defaults to 'imp'. The dash is automatically added, to avoid
confusing it with options. If you want more control, pass the
desired output file as second argument to the script.

=item --help
show this help

=back

If outfile is not provided, it will use the suffix to create the
output filename.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of either: the GNU General Public License as
published by the Free Software Foundation; or the Artistic License.

=cut

