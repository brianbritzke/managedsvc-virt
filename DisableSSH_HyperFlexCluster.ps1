Change powershell console window size
$pshost = get-host
$pswindow = $pshost.ui.rawui

$newsize = $pswindow.buffersize
$newsize.height = 3000
$newsize.width = 150
$pswindow.buffersize = $newsize

$newsize = $pswindow.windowsize
$newsize.height = 50
$newsize.width = 150
$pswindow.windowsize = $newsize

#clear screen
cls
Write-host "-------------------------------------------------------" -foregroundcolor green
Write-Host "This script does a handful of SSH related things:" -foregroundcolor green
Write-Host "	*It enables the 1 hour time for automatically stopping the SSH service." -foregroundcolor green
Write-Host "	*It will stop SSH on all ESXi hosts in the specified vCenter Cluster." -foregroundcolor green
Write-Host "	*It will also enable the SSH has been enabled warning." -foregroundcolor green
Write-Host "	*It configures the SSH service to start and stop manually.   This is useful for HyperFlex Installs where the hosts reboot but requre SSH to be enabled." -foregroundcolor green
Write-Host "Version: 2.1" -foregroundcolor green
Write-Host "Last Change Date: 08/12/2020" -foregroundcolor green
Write-Host "Author: Brian Britzke, Senior Engineer - Virtualization" -foregroundcolor green
Write-host "-------------------------------------------------------" -foregroundcolor green

#Accept Certificate
Set-PowerCLIConfiguration -invalidcertificateaction "ignore" -confirm:$false > $null

# Get vCenter
$VC = Read-Host "Enter the vCenter Server"
$Clust = Read-Host "Enter the Cluster name that contains the host you want to enable SSH on"

Write-host

# Connect to vCenter
Write-host "Connecting to vCenter server $VC..."
Connect-VIServer $VC > $null
Write-host "Connection to vCenter server $VC completed..."

# Enable SSH
$Hosts = Get-Cluster $Clust | Get-VMhost
ForEach ($esx in $Hosts)
{
  $esx | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | Set-AdvancedSetting -Value "3600" -confirm:$false
  $esx | Get-AdvancedSetting | where {$_.Name -eq "UserVars.SuppressShellWarning"} | Set-AdvancedSetting -Value "0" -Confirm:$false
  Stop-VMHostService -HostService ($esx | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"} ) -Confirm:$false 
  $esx | get-vmhostservice | where-object {$_.key -eq "TSM-SSH"} | set-vmhostservice -policy "Off" -Confirm:$false
}

Write-host "SSH Disabled..."

write-host

Write-host
Disconnect-VIServer -confirm:$false
