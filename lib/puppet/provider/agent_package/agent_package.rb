# frozen_string_literal: true

require 'digest'
require 'puppet/resource_api/simple_provider'

# Implementation for the agent_package type using the Resource API.
class Puppet::Provider::AgentPackage::AgentPackage < Puppet::ResourceApi::SimpleProvider
  def create(context, name, should)
    agent_package(context, name, should)
  end

  def update(context, name, should)
    return unless version_different?(context, name, should)

    context.debug 'cmk-agent-ctl is a different version, downloading new package...'
    agent_package(context, name, should)
  end

  def delete(_context, name)
    File.delete(name) if File.exist?(name)
  end

  def get(context, names = [])
    [
      {
        name: names.first,
        ensure: get_current_version(context).nil? ? 'absent' : 'present',
      },
    ]
  end

  private

  def digest(name)
    return nil unless File.exist?(name)

    Digest::SHA256.file(name).hexdigest
  end

  def agent_package(context, name, should)
    uri = URI("#{should[:url]}/#{should[:site_name]}/check_mk/api/1.0/domain-types/agent/actions/download/invoke")
    params = { os_type: should[:os_type] }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/octet-stream'
    request['Authorization'] = "Bearer automation #{should[:bearer_token]}"

    before_hash = digest(name)
    file = open(name, 'wb')
    begin
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request) do |response|
          case response.code
          when '200'
            response.read_body do |segment|
              file.write(segment)
            end
          when '404'
            context.warning '404 Error: Agent package not found. Check your agent_download_host, site_name and os_type are correct'
          else
            context.failed name, message: "Failed to download agent package due to #{response.class} error: { response_code: #{response.code}, body: #{response.body} }"
            file.close
          end
        end
      end
      return if file.closed?

      file.close
      after_hash = digest(name)
      if before_hash.nil?
        context.created name, message: "Created with #{after_hash}"
      elsif before_hash == after_hash
        context.debug name, message: 'No change in file contents'
      else
        context.updated name, message: "Updated from #{before_hash} to #{after_hash}"
      end
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      # Warn here as the server may not be configured yet
      context.warning "Failed to download agent package due to #{e.class} error: #{e.message}"
      file.close if !defined?(file).nil? && file.closed?
    end
  end

  # Checks if the current installed version is different to what can be requested
  # If cmk-agent-ctl is not found, it will return true
  def version_different?(context, name, should)
    current_version = get_current_version(context)
    return true if current_version.nil?

    uri = URI("#{should[:url]}/#{should[:site_name]}/check_mk/api/1.0/domain-types/agent/actions/download/invoke")
    params = { os_type: should[:os_type] }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Head.new(uri)
    request['Accept'] = 'application/octet-stream'
    request['Authorization'] = "Bearer automation #{should[:bearer_token]}"

    file_name = ''
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request) do |response|
        case response.code
        when '200'
          file_name = response['content-disposition'][%r{filename="(.*)"\Z}, 1]
        when '404'
          context.warning '404 Error: Agent package not found. Check your agent_download_host, site_name and os_type are correct'
        else
          context.failed name, message: "Failed to check agent package version: { type: #{response.class}, code: #{response.code}, body: #{response.body} }"
        end
      end
    end

    file_name[%r{(#{current_version[%r{ (.*)\Z}, 1]})}, 1].nil?
  end

  def get_current_version(context)
    context.debug 'checking if cmk-agent-ctl is installed'
    if system('/usr/bin/cmk-agent-ctl --version > /dev/null 2>&1')
      `/usr/bin/cmk-agent-ctl --version`
    else
      context.debug 'cmk-agent-ctl is not installed'
      nil
    end
  end
end
