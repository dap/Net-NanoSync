#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket;
use IO::Socket::Multicast;
use Try::Tiny;

sub bind_for_multicast {
	my $mcast_info = shift;

	# Stand up a multicast listening socket
	my $sock = IO::Socket::Multicast->new(
		LocalPort => $mcast_info->{'port'},
	);
	$sock->mcast_add( $mcast_info->{'addr'} )
		|| die "Couldn't set group: $!\n";

	return $sock;
}

sub listen_for_nanostudio {
	my $sock = shift;

	while (1) {
		my ($data, $peer);

		next unless $peer = $sock->recv($data, 10240);
		next unless $data =~ m/^(.*):FileServer:(\d+);$/;

		my ($peer_port, $peer_addr) = sockaddr_in($peer);
		$peer_addr = inet_ntoa($peer_addr);

		return {'addr' => $peer_addr, 'port' => $2};
	}
}

sub error ($) {
	print "Error: $_[0]\n";
	exit 1;
}

sub main {
	my %mcast_info = (
		'addr' => '225.1.1.1',
		'port' => '10245'
	);

	my $msock;

	try {
		$msock = bind_for_multicast( \%mcast_info );
	}
	catch {
		error "Could not bind to port $mcast_info{'port'}/udp; is another instance running?";
	};

	# Blocking call
	my $peer_info = listen_for_nanostudio($msock);
	print "$peer_info->{'addr'}:$peer_info->{'port'}\n";
}

main() if $0 eq __FILE__;

