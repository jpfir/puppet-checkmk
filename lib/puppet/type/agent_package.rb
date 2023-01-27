# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'agent_package',
  docs: <<-EOS,
    @summary Downloads the agent package from the CheckMK server API
    @example
      agent_package { '/tmp/check-mk-agent.deb':
        ensure       => 'present',
        url          => 'http://127.0.0.1',
        site_name    => 'default',
        bearer_token => 'testing123',
        os_type      => 'linux_deb',
      }

    This type provides Puppet with the capabilities to download the agent package from the CheckMK server API.
  EOS
  features: [],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this agent package should be present or absent on the target system.',
      default: 'present',
    },
    file_name: {
      type: 'String',
      desc: 'Where the downloaded agent package should be saved.',
      behaviour: :namevar,
    },
    url: {
      type: 'String',
      desc: 'The URL for the CheckMK server.',
      behaviour: :parameter,
    },
    bearer_token: {
      type: 'String',
      desc: 'The password for the `automation` user.',
      behaviour: :parameter,
    },
    site_name: {
      type: 'String',
      desc: 'The site name on the CheckMK Server.',
      behaviour: :parameter,
      default: 'default',
    },
    os_type: {
      type: 'String',
      desc: 'The type of package to download.',
      behaviour: :parameter,
    },
  },
)
