#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Coro;
use Coro::Debug;
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

	# Channel for communication with device communicator thread
	my $dev_comm = Coro::Channel->new();

	# Start device discovery thread
	async {
		$Coro::current->{desc} = "device_discoverer";

		try { await_device_announcement($dev_discoverer) }
		catch {
			error 'Could not listen for devices; is another instance running?';
		};
	};

	# Start socket creator thread
	async {
		$Coro::current->{desc} = "socket_creator";

		try { await_device_address($sock_creator, $dev_comm) }
		catch {
			# TODO Improve this error message
			error "Could not connect to new device: $_";
		}
	}

	# Start device communicator thread
	async {
		$Coro::current->{desc} = "device_communicator";

		try { await_device_socket($dev_comm) }
		catch {
			# TODO Improve this error message
			error 'Could not communicate with device.';
		}
	}

	# Start coordination thread
	async {
		$Coro::current->{desc} = "coordinator";

		while () {
			if ( $dev_discoverer->size() ) {
				my $dev = $dev_discoverer->get();

				if ( !exists $devices{$dev->{'name'}} ) {
					$devices{$dev->{'name'}} = $dev;
					$sock_creator->put( $devices{$dev->{'name'}} );
				}
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

