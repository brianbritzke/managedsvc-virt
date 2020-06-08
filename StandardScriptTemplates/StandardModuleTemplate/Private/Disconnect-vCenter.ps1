<#
.SYNOPSIS
Disconnects from a target vCenter,
.DESCRIPTION
This script is an internal function to disconnect from a vCenter.
.NOTES
Author: Kevin McClure
#>
Function Disconnect-vCenter {

    Disconnect-VIServer * -Confirm:$False -Verbose:$false

}