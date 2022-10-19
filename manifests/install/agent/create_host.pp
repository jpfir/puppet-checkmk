# @summary Downloads the CheckMK Agent
class checkmk::install::agent::create_host {
  $host_created = Deferred('checkmk::create_host',
    [
      "${checkmk::agent_download_prefix}://${checkmk::agent_download_host}",
      $checkmk::automation_user_password,
      $checkmk::site_name,
      $checkmk::agent_folder,
      $checkmk::hostname,
    ]
  )

  if $host_created {
    notify { 'Checkmk host created':
      message => 'The CheckMK Agent has been downloaded',
    }
  }
}
