package Net::NanoSync::Coro;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw/
	await_device_announcement
	await_device_address
	await_device_socket
/;

use Coro;
use Coro::Handle;
use Try::Tiny;

use Net::NanoSync::Protocol;

sub await_device_announcement {
	my $channel = shift;

	my $msock;

	# Propogate error on die
	try {
		$msock = unblock open_mcast_socket();
	}
	catch {
		die "Could not open mcast socket: $_";
	};

	while () {
		my $peer_info = get_device_mcast($msock);
		$channel->put($peer_info)
			if $peer_info;
		cede();
	}
}

sub await_device_address {
	my ($my_channel, $dev_comm_channel) = @_;

	while () {
		if ( $my_channel->size() ) {
			my $dev = $my_channel->get();

			my $sock;

			# Propogate error on die
			try {
				$sock = unblock open_data_socket($dev);
			}
			catch {
				die "Could not open data socket: $_";
			};

			$dev->{'sock'} = $sock;

			$dev_comm_channel->put($dev);
		}
		cede();
	}
}

sub await_device_socket {
	my $my_channel = shift;

	while () {
		my $dev = $my_channel->get();
		cede();
	}
}

1;

