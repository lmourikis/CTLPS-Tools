<#
.SYNOPSIS
Export-TeamsMembership.ps1 - v0.1 (7 Apr 2020)

Export a report in CSV with three columns: TeamName, Owners, Members
#>


# Login if required
Get-MsolDomain -ErrorAction SilentlyContinue | out-null
if (-not ($?)) {
    $creds = Get-Credential
    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams -Credential $creds
}

# Init
$k = 0;
$myCsvFile=".\TeamsMembershipReport.csv"
echo '"TeamName";"Owners";"Members"' > "$($myCsvFile)"
Clear-Host
Write-Host "`n`n`n`n`n`n`n`nOutput (if any):`n---"


# Reading all Teams
Write-Progress -Activity "Retrieving Teams info" -Status "Running. It will take a while; please be patient"
$AllTeams = Get-Team | select *

# Parsing each Team
$AllTeams | ForEach-Object {

    # Progress
    $k++
    Write-Progress -Activity "Retrieving Teams info" -Status "Parsing $($k)/$($AllTeams.Count)" -CurrentOperation "Reading info for $($_.DisplayName)." -PercentComplete ($($k)/$($AllTeams.Count)*100)

    # Teachers
    $AllOwners = Get-TeamUser -Role Owner -GroupId $_.GroupId
    $owner = "$($AllOwners[0].User)"
    for ($i=1; $i -le $AllOwners.Count;$i++) {
        $owner = "$($owner),$($AllOwners[$i].User)"
    }
    $owner = "$($owner.Substring(0,$owner.Length-1))" # Delete trailing coma

    # Students
    $AllMembers = Get-TeamUser -Role Member -GroupId $_.GroupId
    $member = "$($AllMembers[0].User)"
    for ($i=1; $i -le $AllMembers.Count;$i++) {
        $member = "$($member),$($AllMembers[$i].User)"
    }
    $member = "$($member.Substring(0,$member.Length-1))" # Delete trailing coma

    # Build our row and export it to our CSV
    $Row = [PSCustomObject]@{TeamName = "$($_.DisplayName)"; Owners = "$($owner)"; Members = "$($member)"}
    $Row | Export-csv -Path "$($myCsvFile)" -Encoding UTF8 -Delimiter ";" -Append
}

# Complete and close progress dialog
Write-Progress -Completed -Activity Completed
Write-Host "`nComplete!`n"



