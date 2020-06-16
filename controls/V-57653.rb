# -*- encoding : utf-8 -*-
# frozen_string_literal: true

control 'V-57653' do
  title "Windows 2012 / 2012 R2 must automatically remove or disable temporary
  user accounts after 72 hours."
  desc "If temporary user accounts remain active when no longer needed or for
  an excessive period, these accounts may be used to gain unauthorized access. To
  mitigate this risk, automated termination of all temporary accounts must be set
  upon account creation.

  Temporary accounts are established as part of normal account activation
  procedures when there is a need for short-term accounts without the demand for
  immediacy in account activation.

  If temporary accounts are used, the operating system must be configured to
  automatically terminate these types of accounts after a DoD-defined time period
  of 72 hours.

  To address access requirements, many operating systems may be integrated
  with enterprise-level authentication/access mechanisms that meet or exceed
  access control policy requirements.
  "
  impact 0.5
  tag "gtitle": 'WINGE-000056'
  tag "gid": 'V-57653'
  tag "rid": 'SV-72063r2_rule'
  tag "stig_id": 'WN12-GE-000056'
  tag "fix_id": 'F-82983r1_fix'
  tag "cci": ['CCI-000016']
  tag "nist": ['AC-2 (2)', 'Rev_4']
  tag "documentable": false
  tag "check": "Determine if temporary user accounts are used and identify any
  that exist. If none exist, this is NA.

  Review temporary user accounts for expiration dates.

  Open \"PowerShell\".

  Domain Controllers:

  Enter \"Search-ADAccount -AccountExpiring -TimeSpan 3:00:00:00 | FT Name,
  AccountExpirationDate\"
  This will return any accounts configured to expire within the next 3 days.
  (The \"TimeSpan\" value to can be changed to find accounts configured to expire
  at various times such as 30 for the next month.)

  If any accounts identified as temporary are not listed, this is a finding.

  For any temporary accounts returned by the previous query:
  Enter \"Get-ADUser -Identity [Name] -Property WhenCreated\" to determine when
  the account was created.

  If the \"WhenCreated\" date and \"AccountExpirationDate\" from the previous
  query are greater than 3 days apart, this is a finding.

  Member servers and standalone systems:

  Enter \"Net User [username]\", where [username] is the name of the temporary
  user account.

  If \"Account expires\" has not been defined within 72 hours for any temporary
  user account, this is a finding.

  If the \"Password last set\" date and \"Account expires\" date are greater than
  72 hours apart, this is a finding. (Net User does not provide an account
  creation date.)"
  tag "fix": "Configure temporary user accounts to automatically expire within
  72 hours.

  Domain account can be configured with an account expiration date, under
  \"Account\" properties.

  Local accounts can be configured to expire with the command \"Net user
  [username] /expires:[mm/dd/yyyy]\", where username is the name of the temporary
  user account.

  Delete any temporary user accounts that are no longer necessary."

  # Critical Input by person running profile
  temp_accounts_domain = input('temp_accounts_domain')
  # Pulls all accounts that have a Expiration date
  temp_accounts_powershell = json({ command: 'Search-ADAccount -AccountExpiring | Select -ExpandProperty SamAccountName | ConvertTo-Json' })
  # Gets list from Powershell
  temp_accounts_list = temp_accounts_powershell.params
  # Adds both input and powershell command together
  untracked_temp_accounts = temp_accounts_list + temp_accounts_domain

  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip
  if untracked_temp_accounts.empty?
    describe 'There are no Temporary Account listed for this Control' do
      skip 'This becomes a manual check if the input temp_accounts_domain is not assigned a value'
    end
  else
    if domain_role == '4' || domain_role == '5'
      untracked_temp_accounts.each do |user|
        # Gets raw format of creation date
        raw_day_created = powershell("Get-ADUser -Identity #{user} -Properties Created | Findstr /i 'Created'").stdout.strip
        # If statement checks for "/" in output to see where the first number for month starts
        if raw_day_created[21] == '/'
          clean_month_created = raw_day_created[20]
        else
          clean_month_created = raw_day_created[20..21]
        end
        # If statement checks for "/" in output to see where the first number for Day starts
        if raw_day_created[21] == '/' && raw_day_created[23] == '/'
          clean_day_created = raw_day_created[22]
        elsif raw_day_created[21] != '/' && raw_day_created[24] == '/'
          clean_day_created = raw_day_created[23]
        elsif raw_day_created[21] == '/' && raw_day_created[22] != '/' && raw_day_created[23] != '/' && raw_day_created[24] == '/'
          clean_day_created = raw_day_created[22..23]
        elsif raw_day_created[21] != '/' && raw_day_created[22] == '/' && raw_day_created[23] != '/' && raw_day_created[24] != '/' && raw_day_created[25] == '/'
          clean_day_created = raw_day_created[23..24]
         end
        # If statement checks for last "/" before year starts
        if raw_day_created[23] == '/'
          clean_year_created = raw_day_created[24..27]
        elsif raw_day_created[24] == '/'
          clean_year_created = raw_day_created[25..28]
        elsif raw_day_created[25] == '/'
          clean_year_created = raw_day_created[26..29]
         end
        # date created by starts setup as dd/mm/yyyy
        date_created = clean_day_created + '/' + clean_month_created + '/' + clean_year_created

        # Gets raw format of expiration date
        raw_day_expire_date = powershell("Get-ADUser -Identity #{user} -Properties AccountExpirationDate | Findstr /i 'AccountExpirationDate'").stdout.strip

        # If statement checks for "/" in output to see where the first number for month starts
        if raw_day_expire_date[25] == '/'
         clean_month_expire_date = raw_day_expire_date[24]
        else
         clean_month_expire_date = raw_day_expire_date[24..25]
        end
        # If statement checks for "/" in output to see where the first number for Day starts
        if raw_day_expire_date[25] == '/' && raw_day_expire_date[27] == '/'
          clean_day_expire_date = raw_day_expire_date[26]
        elsif raw_day_expire_date[25] != '/' && raw_day_expire_date[28] == '/'
          clean_day_expire_date = raw_day_expire_date[27]
        elsif raw_day_expire_date[25] == '/' && raw_day_expire_date[26] != '/' && raw_day_expire_date[27] != '/' && raw_day_expire_date[28] == '/'
          clean_day_expire_date = raw_day_expire_date[26..27]
        elsif raw_day_expire_date[25] != '/' && raw_day_expire_date[26] == '/' && raw_day_expire_date[27] != '/' && raw_day_expire_date[28] != '/' && raw_day_expire_date[29] == '/'
          clean_day_expire_date = raw_day_expire_date[27..28]
         end
        # If statement checks for last "/" before year starts
        if raw_day_expire_date[27] == '/'
          clean_year_expire_date = raw_day_expire_date[28..31]
        elsif raw_day_expire_date[28] == '/'
          clean_year_expire_date = raw_day_expire_date[29..32]
        elsif raw_day_expire_date[29] == '/'
          clean_year_expire_date = raw_day_expire_date[30..33]
         end

        # date expire setup as dd/mm/yyyy
        date_expires = clean_day_expire_date + '/' + clean_month_expire_date + '/' + clean_year_expire_date
        # Determines the number of days difference
        date_expires_minus_password_last_set = DateTime.parse(date_expires).mjd - DateTime.parse(date_created).mjd

        if date_expires_minus_password_last_set <= 3
          describe "Temporary Account is within 3 days since creation and expiration: #{user}" do
            skip "Temporary Account is within 3 days since creation and expiration: #{user}"
          end
        else
          describe 'Account Expiration' do
            it "Temporary Account #{user} Creation date and Expiration date is" do
              failure_message = 'more than 3 days'
              expect(date_expires_minus_password_last_set).to be_empty, failure_message
            end
          end
        end
      end
    end
 end

  temp_account_local = input('temp_account_local')
  if domain_role != '4' || domain_role != '5'
    if temp_account_local.empty?
      describe 'There are no accounts in input temp_account_local, nothing will run' do
        skip 'There are no accounts in input temp_account_local, nothing will run'
      end
    else
      temp_account_local.each do |user|
        # Gets Raw Account Expiration Date for Local Account
        get_account_expires = powershell("Get-LocalUser -name #{user}  | Select-Object AccountExpires").stdout.strip

        # Gets Local Accounts Month of Expiration Date
        if get_account_expires[47] == '/'
          clean_account_expires_month = get_account_expires[46]
        else
          clean_account_expires_month = get_account_expires[46..47]
        end
        # If statement checks for "/" in output to see where the first number for Day starts
        if get_account_expires[47] == '/' && get_account_expires[49] == '/'
          clean_account_expires_day = get_account_expires[48]
        elsif get_account_expires[47] != '/' && get_account_expires[50] == '/'
          clean_account_expires_day = get_account_expires[49]
        elsif get_account_expires[47] == '/' && get_account_expires[48] != '/' && get_account_expires[49] != '/' && get_account_expires[50] == '/'
          clean_account_expires_day = get_account_expires[48..49]
        elsif get_account_expires[47] != '/' && get_account_expires[48] == '/' && get_account_expires[49] != '/' && get_account_expires[50] != '/' && get_account_expires[51] == '/'
          clean_account_expires_day = get_account_expires[49..50]
        end

        # If statement checks for last "/" before year starts
        if get_account_expires[49] == '/'
          clean_account_expires_year = get_account_expires[50..53]
        elsif get_account_expires[50] == '/'
          clean_account_expires_year = get_account_expires[51..54]
        elsif get_account_expires[51] == '/'
          clean_account_expires_year = get_account_expires[52..55]
        end

        # date account expires by starts setup as dd/mm/yyyy
        date_account_expires = clean_account_expires_day + '/' + clean_account_expires_month + '/' + clean_account_expires_year

        # Gets Raw Password Last Set Date for Local Account
        get_password_last_set = powershell("Get-LocalUser -name #{user} | Select-Object PasswordLastSet").stdout.strip
        # Gets Local Accounts Month of Expiration Date
          if get_password_last_set[43] == '/'
             clean_account_last_pass_month =  get_password_last_set[42]
         else
            clean_account_last_pass_month =   get_password_last_set[42..43]
         end

        # If statement checks for "/" in output to see where the first number for Day starts
        if get_password_last_set[43] == '/' && get_password_last_set[45] == '/'
          clean_account_last_pass_day = get_password_last_set[44]
        elsif get_password_last_set[43] != '/' && get_password_last_set[46] == '/'
          clean_account_last_pass_day = get_password_last_set[45]
        elsif get_password_last_set[43] == '/' && get_password_last_set[44] != '/' && get_password_last_set[45] != '/' && get_password_last_set[46] == '/'
          clean_account_last_pass_day = get_password_last_set[44..45]
        elsif get_password_last_set[43] != '/' && get_password_last_set[44] == '/' && get_password_last_set[45] != '/' && get_password_last_set[46] != '/' && get_password_last_set[47] == '/'
          clean_account_last_pass_day = get_password_last_set[45..46]
        end

        # If statement checks for last "/" before year starts
        if get_password_last_set[45] == '/'
          clean_account_last_pass_year = get_password_last_set[46..49]
        elsif get_password_last_set[46] == '/'
          clean_account_last_pass_year = get_password_last_set[47..50]
        elsif get_password_last_set[47] == '/'
          clean_account_last_pass_year = get_password_last_set[48..51]
        end

        # date expire setup as dd/mm/yyyy
        date_expire_last_set = clean_account_last_pass_day + '/' + clean_account_last_pass_month + '/' + clean_account_last_pass_year
        # Determines the number of days difference
        date_expires_minus_password_last_set = DateTime.parse(date_account_expires).mjd - DateTime.parse(date_expire_last_set).mjd

        if date_expires_minus_password_last_set <= 3
          describe "Temporary Account is within 3 days since creation and expiration: #{user}" do
            skip "Temporary Account is within 3 days since creation and expiration: #{user}"
          end
        else
          describe 'Account Expiration' do
            it "Temporary Account #{user} Expiration date and Password Last Set is" do
              failure_message = 'more than 3 days'
              expect(date_expires_minus_password_last_set).to be_empty, failure_message
            end
          end
        end
      end
   end
  end
end
