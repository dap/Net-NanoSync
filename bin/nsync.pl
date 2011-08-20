#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket;
use IO::Socket::Multicast;

sub listen_for_nanostudio {
	my $sock = IO::Socket::Multicast->new(
		LocalPort => 10245,
	);
	$sock->mcast_add('225.1.1.1') || die "Couldn't set group: $!\n";

	while (1) {
		my ($data, $peer);

		next unless $peer = $sock->recv($data, 10240);
		next unless $data =~ m/^(.*):FileServer:(\d+);$/;

		my ($peer_port, $peer_addr) = sockaddr_in($peer);
		$peer_addr = inet_ntoa($peer_addr);

		return {addr => $peer_addr, port => $2};
	}
}

sub main {
	my $peer_info = listen_for_nanostudio();
	print "$peer_info->{'addr'}:$peer_info->{'port'}\n";
}

main() if $0 eq __FILE__;

