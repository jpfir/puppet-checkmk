# @summary Installs CheckMK Agent
class checkmk::install::agent {
  case $facts['os']['family'] {
    'Debian': {
      agent_package { '/tmp/check-mk-agent.deb':
        ensure       => $checkmk::agent_package_ensure,
        url          => "${checkmk::agent_download_protocol}://${checkmk::agent_download_host}",
        bearer_token => $checkmk::automation_user_password,
        site_name    => $checkmk::site_name,
        os_type      => 'linux_deb',
      }

      package { 'check-mk-agent':
        ensure   => installed,
        provider => 'apt',
        source   => '/tmp/check-mk-agent.deb',
        require  => Agent_package['/tmp/check-mk-agent.deb'],
      }
    }
    'RedHat': {
      agent_package { '/tmp/check-mk-agent.rpm':
        ensure       => $checkmk::agent_package_ensure,
        url          => "${checkmk::agent_download_protocol}://${checkmk::agent_download_host}",
        bearer_token => $checkmk::automation_user_password,
        site_name    => $checkmk::site_name,
        os_type      => 'linux_rpm',
      }

      package { 'check-mk-agent':
        ensure   => installed,
        provider => 'rpm',
        source   => '/tmp/check-mk-agent.rpm',
        require  => Agent_package['/tmp/check-mk-agent.rpm'],
      }
    }
    default: {
      fail('Unsupported OS family')
    }
  }

  create_host { $checkmk::hostname:
    ensure       => present,
    url          => "${checkmk::agent_download_protocol}://${checkmk::agent_download_host}",
    bearer_token => $checkmk::automation_user_password,
    site_name    => $checkmk::site_name,
    folder       => $checkmk::agent_folder,
    require      => Package['check-mk-agent'],
  }
  Package['check-mk-agent'] -> Create_host[$facts['fqdn']]

  $registration_server = checkmk::registration_server(
    "${checkmk::agent_download_protocol}://${checkmk::agent_download_host}",
    $checkmk::site_name,
  )

  exec { 'register checkmk agent':
    command => "/usr/bin/cmk-agent-ctl register --hostname ${checkmk::hostname} --server ${registration_server} --site ${checkmk::site_name} --user automation --password ${checkmk::automation_user_password} --trust-cert",
    require => [Package['check-mk-agent'], Create_host[$facts['fqdn']]],
    onlyif  => "/usr/bin/cmk-agent-ctl status --json | grep -q '\"connections\":\\[\\]'",
  }
}
