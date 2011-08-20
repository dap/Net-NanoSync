package Net::NanoSync::Protocol;

use strict;
use warnings;

use IO::Socket::Multicast;
use IO::Socket::IP;

use base 'Exporter';
our @EXPORT = qw/
	open_mcast_socket
	get_device_mcast
	open_data_socket
/;

sub open_mcast_socket {
	my $mcast_info = shift;

	$mcast_info = { 'addr' => '225.1.1.1', 'port' => '10245'}
		unless $mcast_info;

	# Stand up a multicast listening socket
	my $sock = IO::Socket::Multicast->new(
		LocalPort => $mcast_info->{'port'},
	);
	$sock->mcast_add( $mcast_info->{'addr'} )
		|| die "Couldn't set group: $!\n";

	return $sock;
}

sub get_device_mcast {
	my $sock = shift;

	my ($data, $peer);

	return unless $peer = $sock->recv($data, 10240);
	return unless $data =~ m/^(.*):FileServer:(\d+);$/;

	my ($peer_port, $peer_addr) = sockaddr_in($peer);
	$peer_addr = inet_ntoa($peer_addr);

	return {'name' => "$1", 'addr' => $peer_addr, 'port' => $2};
}

sub open_data_socket {
	my $socket_info = shift;

	my $sock = IO::Socket::IP->new(
		PeerHost => $socket_info->{'addr'},
		PeerPort => $socket_info->{'port'},
	) or die "Cannot construct socket - $@";

	return $sock;
}

1;

