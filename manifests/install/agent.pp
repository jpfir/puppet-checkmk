# @summary Installs CheckMK Agent
class checkmk::install::agent {
  case $facts['os']['family'] {
    'Debian': {
      class { 'checkmk::install::agent::package': }

      package { 'check-mk-agent':
        ensure   => installed,
        provider => 'apt',
        source   => '/tmp/check-mk-agent.deb',
        require  => Class['checkmk::install::agent::package'],
      }

      class { 'checkmk::install::agent::create_host': }

      exec { 'register checkmk agent':
        command => "/usr/bin/cmk-agent-ctl register --hostname ${checkmk::hostname} --server ${checkmk::agent_download_host} --site ${checkmk::site_name} --user automation --password ${checkmk::automation_user_password} --trust-cert",
        require => [Package['check-mk-agent'], Class['checkmk::install::agent::create_host']],
        onlyif  => "/usr/bin/cmk-agent-ctl status --json | grep -q '\"connections\":\\[\\]'",
      }
    }
    default: {
      fail('Unsupported OS family')
    }
  }
}
