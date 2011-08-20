package Net::NanoSync::Coro;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw/await_device_announcement/;

use Coro;
use Coro::Handle;
use Try::Tiny;

use Net::NanoSync::Protocol;

sub await_device_announcement {
	my $channel = shift;

	my $msock;

	# This might die; bubble it up
	try {
		$msock = unblock open_mcast_socket();
	}
	catch {
		die "Could not open mcast socket: $!";
	};

	while () {
		my $peer_info = get_device_mcast($msock);
		$channel->put($peer_info)
			if $peer_info;
		cede();
	}
}

1;

