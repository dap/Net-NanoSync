#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::NanoSync' ) || print "Bail out!
";
}

diag( "Testing Net::NanoSync $Net::NanoSync::VERSION, Perl $], $^X" );
