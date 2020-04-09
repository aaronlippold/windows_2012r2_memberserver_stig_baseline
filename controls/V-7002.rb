control 'V-7002' do
  title 'Windows 2012/2012 R2 accounts must be configured to require passwords.'
  desc  "The lack of password protection enables anyone to gain access to the
  information system, which opens a backdoor opportunity for intruders to
  compromise the system as well as other resources.  Accounts on a system must
  require passwords."
  impact 0.7
  tag "gtitle": 'Password Requirement'
  tag "gid": 'V-7002'
  tag "rid": 'SV-52940r2_rule'
  tag "stig_id": 'WN12-GE-000015'
  tag "fix_id": 'F-85581r1_fix'
  tag "cci": ['CCI-000764']
  tag "nist": ['IA-2', 'Rev_4']
  tag "documentable": false
  tag "check": "Review the password required status for enabled user accounts.

  Open \"Windows PowerShell\".

  Domain Controllers:

  Enter \"Get-ADUser -Filter * -Properties PasswordNotRequired | Where
  PasswordNotRequired -eq True | FT Name, PasswordNotRequired, Enabled\".

  Exclude disabled accounts (e.g., Guest).

  If \"PasswordNotRequired\" is \"True\" for any enabled user account, this is a
  finding.

  Member servers and standalone systems:

  Enter 'Get-CimInstance -Class Win32_Useraccount -Filter
  \"PasswordRequired=False and LocalAccount=True\" | FT Name, PasswordRequired,
  Disabled, LocalAccount'.

  Exclude disabled accounts (e.g., Guest).

  If any enabled user accounts are returned with a \"PasswordRequired\" status of
  \"False\", this is a finding."
  tag "fix": "Configure all enabled accounts to require passwords.

  The password required flag can be set by entering the following on a command
  line: \"Net user [username] /passwordreq:yes\", substituting [username] with
  the name of the user account."

  # returns a hash of {'Enabled' => 'true' } 
 is_domain_controller = json({ command: 'Get-ADDomainController | Select Enabled | ConvertTo-Json' })

   if (is_domain_controller['Enabled'] == true)
     list_of_accounts = json({ command: "Get-ADUser -Filter * -Properties PasswordNotRequired | Where-Object {$_.PasswordNotRequired -eq 'True' -and $_.Enabled -eq 'True'} Select -ExpandProperty Name | ConvertTo-Json" })
     ad_accounts = list_of_accounts.params
  # require 'pry'; binding.pry
       describe 'AD Accounts' do
         it 'AD should not have any Accounts that have Password Not Required' do
         failure_message = "Users that have Password Not Required #{ad_accounts}"
         expect(ad_accounts).to be_empty, failure_message
        end
       end
   end
 if (is_domain_controller.params == {} )
    local_users = json({ command: "Get-CimInstance -Class Win32_Useraccount -Filter PasswordRequired=False and LocalAccount=True | Select -ExpandProperty Name | ConvertTo-Json" })
    local_users_list = local_users.params
    if (local_users_list == ' ')
      impact 0.0
       describe 'The system does not have any accounts with a Password set, control is NA' do
        skip 'The system does not have any accounts with a Password set,, controls is NA'
       end
    else
      describe "Account or Accounts exists" do
        it 'Server should not have Accounts with No Password Set' do
        failure_message = "User or Users #{local_users_list} have no Password Set" 
        expect(local_users_list).to be_empty, failure_message
        end
      end
    end
  end
end


 