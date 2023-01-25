# frozen_string_literal: true

# Gets the registration port from the CheckMK server and returns the hostname and port for cmk-agent-ctl register
Puppet::Functions.create_function(:'checkmk::registration_server') do
  dispatch :registration_server do
    param 'String', :url
    param 'String', :site_name
    return_type 'String'
  end

  def registration_server(url, site_name)
    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/domain-types/internal/actions/discover-receiver/invoke")
    client = Puppet.runtime[:http]
    registration_port = ''
    client.get(uri, options: { include_system_store: true }) do |response|
      unless response.success?
        raise Puppet::Error, "Failed to get registration port: { type: #{response.class}, code: #{response.code} }"
      end

      registration_port = response.body
    end

    "#{uri.hostname}:#{registration_port}"
  rescue StandardError => e
    call_function('warning', "Failed to connect to the CheckMK server, using default value of 8000: #{e}")
    "#{URI(url).hostname}:8000"
  end
end
