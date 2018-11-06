control "V-3245" do
  title "Non system-created file shares on a system must limit access to groups
  that require it."
  desc  "Shares on a system provide network access.  To prevent exposing
  sensitive information, where shares are necessary, permissions must be
  reconfigured to give the minimum access to those accounts that require it."
  impact 0.5
  tag "gtitle": "File share ACLs"
  tag "gid": "V-3245"
  tag "rid": "SV-52881r3_rule"
  tag "stig_id": "WN12-GE-000018"
  tag "fix_id": "F-45807r4_fix"
  tag "cci": ["CCI-001090"]
  tag "nist": ["SC-4", "Rev_4"]
  tag "documentable": false
  tag "check": "If only system-created shares such as \"ADMIN$\", \"C$\", and
  \"IPC$\" exist on the system, this is NA.
  (System-created shares will display a message that it has been shared for
  administrative purposes when \"Properties\" is selected.)

  Run \"Computer Management\".
  Navigate to System Tools >> Shared Folders >> Shares.

  Right click any non-system-created shares.
  Select \"Properties\".
  Select the \"Share Permissions\" tab.

  If the file shares have not been reconfigured to restrict permissions to the
  specific groups or accounts that require access, this is a finding.

  Select the \"Security\" tab.

  If the NTFS permissions have not been reconfigured to restrict permissions to
  the specific groups or accounts that require access, this is a finding."
  tag "fix": "If a non-system-created share is required on a system, configure
  the share and NTFS permissions to limit access to the specific groups or
  accounts that require it.

  Remove any unnecessary non-system-created shares."
  
  share_names = []
  share_paths = []
  get = command('Get-WMIObject -Query "SELECT * FROM Win32_Share" | Findstr /V "Name --"').stdout.strip.split("\n")

  get.each do |share|
    loc_space = share.index(' ')
 
    names = share[0..loc_space-1]
 
    share_names.push(names)
    loc_colon = share.index(':')
    path = share[9..50]
    share_paths.push(path)
  end

  share_names_string = share_names.join(",")

  if (share_names_string != 'ADMIN$,C$,IPC$')

    [share_paths, share_names].each do |path1, name1|

      describe command("Get-Acl -Path '#{path1}' | Format-List | Findstr /i /C:'Everyone Allow'") do
        its('stdout') { should eq '' }
      end 
    end
  end

  if (share_names_string == 'ADMIN$,C$,IPC$') 
    impact 0.0
    describe "The default files shares exist" do
      skip "This control is NA"
    end
  end
end