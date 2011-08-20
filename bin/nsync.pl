#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Coro;
use Try::Tiny;

use Net::NanoSync::Coro;

sub error ($) {
	print STDERR "Error: $_[0]\n";
	exit 1;
}

sub main {

	# Channel for communication with device discovery thread
	my $dev_announcement = Coro::Channel->new();

	# Start device discovery thread
	async {
		try { await_device_announcement($dev_announcement) }
		catch {
			error 'Could not listen for devices; is another instance running?';
		};
	};

	while () {
		#print STDERR ".";
		if ( $dev_announcement->size() ) {
			print STDERR $dev_announcement->get()->{'name'}, "\n"
		}
		cede();
	}
}

main() if $0 eq __FILE__;

