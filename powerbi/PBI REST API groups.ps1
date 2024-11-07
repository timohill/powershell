
## Login
#Connect-PowerBIServiceAccount

Write-Host "**START**" -ForegroundColor Yellow -BackgroundColor DarkGreen

## clear
$groups = @()
$groupUsers = @()
$groupReports = @()
$groupDatasets = @()
$groupDatasources = @()

## parameters
$path = Split-Path -parent "C:\tmp\*.*"
$LogDate = get-date -f yyyyMMddhhmmss
$i=0
$invoke=0

$groups = Get-PowerBIWorkspace -All # | WHERE id -eq '<<GUID>>'


$groups = $groups | 
    SELECT @{n='groupId';e={$_.Id}}, 
            @{n='groupName';e={$_.Name}}, 
            IsReadOnly, IsOnDedicatedCapacity, IsOrphaned,
            CapacityId, Description, Type |
        Sort-Object groupName


## Get Users in each Worskspace
foreach ($group in $groups) {
    $i++
    Write-Output "GET groups ... ($i/$($groups.Count)) ... $($group.groupName)"

    #$WorkspaceObject = Get-PowerBIWorkspace -Id $wsId
    #$WorkspaceObject

    #Write-Host "GET Users ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

  ###users - API
    $pbiURLusers = "https://api.powerbi.com/v1.0/myorg/groups/$($group.groupId)/users"
    ## API call
    $resultJsonUsers = Invoke-PowerBIRestMethod –Url $pbiURLusers –Method GET
    $invoke ++
    $resultObjectUsers = ConvertFrom-Json -InputObject $resultJsonUsers
    
    ## Build the output
    $groupUsers += $resultObjectUsers.Value | 
    SELECT @{n='groupId';e={$group.groupId}}, 
            @{n='groupName';e={$group.groupName}}, 
            @{n='userId';e={$_.identifier}},
            @{n='userName';e={$_.displayName}},
            emailAddress, 
            @{n='userRole';e={$_.groupUserAccessRight}}, 
            @{n='principleType';e={$_.principalType}} |
        SELECT groupId, groupName, userId, userName, userRole, principleType, emailAddress | 
        SORT UserRole, userName 

    #Write-Host "GET Reports ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

  ###reports - API
    $pbiURLreports = "https://api.powerbi.com/v1.0/myorg/groups/$($group.groupId)/reports"
    ## API call
    $resultJsonReports = Invoke-PowerBIRestMethod –Url $pbiURLreports –Method GET
    $invoke ++
    $resultObjectReports = ConvertFrom-Json -InputObject $resultJsonReports  
    
    ## Build the outputv
    $groupReports += $resultObjectReports.Value | 
    SELECT @{n='groupId';e={$group.groupId}}, 
            @{n='groupName';e={$group.groupName}},
            @{n='reportId';e={$_.id}},
            @{n='reportName';e={$_.name}},
            reportType, webUrl, embedUrl, isFromPbix, isOwnedByMe |
        SELECT groupId, groupName, reportId, reportName, reportType, webUrl, embedUrl, isFromPbix, isOwnedByMe
   
    ## Build the output
    #$WorkspaceReports | ft -auto | Where{$_.WorkspaceId -eq $GroupWorkspaceId}

    #Write-Host "GET Datasets ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

  ###datasets - API
    $pbiURLdatasets = "https://api.powerbi.com/v1.0/myorg/groups/$($group.groupId)/datasets"
    ## API call
    $resultJsonDatasets = Invoke-PowerBIRestMethod –Url $pbiURLdatasets –Method GET
    $invoke ++ 
    $resultObjectDatasets = ConvertFrom-Json -InputObject $resultJsonDatasets  

    $groupDatasets_each = @()
    ## Build the outputv
    $groupDatasets_each += $resultObjectDatasets.Value | 
    SELECT @{n='groupId';e={$group.groupId}}, 
            @{n='groupName';e={$group.groupName}},
            @{n='datasetId';e={$_.id}},
            @{n='datasetName';e={$_.name}},
            description, webUrl, reportType, configuredBy, isOnPremGatewayRequired |
        SELECT groupId, groupName, datasetId, datasetName, description, webUrl, reportType, configuredBy, isOnPremGatewayRequired
    $groupDatasets += $groupDatasets_each

    $j=0
    foreach ($dataset in $groupDatasets_each) {
        $j++
        Write-Output "GET datasets ... $j $($dataset.datasetName)"
        #Write-Output "GET datasets ... ($j/$($groupDatasets.Count)) ... $($dataset.datasetName)"

        ## datasources - API
        $pbiURLdatasources = "https://api.powerbi.com/v1.0/myorg/groups/$($group.groupId)/datasets/$($dataset.datasetId)/datasources"

        ## API call
        try {
            $resultJsonDatasources = Invoke-PowerBIRestMethod –Url $pbiURLdatasources –Method GET -ErrorAction SilentlyContinue
            $invoke ++
            $resultObjectDatasources = ConvertFrom-Json -InputObject $resultJsonDatasources

            if ([string]::IsNullOrEmpty($resultJsonDatasources)){
                #Write-Output "Warning: No data returned for dataset: $($dataset.datasetName)"
                continue  # Skip to the next dataset if empty
            }
        } catch {
            Write-Output "Error invoking return null for dataset: $($dataset.datasetName) - $_"
            continue  # Skip to the next dataset if there's an error
        }
        
        ## Build the outputv
        $groupDatasources += $resultObjectDatasources.Value | 
        SELECT @{n='groupId';e={$group.groupId}},
                @{n='groupName';e={$group.groupName}},
                @{n='datasetId';e={$dataset.datasetId}}, 
                @{n='datasetName';e={$dataset.datasetName}},
                datasourceId, gatewayId, datasourceType, connectionDetails |
            SELECT groupId, groupName, datasetId, datasetName, datasourceId, gatewayId, datasourceType, connectionDetails
			
    }

    Write-Output "** COMPLETE **"

}

Write-Host "Workspaces: " $groups.Count " | Users: " $groupUsers.Count " | Reports: " $groupReports.Count " | Datasets: " $groupDatasets.Count -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "Invoked: " $invoke -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "Wait for CSVs to be created ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

#export CSV
$csvGroups = $path + "\pbi-groups-" + $LogDate + ".csv"
$groups | export-csv -Path $csvGroups -NoTypeInformation

$csvWorkspaceUsers = $path + "\pbi-grp-users-" + $LogDate + ".csv"
$groupUsers | export-csv -Path $csvWorkspaceUsers -NoTypeInformation

$csvWorkspaceReports = $path + "\pbi-grp-reports-" + $LogDate + ".csv"
$groupReports | export-csv -Path $csvWorkspaceReports -NoTypeInformation

$csvWorkspaceDatasets = $path + "\pbi-grp-datasets-" + $LogDate + ".csv"
$groupDatasets | export-csv -Path $csvWorkspaceDatasets -NoTypeInformation

$csvWorkspaceDatasourcess = $path + "\pbi-grp-set-src" + $LogDate + ".csv"
$groupDatasources | export-csv -Path $csvWorkspaceDatasourcess -NoTypeInformation

clear-variable -name groups
clear-variable -name groupUsers
clear-variable -name groupReports
clear-variable -name groupDatasets
clear-variable -name groupDatasources

Write-Host "**END**" -ForegroundColor Yellow -BackgroundColor DarkGreen


