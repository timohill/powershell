###########################################################
# AUTHOR  : Tim Hill
###########################################################

Import-Module ActiveDirectory

#vars
$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "C:\tmp\ExportADUsers.csv"

#get base data``
$Users = Get-ADUser `
    -Filter {Company -eq "Resources" -or Company -eq "DNRME"} `
    -Properties SamAccountName, EmailAddress, DisplayName, GivenName, Surname, 
    Title, Enabled, Manager, LastLogonDate, Created, UserPrincipalName,
    Company, Department, Office, Street, City, State, PostalCode, Country,
    extensionAttribute1, extensionAttribute2, extensionAttribute3, extensionAttribute4, extensionAttribute5,
    extensionAttribute6, extensionAttribute7, extensionAttribute8, extensionAttribute9, extensionAttribute10,
    extensionAttribute11, extensionAttribute12, extensionAttribute13, extensionAttribute14, extensionAttribute15

#append logdate and export csv
$Users | Select-Object SamAccountName, EmailAddress, DisplayName, GivenName, Surname, 
    Title, Enabled, Manager, LastLogonDate, Created, UserPrincipalName,
    Company, Department, Office, Street, City, State, PostalCode, Country,
    extensionAttribute1, extensionAttribute2, extensionAttribute3, extensionAttribute4, extensionAttribute5,
    extensionAttribute6, extensionAttribute7, extensionAttribute8, extensionAttribute9, extensionAttribute10,
    extensionAttribute11, extensionAttribute12, extensionAttribute13, extensionAttribute14, extensionAttribute15, 
    @{Name="LogDateTime"; Expression={$LogDateTime}} | export-csv -Path $csvfile -NoTypeInformation


# for all tenancy
#-Filter * ` {Company -eq "Resources" -or Company -eq "DNRME"} `