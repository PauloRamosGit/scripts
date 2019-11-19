$driveLetter = "t"
$volume = Get-Volume -FileSystemLabel "SQLTempDBVol"

#Check if volume already exists
if (!$volume)
{

    # Get all possible disks
    $physicalDisks = Get-PhysicalDisk –CanPool $True | ? FriendlyName -Like 'NVMe Amazon EC2 NVMe'
    
    # If disks are available create the pool, disk and volume
    if ($physicalDisks -ne $null)
    {
        $storageSubsystem = Get-StorageSubsystem | ? FriendlyName -Like "Windows Storage on*"
        $storagePool = New-StoragePool –FriendlyName "SQLTempDBPool" -StorageSubSystemFriendlyName $storageSubsystem.FriendlyName -PhysicalDisks $physicaldisks
        $storagePool = Get-StoragePool -FriendlyName "SQLTempDBPool"

        $virtualDisk = New-VirtualDisk –FriendlyName "SQLTempDBDisk" –StoragePoolFriendlyName $storagePool.FriendlyName -UseMaximumSize -ResiliencySettingName Simple
        $virtualDisk = Get-Disk -FriendlyName "SQLTempDBDisk"

        $volume = New-Volume -FriendlyName "SQLTempDBVol" -DiskNumber $virtualDisk.DiskNumber -FileSystem NTFS -DriveLetter $driveLetter 
        $volume = Get-Volume -FileSystemLabel "SQLTempDBVol"
    }

    # Assign permissions
    $path = $volume.DriveLetter + ":\"
    $dir = Get-Item -LiteralPath $path
    $acl = $dir.GetAccessControl()
    $ace = "Everyone","FullControl","Allow"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $ace
    $acl.SetAccessRule($rule)
    $dir.SetAccessControl($acl)

}

#  Restart SQL so it can create tempdb on new drive
#Stop-Service SQLSERVERAGENT
#Stop-Service MSSQLSERVER
Start-Service SQLSERVERAGENT
Start-Service MSSQLSERVER