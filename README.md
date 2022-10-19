# checkmk

## Description

Provision [CheckMK](https://checkmk.com/) server and client.

## Usage

To set up a CheckMK server:
```puppet
class { '::checkmk':
  mode                     => 'server',
  download_url             => 'https://download.checkmk.com/checkmk/2.1.0p14/check-mk-raw-2.1.0p14_0.jammy_amd64.deb', # Where to download the CheckMK server package from
  sha256_hash              => '8804c0291e897f6185b147613a5fc86d61c0bcf73eaac5b11d90afe58af10c9f', # SHA256 hash of the downloaded package
  automation_user_password => '', # Password for the `automation` user, this can be configured after the server has been started
}
```
This will provision a CheckMK server with default configuration. This can be accessed from: `http://<server-ip>/default`.
To login, the `cmkadmin` user password must be set by running `htpasswd /omd/sites/default/etc/htpasswd cmkadmin <password>` on the server.
Once logged in the `automation` user password can be set by going to `Setup` -> `Users` -> `Users` -> `automation` -> `Automation secret for machine accounts`.

To set up a CheckMK agent:
```puppet
class { '::checkmk':
  mode                    => 'agent',
  agent_download_protocol => 'http', # The protocol that should be used when talking to the CheckMK server
  agent_download_host     => 'checkmk.example.com', # The hostname or IP address of the CheckMK server
}
```

All configurations can be set using Hiera.
```yaml
---
checkmk::mode: 'server'
checkmk::download_url: 'https://download.checkmk.com/checkmk/2.1.0p14/check-mk-raw-2.1.0p14_0.jammy_amd64.deb'
checkmk::sha256_hash: '8804c0291e897f6185b147613a5fc86d61c0bcf73eaac5b11d90afe58af10c9f'
checkmk::automation_user_password: ''
```

## Limitations

Currently only tested and supported Debian based systems.

## Development

To contribute to this module, please fork the repository and submit a pull request.
All commits should be squashed into a single commit and the commit message should follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
