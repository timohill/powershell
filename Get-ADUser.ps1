
Get-ADUser -filter {name -like "enter-name"} -properties * #| `
    #Select SamAccountName, extensionAttribute7, extensionAttribute5, extensionAttribute15, UserPrincipalName, Company

