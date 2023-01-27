# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'checkmk' do
  it 'installs server' do
    pp = <<-EOS
      class { 'checkmk':
        mode                     => 'server',
        download_url             => 'https://download.checkmk.com/checkmk/2.1.0p17/check-mk-raw-2.1.0p17_0.focal_amd64.deb',
        version                  => '2.1.0p17',
        sha256_hash              => '0dcac8b62221f9ebb7073ea17e5ec21b22fe2d4e0b0acf261ec68520243876dc',
        cmkadmin_user_password   => 'changeme123',
        automation_user_password => 'changeme456',
      }
    EOS

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_failures: true)
  end
end
