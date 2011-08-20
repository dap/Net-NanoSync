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

	my %devices;

	# Channel for communication with device discovery thread
	my $dev_discoverer = Coro::Channel->new();

	# Channel for communication with socket creation thread
	my $sock_creator = Coro::Channel->new();

	# Start device discovery thread
	async {
		$Coro::current->{desc} = "device_discoverer";

		try { await_device_announcement($dev_discoverer) }
		catch {
			error 'Could not listen for devices; is another instance running?';
		};
	};

	# Start coordination thread
	async {
		$Coro::current->{desc} = "coordinator";

		while () {
			print STDERR '.';
			if ( $dev_discoverer->size() ) {
				my $dev = $dev_discoverer->get();

				if ( !defined $devices{ $dev->{'name'} } ) {
					# TODO check for IP address change then signal sock_creator to recreate
					$devices{ $dev->{'name'} } = (
						'addr' => $dev->{'addr'},
						'port' => $dev->{'port'},
					);
					$sock_creator->put( $dev->{'name'} );
					print STDERR $dev->{'name'}, "\n";
				}
				else {
					print STDERR "IGNORING $dev->{'name'}\n";
				}
				sleep 1;
			}
			cede();
		}
	};

	# Allow threads to run
	while () {
		cede();
	}
}

main() if $0 eq __FILE__;

