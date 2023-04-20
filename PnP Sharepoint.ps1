

#Install-Module -Name "SharePointPnPPowerShellOnline"

$client = "guid"
$tenant = "insert-tenant"
$site = "team name"
$relpath = "subfolder"
$user = "email"

$url = "https://$tenant.sharepoint.com/sites/$site"
$url_deco = "https://$tenant.sharepoint.com/sites/$site/$sitepath"

#$cred = $host.ui.PromptForCredential("Enter credentials", "Enter user/pass.", $user, "NetBiosUserName")


Connect-PnPOnline -ClientId $client -Url $url -Interactive

#Get-PnPList Documents
#Get-PnPFolder -Url $url_deco

#Get-PnPAzureADAppPermission

#Get-Pnp -Url $url_deco

#Add-PnPFolder -Name "NewFolder2" -Folder $relpath