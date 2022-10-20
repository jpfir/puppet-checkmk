# frozen_string_literal: true

require 'spec_helper'

describe 'checkmk' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    describe "on #{os}" do
      context 'mode => server' do
        let(:params) do
          {
            'mode'                     => 'server',
            'cmkadmin_user_password'   => 'somepassword',
            'automation_user_password' => 'somepassword',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('checkmk::install::server') }
        it { is_expected.to contain_class('checkmk::install::agent') }
      end

      # TODO: Use docker to run a CheckMK server for this to test against
      context 'mode => agent' do
        let(:params) do
          {
            'mode'                     => 'agent',
            'automation_user_password' => 'somepassword',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('checkmk::install::agent') }
      end
    end
  end
end
