###########################################################
# AUTHOR  : Tim Hill
###########################################################

#groupName, managedBy_SAMAcct, managedBy_Name

#vars
$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "c:\tmp\ExportPBIGroupsOwners.csv"

#get
$groups = Get-ADGroup -Filter "(Name -like 'CG-O365-Power-BI-WS-R-*')" -Properties name,managedby |
    select name, managedby

$tbl = @()
$rcd = [ordered]@{
"groupName" = ""
"mngdBySAMAcct"=""
"mngdByName"=""
}

$filtGroups = $groups | ?{$_.managedby -ne $null}
foreach ($item in $filtGroups)
{
$user = Get-ADUser -Identity $item.managedby

$rcd."groupName" = $item.name
$rcd."mngdBySAMAcct" = $user.name
$rcd."mngdByName" = $user.surname + ' ' + $user.givenname

$obj = New-Object PSObject -property $rcd
$tbl += $obj
}

$tbl | export-csv -Path $csvfile -NoTypeInformation
