

#when a person was added to the Pro group


Function Get-ADGroupMemberDate {
     
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
        [string]$Group
         
    )
    Begin {
         
        [regex]$pattern = '^(?<State>\w+)\s+member(?:\s(?<DateTime>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(?:.*\\)?(?<DC>\w+|(?:(?:\w{8}-(?:\w{4}-){3}\w{12})))\s+(?:\d+)\s+(?:\d+)\s+(?<Modified>\d+))?'
        $DomainController = ($env:LOGONSERVER -replace "\\\\")
        If(!$DomainController)
        {
            Throw "Computer from which script is run is not joined to domain and domain controller can not be identified."
            Break
        }
    }
    Process
    {
        Write-Verbose "Checking distinguished name of the group $Group"
        Try
        {
            $distinguishedName = (Get-ADGroup -Identity $Group).DistinguishedName
        } 
        Catch 
        {
            Write-Warning "$group can not be found!"
            Break               
        }
        $RepadminMetaData = (repadmin /showobjmeta $DomainController $distinguishedName | Select-String "^\w+\s+member" -Context 2)
        $Array = @()
        ForEach ($rep in $RepadminMetaData) 
        {
           If ($rep.line -match $pattern) 
           {
                
               $object = New-Object PSObject -Property  @{
                    Username = [regex]::Matches($rep.context.postcontext,"CN=(?<Username>.*?),.*") | ForEach {$_.Groups['Username'].Value}
                    LastModified = If ($matches.DateTime) {[datetime]$matches.DateTime} Else {$Null}
                    DomainController = $matches.dc
                    Group = $group
                    State = $matches.state
                    ModifiedCounter = $matches.modified
                }
                 
                $Array += $object
                 
            }
        }
     
    }
    End
    {
        $Array = $Array | Select Username, LastModified, ModifiedCounter
        $Array
    }
}

#vars
$LogDateTime = get-date -f "yyyy-MM-dd hh:mm:ss"
$csvfile = "c:\tmp\ExportADPBIGroup_AddUser.csv"
$SecGrp = "SG-O365-Power_BI_Pro"

$arrList = Get-ADGroupMemberDate -Group $SecGrp

$arrList | Select-Object @{Name="SecurityGroup"; Expression={$SecGrp}}, *, @{Name="LogDateTime"; Expression={$LogDateTime}} | export-csv -Path $csvfile -NoTypeInformation