require 'net/http'

# Downloads the agent package
Puppet::Functions.create_function(:'checkmk::get_agent_package') do
  dispatch :get_agent_package do
    param 'String', :url
    param 'String', :bearer_token
    param 'String', :site_name
    param 'String', :os_type
    param 'String', :file_name
    return_type 'String'
  end

  def get_agent_package(url, bearer_token, site_name, os_type, file_name)
    return 'cmk-agent-ctl version is the same' unless version_different?(url, bearer_token, site_name, os_type)
    call_function('debug', 'cmk-agent-ctl is a different version, downloading new package')

    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/domain-types/agent/actions/download/invoke")
    params = { os_type: os_type }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/octet-stream'
    request['Authorization'] = "Bearer automation #{bearer_token}"

    file = open(file_name, 'wb')
    begin
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request) do |response|
          case response.code
          when '200'
            response.read_body do |segment|
              file.write(segment)
            end
          else
            file.close
            raise Puppet::Error, "Failed to download agent package: { type: #{response.class}, code: #{response.code}, body: #{response.body} }"
          end
        end
      end
      file.close

      'cmk-agent-ctl has been downloaded'
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      # Warn here as the server may not be configured yet
      call_function('warning', "Failed to connect: #{e}")
      file.close unless defined?(file).nil?

      'cmk-agent-ctl failed to downloaded'
    end
  end

  # Checks if the current installed version is different to what can be requested
  # If cmk-agent-ctl is not found, it will return true
  def version_different?(url, bearer_token, site_name, os_type)
    call_function('debug', 'checking if cmk-agent-ctl is installed')
    if system('/usr/bin/cmk-agent-ctl --version > /dev/null 2>&1')
      current_version = `/usr/bin/cmk-agent-ctl --version`
    else
      call_function('debug', 'cmk-agent-ctl is not installed')
      return true
    end

    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/domain-types/agent/actions/download/invoke")
    params = { os_type: os_type }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Head.new(uri)
    request['Accept'] = 'application/octet-stream'
    request['Authorization'] = "Bearer automation #{bearer_token}"

    file_name = ''
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request) do |response|
        file_name = response['content-disposition'][%r{filename="(.*)"\Z}, 1]
      end
    end

    file_name[%r{(#{current_version[%r{ (.*)\Z}, 1]})}, 1].nil?
  end
end
