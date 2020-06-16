control 'V-1112' do
  title "Outdated or unused accounts must be removed from the system or
  disabled."
  desc "Outdated or unused accounts provide penetration points that may go
  undetected.  Inactive accounts must be deleted if no longer necessary or, if
  still required, disabled until needed."
  impact 0.3
  tag "gtitle": 'Dormant Accounts'
  tag "gid": 'V-1112'
  tag "rid": 'SV-52854r4_rule'
  tag "stig_id": 'WN12-GE-000014'
  tag "fix_id": 'F-45780r2_fix'
  tag "cci": ['CCI-000795']
  tag "nist": ['IA-4 e', 'Rev_4']
  tag "documentable": false
  tag "check": "Run \"PowerShell\".

  Member servers and standalone systems:
  Copy or enter the lines below to the PowerShell window and enter. (Entering
  twice may be required. Do not include the quotes at the beginning and end of
  the query.)

  ([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where {
  $_.SchemaClassName -eq 'user' } | ForEach {
   $user = ([ADSI]$_.Path)      <status>draft</status>

   $lastLogin = $user.Properties.LastLogin.Value
   $enabled = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2
   if ($lastLogin -eq $null) {
   $lastLogin = 'Never'
   }
   Write-Host $user.Name $lastLogin $enabled
  }

  This will return a list of local accounts with the account name, last logon,
  and if the account is enabled (True/False).
  For example: User1 10/31/2015 5:49:56 AM True

  Domain Controllers:
  Enter the following command in PowerShell.
  \"Search-ADAccount -AccountInactive -UsersOnly -TimeSpan 35.00:00:00\"

  This will return accounts that have not been logged on to for 35 days, along
  with various attributes such as the Enabled status and LastLogonDate.

  Review the list of accounts returned by the above queries to determine the
  finding validity for each account reported.

  Exclude the following accounts:
  Built-in administrator account (Renamed, SID ending in 500)
  Built-in guest account (Renamed, Disabled, SID ending in 501)
  Application accounts

  If any enabled accounts have not been logged on to within the past 35 days,
  this is a finding.

  Inactive accounts that have been reviewed and deemed to be required must be
  documented with the ISSO."
  tag "fix": "Regularly review accounts to determine if they are still active.
  Disable or delete any active accounts that have not been used in the last 35
  days."

  application_accounts = input('application_accounts_domain')
  excluded_accounts = input('excluded_accounts_domain')

  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip

  if domain_role == '4' || domain_role == '5'
    list_of_accounts = json({ command: 'Search-ADAccount -AccountInactive -UsersOnly -Timespan 35.00:00:00 | Select -ExpandProperty Name | ConvertTo-Json' })
    ad_accounts = list_of_accounts.params
    untracked_accounts = ad_accounts - application_accounts - excluded_accounts
    describe 'AD Accounts' do
      it 'AD should not have any Accounts that are Inactive over 35 days' do
        failure_message = "Users that have not log into in 35 days #{untracked_accounts}"
        expect(untracked_accounts).to be_empty, failure_message
      end
    end
  end
  if domain_role != '4' || domain_role != '5'
    local_users = json({ command: "Get-LocalUser | Where-Object {$_.Enabled -eq 'True' -and $_.Lastlogon -le (Get-Date).AddDays(-35) } | Select -ExpandProperty Name | ConvertTo-Json" })
    local_users_list = local_users.params
    if local_users_list == ' '
      impact 0.0
      describe 'The system does not have any inactive accounts, control is NA' do
        skip 'The system does not have any inactive accounts, controls is NA'
      end
    else
      describe 'Account or Accounts exists' do
        it 'Server should not have Accounts' do
          failure_message = "User or Users #{local_users_list} have not login to system in 35 days"
          expect(local_users_list).to be_empty, failure_message
        end
      end
   end
 end
end