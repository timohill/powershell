
###########################################################
# AUTHOR  : Tim Hill
###########################################################

#List of securityGroups, pathNames, folderNames

$baseFolder = "\\lands\data\resources\pbi\"
$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "c:\tmp\ExportPBIFoldersAccessSecurity.csv"

$output = @()
$rcd = @{
"PathName" = ""
"FolderName"=""
"SecurityGroup"=""
}


$folders = Get-ChildItem $baseFolder | select Fullname, Name 

Foreach ($folder in $folders)
   {
   $sec = Get-Acl $folder.FullName | 
    Select-Object -ExpandProperty Access |
    Where-Object identityreference -Like "*LANDS\CG-O365-Power-BI-WS-R*Pub" |
    Select-Object identityreference

   $rcd.PathName = $folder.FullName
   $rcd.FolderName = $folder.Name
   $rcd.SecurityGroup = $sec.identityreference

   $objRecord = New-Object PSObject -property $rcd
   $output += $objRecord
   }

$output | Select-Object *, @{Name="LogDateTime"; Expression={$LogDateTime}} | export-csv -Path $csvfile -NoTypeInformation


