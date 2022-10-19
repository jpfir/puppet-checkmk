function checkmk::params(Hash $options, Puppet::LookupContext $context) {
  $base_params = {
    'checkmk::mode'                     => 'server',
    'checkmk::site_name'                => 'default',
    'checkmk::sha256_hash'              => '8804c0291e897f6185b147613a5fc86d61c0bcf73eaac5b11d90afe58af10c9f', # check-mk-raw-2.1.0p14_0.jammy_amd64.deb
    'checkmk::agent_download_protocol'  => 'http',
    'checkmk::agent_download_host'      => 'localhost',
    'checkmk::automation_user_password' => '',
    'checkmk::agent_folder'             => '/',
    'checkmk::hostname'                 => $trusted['certname'],
  }

  $os_params = case $facts['os']['family'] {
    'Debian': {
      {
        'checkmk::version'      => '2.1.0p14',
        'checkmk::download_url' => "https://download.checkmk.com/checkmk/2.1.0p14/check-mk-raw-2.1.0p14_0.${facts['os']['codename']}_amd64.deb"
      }
    }
    default: {
      {
        'checkmk::version'      => '2.1.0p14',
        'checkmk::download_url' => "https://download.checkmk.com/checkmk/2.1.0p14/check-mk-raw-2.1.0p14_0.${facts['os']['codename']}_amd64.deb"
      }
    }
  }

  $base_params + $os_params
}
