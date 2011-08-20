use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::NanoSync',
    license             => 'perl',
    dist_author         => q{Darian Anthony Patrick <dap@darianpatrick.com>},
    dist_version_from   => 'lib/Net/NanoSync.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-NanoSync-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
