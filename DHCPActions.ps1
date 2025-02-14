# This file contains functions for DHCP management.

function Clear-DHCPScopeLeases
{    
    <#
        .SYNOPSIS
        Clears DHCP scopes with a specified number of available leases. 

        .DESCRIPTION
        Checks script defined DHCP servers and scopes. Scopes at or below a specified number of available leases are automatically purged.

        .PARAMETER PurgeValue
        The number of available leases below which a scope will be purged. e.g, PurgeValue 50 will clear any scope with 50 or fewer
        available leases. Recommended value: 20. 

        .EXAMPLE

        PS C:\> Clear-PSUDHCPScopeLeases -PurgeValue 50

        Statistics:

        Server              Scope      Available Leases Leases in Use Purged
        ------              -----      ---------------- ------------- ------
        dhcp-01.example.com 10.10.10.0              235            10   True
        dhcp-01.example.com 10.10.20.0              185            56  False
        dhcp-01.example.com 10.10.30.0              173            72  False
        dhcp-02.example.com 10.20.10.0              87            158  False
        dhcp-02.example.com 10.20.20.0              99            146  False
        dhcp-02.example.com 10.20.30.0              212            33  False
    #>

    [cmdletbinding()]
    Param (
        [int]$PurgeValue = 20
    )

    Begin
    {
        $DHCPServers = @(
            "dhcp-01.example.com",
            "dhcp-02.example.com"
        )
        $Scopes = @{
            "dhcp-01.example.com" = @(
                "10.10.10.0",
                "10.10.20.0",
                "10.10.30.0"
            )
            "dhcp-02.example.com" = @(
                "10.20.10.0",
                "10.20.20.0",
                "10.20.30.0"
            )
        }
        $OutputTable = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process
    {
        Write-Host "Looking for scopes with $PurgeValue or fewer available addresses..."
        ForEach ($DHCPServer in $DHCPServers)
        {
            Write-Host "Scanning $DHCPServer..."
            ForEach ($Scope in $Scopes[$DHCPServer])
            {
                $ScopePurged = $False
                Write-Host "Scanning $Scope..."
                $ScopeStats = Get-DhcpServerv4ScopeStatistics -ComputerName $DHCPServer -ScopeId $Scope
                Write-Verbose "Free leases for scope $Scope is $($ScopeStats.Free)"
                if ($ScopeStats.Free -le $PurgeValue) 
                {
                    # Reset counter for progress tracking
                    $counter = 0
                    $Leases = Get-DhcpServerv4Lease -ComputerName $DHCPServer -ScopeId $Scope
                    ForEach ($Lease in $Leases)
                    {
                        # Progress bar
                        $counter++
                        $PercentComplete = ($counter / $Leases.Count) * 100
                        Write-Progress -Activity "Purging $Scope" -Status "Processing $counter of $($Leases.Count)" -PercentComplete $PercentComplete

                        $k = Remove-DhcpServerv4Lease -ComputerName $DHCPServer -IPAddress $Lease.IPAddress -ErrorAction SilentlyContinue
                        if ($k) 
                        { 
                            Write-Verbose "Removed lease for $($Lease.IPAddress)." 
                        }
                        else 
                        { 
                            Write-Host "Failed to remove lease for $($Lease.IPAddress)!" -ForegroundColor Red 
                        }
                    }
                    Write-Progress -Activity "Purging $Scope" -Completed
                    Write-Host "Purge complete!"
                    $ScopePurged = $true
                }
                $ScopeStats = Get-DhcpServerv4ScopeStatistics -ComputerName $DHCPServer -ScopeId $Scope
                $OutputTable.Add([PSCustomObject]@{
                    "Server" = $DHCPServer
                    "Scope" = $Scope
                    "Available" = $ScopeStats.Free
                    "In Use" = $ScopeStats.Free
                    "Purged" = $ScopePurged
                })
            }
        }
    }

    End
    {
        Write-Host "Statistics:"
        return $OutputTable | Format-Table
    }
}