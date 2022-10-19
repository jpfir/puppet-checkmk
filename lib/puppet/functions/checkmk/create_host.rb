require 'net/http'
require 'json'

# Creates a host in the CheckMK server
Puppet::Functions.create_function(:'checkmk::create_host') do
  dispatch :create_host do
    param 'String', :url
    param 'String', :bearer_token
    param 'String', :site_name
    param 'String', :folder
    param 'String', :host_name
    return_type 'String'
  end

  def create_host(url, bearer_token, site_name, folder, host_name)
    return 'CheckMK host already exists' if host_exists?(url, bearer_token, site_name, host_name)
    call_function('debug', 'Checkmk host does not exist, creating')

    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/domain-types/host_config/collections/all")
    request = Net::HTTP::Post.new(uri)
    request['accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer automation #{bearer_token}"
    request.body = { folder: folder, host_name: host_name }.to_json

    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    'CheckMK host has been created'
  rescue Errno::ECONNREFUSED => e
    # Warn here as the server may not be configured yet
    call_function('warning', "Failed to connect: #{e}")
    'CheckMK host creation failed'
  end

  def host_exists?(url, bearer_token, site_name, host_name)
    call_function('debug', 'Checking if checkmk host exists')

    uri = URI("#{url}/#{site_name}/check_mk/api/1.0/objects/host_config/#{host_name}")
    params = { effective_attributes: false }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
    request['accept'] = 'application/json'
    request['Authorization'] = "Bearer automation #{bearer_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
    response.code == '200'
  end
end
