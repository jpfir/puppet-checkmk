# frozen_string_literal: true

require 'spec_helper'

describe 'checkmk' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      it { is_expected.to compile }
    end

    context 'mode => server' do
      let(:params) { { 'mode' => 'server' } }

      it { is_expected.to compile }
      it { is_expected.to contain_class('checkmk::install::server') }
    end

    # TODO: Use docker to run a CheckMK server for this to test against
    # context 'mode => agent' do
    #   let(:params) { { 'mode' => 'agent' } }
    #
    #   it { is_expected.to compile }
    #   it { is_expected.to contain_class('checkmk::install::agent') }
    # end
  end
end
