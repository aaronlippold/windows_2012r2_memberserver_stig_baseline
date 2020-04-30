# -*- encoding : utf-8 -*-
# frozen_string_literal: true

control 'V-3337' do
  title 'Anonymous SID/Name translation must not be allowed.'
  desc  "Allowing anonymous SID/Name translation can provide sensitive
  information for accessing a system.  Only authorized users must be able to
  perform such translations."
  impact 0.7
  tag "gtitle": 'Anonymous SID/Name Translation'
  tag "gid": 'V-3337'
  tag "rid": 'SV-52882r1_rule'
  tag "stig_id": 'WN12-SO-000050'
  tag "fix_id": 'F-45808r1_fix'
  tag "cci": ['CCI-000366']
  tag "cce": ['CCE-24597-7']
  tag "nist": ['CM-6 b', 'Rev_4']
  tag "documentable": false
  tag "check": "Verify the effective setting in Local Group Policy Editor.
  Run \"gpedit.msc\".

  Navigate to Local Computer Policy -> Computer Configuration -> Windows Settings
  -> Security Settings -> Local Policies -> Security Options.

  If the value for \"Network access: Allow anonymous SID/Name translation\" is
  not set to \"Disabled\", this is a finding."
  tag "fix": "Configure the policy value for Computer Configuration -> Windows
  Settings -> Security Settings -> Local Policies -> Security Options ->
  \"Network access: Allow anonymous SID/Name translation\" to \"Disabled\"."

  describe security_policy do
    its('LSAAnonymousNameLookup') { should eq 0 }
  end
end
