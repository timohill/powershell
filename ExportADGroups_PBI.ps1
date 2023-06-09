###########################################################
# AUTHOR  : Tim Hill
###########################################################

#vars
$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "c:\tmp\ExportADGroups_PBI.csv"

#import
#Import-Module ActiveDirectory

#get
$Groups = Get-ADGroup -Filter "((Name -like 'CG-O365-Power*') -or (Name -eq 'SG-O365-Power_BI_Pro'))" -Properties *

$tbl = @()
$rcd = [ordered]@{
"GroupName" = ""
"GroupCreatedDate"=""
"GroupModifiedDate"=""
"GroupDesc"=""
"GroupExtnAttr1"=""
"GroupExtnAttr8"=""
"Username" = ""
}

foreach ($Group in $Groups)
{
$arrMembers = Get-ADGroupMember -identity $Group

foreach ($Member in $arrMembers)
{
$User = Get-ADUser -Filter ({sAMAccountName -eq $Member.SamAccountName}) -Properties *

$rcd."GroupName" = $Group.Name
$rcd."GroupCreatedDate" = $Group.Created
$rcd."GroupModifiedDate" = $Group.Modified
$rcd."GroupDesc" = $Group.Description 
$rcd."GroupExtnAttr1" = $Group.extensionAttribute1
$rcd."GroupExtnAttr8" = $Group.extensionAttribute8
$rcd."Username" = $Member.samaccountname
$objRecord = New-Object PSObject -property $rcd
$tbl += $objRecord
}
}
$tbl | Select-Object *, @{Name="LogDateTime"; Expression={$LogDateTime}} | export-csv -Path $csvfile -NoTypeInformation


