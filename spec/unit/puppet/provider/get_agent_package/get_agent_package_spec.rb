# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::AgentPackage')
require_relative '../../../../../lib/puppet/provider/agent_package/agent_package'

RSpec.describe Puppet::Provider::AgentPackage::AgentPackage do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:url) { 'http://127.0.0.1' }
  let(:bearer_token) { 'testing123' }
  let(:site_name) { 'default' }
  let(:os_type) { 'linux_deb' }

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:debug).with('checking if cmk-agent-ctl is installed')
      expect(context).to receive(:notice).with(%r{\ACreating 'cmk-agent-ctl'})

      provider.create(context, 'a', name: 'a', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:debug).with('checking if cmk-agent-ctl is installed')
      expect(context).to receive(:debug).with('cmk-agent-ctl is not installed')
      expect(context).to receive(:notice).with(%r{\AUpdating 'cmk-agent-ctl'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      provider.delete(context, 'foo')

      expect(context).to receive(:notice).with(%r{\ADeleting 'cmk-agent-ctl'})
    end
  end
end
