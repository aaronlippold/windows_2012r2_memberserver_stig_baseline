control "V-15685" do
  title "Users must be prevented from changing installation options."
  desc  "Installation options for applications are typically controlled by
  administrators.  This setting prevents users from changing installation options
  that may bypass security features."
  impact 0.5
  tag "gtitle": "Windows Installer – User Control "
  tag "gid": "V-15685"
  tag "rid": "SV-53061r1_rule"
  tag "stig_id": "WN12-CC-000115"
  tag "fix_id": "F-45986r1_fix"
  tag "cci": ['CCI-001812']
  tag "cce": ['CCE-23712-3']
  tag "nist": ['CM-11 (2)', 'Rev_4']
  tag "false_negatives": nil
  tag "false_positives": nil
  tag "documentable": false
  tag "mitigations": nil
  tag "severity_override_guidance": false
  tag "potential_impacts": nil
  tag "third_party_tools": nil
  tag "mitigation_controls": nil
  tag "responsibility": nil
  tag "ia_controls": nil
  tag "check": "If the following registry value does not exist or is not
  configured as specified, this is a finding:

  Registry Hive: HKEY_LOCAL_MACHINE
  Registry Path: \\Software\\Policies\\Microsoft\\Windows\\Installer\\

  Value Name: EnableUserControl

  Type: REG_DWORD
  Value: 0"
  tag "fix": "Configure the policy value for Computer Configuration ->
  Administrative Templates -> Windows Components -> Windows Installer -> \"Allow
  user control over installs\" to \"Disabled\"."
  describe registry_key('HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\Installer') do
    it { should have_property 'EnableUserControl' }
    its('EnableUserControl') { should cmp == 0 }
  end
end

