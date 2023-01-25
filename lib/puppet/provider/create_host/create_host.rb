# frozen_string_literal: true

require 'json'

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
    client = Puppet.runtime[:http]
    client.post(
      uri,
      { folder: should[:folder], host_name: should[:host_name] }.to_json,
      headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'Authorization' => "Bearer automation #{should[:bearer_token]}" },
      options: { include_system_store: true },
    ) do |response|
      unless response.success?
        if response.code == 404
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
    client = Puppet.runtime[:http]
    response = client.get(
      uri,
      params: { effective_attributes: false },
      headers: { 'Accept' => 'application/json', 'Authorization' => "Bearer automation #{should[:bearer_token]}" },
      options: { include_system_store: true },
    )

    response.success?
  end
end
