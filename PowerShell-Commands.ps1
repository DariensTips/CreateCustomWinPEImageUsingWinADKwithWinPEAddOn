########### --Basic WinPE ISO-- ###########

$ADKWPEPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"
$winPE = "C:\WinPE_amd64"
$winPEISO = "$winPE\ISO"
copype amd64 $winPEISO
MakeWinPEMedia /ISO $winPEISO $winPEISO\WinPE_amd64.iso


########### --Custom WinPE ISO-- ###########

# -- Set Variables
$ADKWPEPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"
$winPE = "C:\WinPE_amd64"
$winPEMount = "$winPE\mount"
$winPEISO = "$winPE\ISO"
$PackagePath = "$ADKWPEPath\WinPE_OCs"
$lang="en-us"

# -- Mount base Winpe image
New-Item -Type Directory $winPEMount
Dism /Mount-Image /ImageFile:"$ADKWPEPath\$lang\winpe.wim" /index:1 /MountDir:$winPEMount

# -- Add Drivers
Dism /image:$winPEMount /Add-Driver /Driver:C:\Temp\Drivers\Windows10-x64\LewisburgSystem.inf
Dism /Image:$winPEMount /Get-Drivers

# -- Add PowerShell and other components
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-WMI.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-WMI_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-NetFX.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-NetFX_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-Scripting.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-Scripting_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-PowerShell.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-PowerShell_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-StorageWMI_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-DismCmdlets_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-SecureStartup.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-SecureStartup_$lang.cab"
# -- other optional components --#
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-EnhancedStorage.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-EnhancedStorage_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-PmemCmdlets.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\$lang\WinPE-PmemCmdlets_$lang.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-PlatformId.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-SecureBootCmdlets.cab"
Dism /Add-Package /Image:$winPEMount /PackagePath:"$PackagePath\WinPE-HSP-Driver.cab"

# -- Change winpe.jpg permissions
$daFile = "$winPEMount\Windows\System32\winpe.jpg"
$NewAcl = Get-Acl -Path $daFile
# Set properties
$identity = "BUILTIN\Administrators"
$fileSystemRights = "FullControl"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path $daFile -AclObject $NewAcl

# -- Copy custome winpe.jpg file
$daRenamedFile = "$winPEMount\Windows\System32\winpe(OE).jpg"
Rename-Item $daFile $daRenamedFile
copy c:\temp\winpe.jpg $winPEMount\Windows\System32

# -- Unmount and make ISO
Dism /Unmount-Image /MountDir:$winPEMount /commit
copype amd64 $winPEISO
MakeWinPEMedia /ISO $winPEISO $winPEISO\WinPE_amd64.iso

# -- Add openssh to path
$cmdPath = "$winPEMount\Windows\System32\startnet.cmd"
$additionalPath = "X:\Apps\OpenSSH-Win64\OpenSSH-Win64\"

Add-Content -Path $cmdPath -Value "set PATH=%PATH%;$additionalPath"
