param (
    [string]$driveLetter = "t",
    [string]$volumeName = "SQLTempDBVol",
    [string]$poolName = "SQLTempDBPool",
    [string]$diskName = "SQLTempDBDisk",
    [Switch]$NoStartSQLServer
)

$volume = Get-Volume -FileSystemLabel $volumeName

#Check if volume already exists
if (!$volume)
{

    # Get all possible disks
    $physicalDisks = Get-PhysicalDisk –CanPool $True | ? FriendlyName -Like 'NVMe Amazon EC2 NVMe'
    
    # If disks are available create the pool, disk and volume
    if ($physicalDisks -ne $null)
    {
        $storageSubsystem = Get-StorageSubsystem | ? FriendlyName -Like "Windows Storage on*"
        $storagePool = New-StoragePool –FriendlyName $poolName -StorageSubSystemFriendlyName $storageSubsystem.FriendlyName -PhysicalDisks $physicaldisks
        $storagePool = Get-StoragePool -FriendlyName $poolName

        $virtualDisk = New-VirtualDisk –FriendlyName $diskName –StoragePoolFriendlyName $storagePool.FriendlyName -UseMaximumSize -ResiliencySettingName Simple
        $virtualDisk = Get-Disk -FriendlyName $diskName

        $volume = New-Volume -FriendlyName $volumeName -DiskNumber $virtualDisk.DiskNumber -FileSystem NTFS -DriveLetter $driveLetter 
        $volume = Get-Volume -FileSystemLabel $volumeName
    
        # Assign permissions
        $path = $volume.DriveLetter + ":\"
        $dir = Get-Item -LiteralPath $path
        $acl = $dir.GetAccessControl()
        $ace = "Everyone","FullControl","Allow"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $ace
        $acl.SetAccessRule($rule)
        $dir.SetAccessControl($acl)
    }
}

if (!$NoStartSQLServer)
{
    #  Restart SQL so it can create tempdb on new drive
    #Stop-Service SQLSERVERAGENT
    #Stop-Service MSSQLSERVER
    Start-Service SQLSERVERAGENT
    Start-Service MSSQLSERVER
}
