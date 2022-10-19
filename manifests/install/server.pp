# @summary Installs CheckMK Server
class checkmk::install::server {
  case $facts['os']['family'] {
    'Debian': {
      file { '/tmp/check-mk-raw.deb':
        ensure         => file,
        source         => $checkmk::download_url,
        checksum       => 'sha256',
        checksum_value => $checkmk::sha256_hash,
      }

      package { "check-mk-raw-${checkmk::version}":
        ensure   => installed,
        provider => 'apt',
        source   => '/tmp/check-mk-raw.deb',
        require  => File['/tmp/check-mk-raw.deb'],
      }

      # TODO: make sure a user configurable password is set
      exec { "create omd site ${checkmk::site_name}":
        command => "/usr/bin/omd create ${checkmk::site_name}",
        creates => "/opt/omd/sites/${checkmk::site_name}",
        require => Package["check-mk-raw-${checkmk::version}"],
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
