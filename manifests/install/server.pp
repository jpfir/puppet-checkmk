# @summary Installs CheckMK Server
class checkmk::install::server {
  case $facts['os']['family'] {
    'Debian': {
      file { '/tmp/checkmk_server.deb':
        ensure         => file,
        source         => $checkmk::download_url,
        checksum       => 'sha256',
        checksum_value => $checkmk::sha256_hash,
      }

      package { 'checkmk_server':
        ensure   => installed,
        provider => 'apt',
        source   => '/tmp/checkmk_server.deb',
        require  => File['/tmp/checkmk_server.deb'],
      }

      # TODO: make sure a user configurable password is set
      exec { "create omd site ${checkmk::site_name}":
        command => "/usr/bin/omd create ${checkmk::site_name}",
        creates => "/opt/omd/sites/${checkmk::site_name}",
        require => Package['checkmk_server'],
      }

      exec { "start odm site ${checkmk::site_name}":
        command => "/usr/bin/omd start ${checkmk::site_name}",
        require => Exec["create omd site ${checkmk::site_name}"],
        unless  => "/usr/bin/omd status ${checkmk::site_name}",
      }
    }
    default: {
      fail('Unsupported OS family')
    }
  }
}
