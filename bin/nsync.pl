#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket;
use IO::Socket::Multicast;


my $sock = IO::Socket::Multicast->new(
	LocalPort => 10245,
);
$sock->mcast_add('225.1.1.1') || die "Couldn't set group: $!\n";

while (1) {
	my ($data, $peer);
	next unless $peer = $sock->recv($data, 10240);
	next unless $data =~ m/^(.*):FileServer:(\d+);$/;
	print $data, "\n";
}
