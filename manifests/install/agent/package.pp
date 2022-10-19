# @summary Downloads the CheckMK Agent
class checkmk::install::agent::package {
  Deferred('checkmk::get_agent_package',
    [
      "${checkmk::agent_download_prefix}://${checkmk::agent_download_host}",
      $checkmk::automation_user_password,
      $checkmk::site_name,
      'linux_deb',
      '/tmp/check-mk-agent.deb',
    ]
  )
}
