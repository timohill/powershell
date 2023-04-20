###########################################################
# AUTHOR  : Tim Hill
###########################################################

#List of workspaces admin has access to.
#

#Run this via Windows Powershell ISE (doesn't need admin)
#Install-Module -Name MicrosoftPowerBIMgmt
#The install requires dev acct
#Login-PowerBI #command stopped working

$User = "tim.hill@resources.qld.gov.au"
#$PW = ""

#$SecPasswd = ConvertTo-SecureString $PW -AsPlainText -Force
#$myCred = New-Object System.Management.Automation.PSCredential($User,$SecPasswd)
$myCred = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", $User, "NetBiosUserName")

Connect-PowerBIServiceAccount -Credential $myCred


$items = Get-PowerBIWorkspace -All
#$items = Get-PowerBIWorkspace -Scope Individual
#$items = Get-PowerBIWorkspace -All -First
#$items = Get-PowerBIWorkspace -Scope Organization

$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "C:\tmp\ExportPBIWorkspaces.csv"

$items | Select-Object *, @{Name="LogDateTime"; Expression={$LogDateTime}} | export-csv -Path $csvfile -NoTypeInformation


