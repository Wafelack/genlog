#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

sub get_hashes {
	my $start_hash = $_[0];
	my $raw_hashes = `git log --pretty=format:"%h" "$start_hash"..HEAD`;
	my @hashes = split "\n", $raw_hashes;
	@hashes;
}

sub gen_changelog {
	my @hashes = get_hashes($_[0]);
	my %categories = ();
	foreach my $hash (@hashes) {
		my @parts = split ':', scalar `git log --format=%B -n 1 $hash`;
		my $category = $parts[0];
		my $content = $parts[1];
		next unless defined $content;

		$category =~ s/^\s+|\s+$//g;
		$category = lc($category);
		$content =~ s/^\s+|\s+$//g;
		$categories{$category} = [] unless defined $categories{$category};

		push @{$categories{$category}}, $content;
	}
	%categories;
}

my $title = "";
my $hash = "";
my $help = 0;

GetOptions('title=s' => \$title, 'hash=s' => \$hash, 'help' => \$help);

if ($help != 0) {
	print "Usage: genlog.pl [--hash HASH] [--title TITLE].\n";
	exit 0;
}

if ($hash eq "") {
	$hash = `git log --pretty=format:"%h" | tail -n 1`;
}

if ($title eq "") {
	$title = "Changelog from $hash to HEAD";
}

my %categories = gen_changelog($hash);
print "# $title\n\n";
foreach my $category (keys %categories) {
	my $up_category = ucfirst $category;
	print "## $up_category\n\n";
	my @commits = @{$categories{$category}};
	foreach my $commit (@commits) {
		$commit = ucfirst $commit;
		print "* $commit\n";
	}
	print "\n";
}
