# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Creates a host in the CheckMK server
class Puppet::Provider::CreateHost::CreateHost < Puppet::ResourceApi::SimpleProvider
  def create(context, name, should)
    return if host_exists?(context, name, should)

    create_host(context, name, should)
  end

  def update(context, name, should)
    return if host_exists?(context, name, should)

    context.debug 'Checkmk host does not exist, creating...'
    create_host(context, name, should)
  end

  def delete(context, _name)
    # TODO: delete the host
    context.warning 'CheckMK Host deletion is not yet implemented'
  end

  def get(_context, names = [])
    [
      {
        name: names.first,
        ensure: 'present',
      },
    ]
  end

  private

  def create_host(context, name, should)
    uri = URI("#{should[:url]}/#{should[:site_name]}/check_mk/api/1.0/domain-types/host_config/collections/all")
    request = Net::HTTP::Post.new(uri)
    request['accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer automation #{should[:bearer_token]}"
    request.body = { folder: should[:folder], host_name: should[:host_name] }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request) do |response|
        case response.code
        when '200'
          true
        when '404'
          context.warning '404 Error: Unable to add host. Is the server configured?'
        else
          context.failed name, message: "Failed to add host: { type: #{response.class}, code: #{response.code}, body: #{response.body} }"
        end
      end
    end

    'CheckMK host has been created'
  rescue Errno::ECONNREFUSED => e
    # Warn here as the server may not be configured yet
    context.warning "Failed to connect: #{e}"
  end

  def host_exists?(_context, _name, should)
    uri = URI("#{should[:url]}/#{should[:site_name]}/check_mk/api/1.0/objects/host_config/#{should[:host_name]}")
    params = { effective_attributes: false }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
    request['accept'] = 'application/json'
    request['Authorization'] = "Bearer automation #{should[:bearer_token]}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
    response.code == '200'
  end
end
