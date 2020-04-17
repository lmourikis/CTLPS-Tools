Function CTLGet-VirtualDiskSlabs {
<#
.SYNOPSIS
    View physical disks and virtual disks' extents (aka slabs) correlation.
	Created by Lefteris Mourikis (Nov 2019)
#>

    Param (
        [Parameter(Mandatory=$True)]
        [string]$VirtualDiskName

        #[Parameter(Mandatory=$False)]
        #[ValidateSet('Alpha','Beta','Gamma')]
    )

    Begin {
        # Start of the BEGIN block.
		#$CtlVirtualDisk = $(Get-VirtualDisk -FriendlyName $VirtualDiskName | select *)
		$CtlPhysicalExtents = $(Get-VirtualDisk -FriendlyName $VirtualDiskName | Get-PhysicalExtent | select *)
		
		##$CtlPysicalExtentsCount = $($CtlPhysicalExtents | Measure).Count

		
		$CtlResultTmp = $CtlPhysicalExtents.PhysicalDiskUniqueId | Get-PhysicalDisk | `
			select @{Name="DiskUniqueID";Expression={$_.UniqueID}}, @{Name="DiskSerialNumber";Expression={$_.SerialNumber}}, `
			OperationalStatus, HealthStatus, Usage, `
			@{Name="HostName";Expression={$(Get-StorageNode -PhysicalDisk $(Get-PhysicalDisk -UniqueId $_.UniqueId) -PhysicallyConnected)[0].Name}}

		$CtlResult = $CtlResultTmp | select *, @{Name="ExtentsCount";Expression={$($CtlResultTmp | ? DiskUniqueID -eq $_.DiskUniqueID | Measure).Count}} `
			| Sort-Object -Property DiskUniqueID -Unique | Sort-Object -Property HostName
		
    } # End Begin block

    Process {
        # Start of PROCESS block.


    } # End of PROCESS block.

    End {
        # Start of END block.
		$CtlResult | ft *
        ##Write-Host "Total number of slabs: $CtlPysicalExtentsCount"
		
    } # End of the END Block.
} # End Function


