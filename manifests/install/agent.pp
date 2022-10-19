# @summary Installs CheckMK Agent
class checkmk::install::agent {
  case $facts['os']['family'] {
    'Debian': {
      $get_agent_package = Deferred('checkmk::get_agent_package',
                                    ["${checkmk::agent_download_prefix}://${checkmk::agent_download_host}",
                                     $checkmk::automation_user_password,
                                     $checkmk::site_name,
                                     'linux_deb',
                                     '/tmp/check-mk-agent.deb'])

      package { 'check-mk-agent':
        ensure   => installed,
        provider => 'apt',
        source   => '/tmp/check-mk-agent.deb',
      }

      $create_host = Deferred('checkmk::create_host',
                              ["${checkmk::agent_download_prefix}://${checkmk::agent_download_host}",
                                $checkmk::automation_user_password,
                                $checkmk::site_name,
                                $checkmk::agent_folder,
                                $checkmk::hostname])

      exec { 'register checkmk agent':
        command => "/usr/bin/cmk-agent-ctl register --hostname ${trusted['certname']} --server ${checkmk::agent_download_host} --site ${checkmk::site_name} --user automation --password ${checkmk::automation_user_password} --trust-cert",
        require => Package['check-mk-agent'],
        onlyif  => "/usr/bin/cmk-agent-ctl status --json | grep -q '\"connections\":\\[\\]'",
      }
    }
    default: {
      fail('Unsupported OS family')
    }
  }
}
