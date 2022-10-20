function checkmk::params(Hash $options, Puppet::LookupContext $context) {
  {
    'checkmk::mode'                     => 'server',
    'checkmk::version'                  => '2.1.0p14',
    'checkmk::download_url'             => undef,
    'checkmk::site_name'                => 'default',
    'checkmk::sha256_hash'              => '8804c0291e897f6185b147613a5fc86d61c0bcf73eaac5b11d90afe58af10c9f', # check-mk-raw-2.1.0p14_0.jammy_amd64.deb
    'checkmk::agent_download_protocol'  => 'http',
    'checkmk::agent_download_host'      => 'localhost',
    'checkmk::cmkadmin_user_password'   => undef,
    'checkmk::automation_user_password' => undef,
    'checkmk::agent_folder'             => '/',
    'checkmk::hostname'                 => $trusted['certname'],
  }
}
