require 'net/http'

# Gets the registration port from the CheckMK server and returns the hostname and port for cmk-agent-ctl register
Puppet::Functions.create_function(:'checkmk::registration_server') do
  dispatch :registration_server do
    param 'String', :url
    param 'String', :site_name
    return_type 'String'
  end

  def registration_server(url, site_name)
    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/domain-types/internal/actions/discover-receiver/invoke")
    request = Net::HTTP::Get.new(uri)

    registration_port = ''
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request) do |response|
        case response.code
        when '200'
          registration_port = response.body
        else
          raise Puppet::Error, "Failed to get registration port: { type: #{response.class}, code: #{response.code} }"
        end
      end
    end

    "#{uri.hostname}:#{registration_port}"
  rescue Errno::ECONNREFUSED => e
    call_function('warning', "Failed to connect, using default value of 8000: #{e}")
    "#{URI(url).hostname}:8000"
  end
end
