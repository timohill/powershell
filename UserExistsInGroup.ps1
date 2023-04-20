

<#

$fName = "xxx"
$lName = "yyy"

Get-ADuser -Filter {GivenName -eq $fName -and Surname -eq $lName} `
    -Properties DisplayName, SamAccountName, EmailAddress, GivenName, Surname `
    | select DisplayName, SamAccountName, EmailAddress, GivenName, Surname

#>


$user = "xxxx"
$group = "xxxx-group"
$members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty Name

If ($members -contains $user) 
    {Write-Host "$user exists in $group"} 
    Else 
    {Write-Host "$user does not exist in $group"}


