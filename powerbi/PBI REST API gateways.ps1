
## Login
#Connect-PowerBIServiceAccount

Write-Host "**START**" -ForegroundColor Yellow -BackgroundColor DarkGreen

## parameters
$path = Split-Path -parent "C:\tmp\*.*"
$LogDate = get-date -f yyyyMMddhhmmss
$i=0
$gwDatasources = @()

    ## 
    ##

$gateways = @(
    [PSCustomObject]@{ gatewayId = "<<enter the gateway1 guide>>"; gatewayName = "<<>>"; gatewayServer = "<<>>" },
    [PSCustomObject]@{ gatewayId = "<<enter the gateway2 guide>>"; gatewayName = "<<>>"; gatewayServer = "<<>>" }
)

$gateways.Count

## Get Users in each Worskspace
foreach ($gateway in $gateways) {
    $i++
    Write-Output "GET ... ($i/$($gateways.Count)) ... $($gateway.gatewayName)"
    
  ###users - API
    $apiURL = "https://api.powerbi.com/v1.0/myorg/gateways/$($gateway.gatewayId)/datasources"
    ## API call

    $resultJson = Invoke-PowerBIRestMethod –Url $apiURL –Method GET 
    $resultObj = ConvertFrom-Json -InputObject $resultJson
    
    ## Build the output
    $gwDatasources += $resultObj.Value | 
    SELECT @{n='gatewayId';e={$gateway.gatewayId}}, 
            @{n='gatewayName';e={$gateway.gatewayName}}, 
            @{n='gatewayServer';e={$gateway.gatewayServer}}, 
            @{n='datasourceId';e={$_.id}}, 
            datasourceName, datasourceType, connectionDetails, credentialType, credentialDetails |
        SELECT gatewayId, gatewayName, gatewayServer, datasourceId, datasourceName, datasourceType, connectionDetails, credentialType, credentialDetails | 
        SORT gatewayName, datasourceName 


    clear-variable -name resultJson
    clear-variable -name resultObj

    Write-Output "** COMPLETE **"

}

Write-Host "Gateways: " $gateways.Count " | dataSources: " $gwDatasources.Count -ForegroundColor Yellow -BackgroundColor DarkGreen

#export CSV
$csv = $path + "\pbi-gw-datasources-" + $LogDate + ".csv"
$gwDatasources | export-csv -Path $csv -NoTypeInformation

clear-variable -name gateways

Write-Host "**END**" -ForegroundColor Yellow -BackgroundColor DarkGreen
