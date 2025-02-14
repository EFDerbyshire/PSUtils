# This file contains functions for finding & manipulating users.

function Get-ADUsers
{
    <#
        .SYNOPSIS
        Queries AD with a list of users from a given file and outputs the results.

        .DESCRIPTION
        Queries AD with a list of users from a given file and outputs the results.

        .PARAMETER Path
        Location of the file containing your list of users. Must be .txt!

        .PARAMETER SearchType
        Specifies whether to check for legal names 'DisplayName' or logon names 'SamAccountName'

        Valid options:
        - "DisplayName"    : Search using legal names (John Smith).
        - "SamAccountName" : Search using logon names (jsmith).

        .PARAMETER Fuzzy
        Add this flag for widened search criteria for name matching. This will query every user object!

        .EXAMPLE
        PS C:\> Get-PSUtilADUsers -Path "C:\Users\You\Documents\names.txt" -SearchType "DisplayName"

        Retrieves user details based on legal name search from given file (John Smith).

        .EXAMPLE
        PS C:\> Get-PSUtilADUsers -Path "C:\Users\You\Documents\names.txt" -SearchType "SamAccountName" -Fuzzy
        
        Retrieves user details based on login name search from given file (jsmith) with widened search criteria.
    #>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DisplayName", "SamAccountName")]
        [string]$SearchType,
        [switch]$Fuzzy
    )

    Begin 
    {
        # Initialise results array.
        $OutputTable = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process 
    {
        $NameList = Get-Content $Path
        ForEach($Name in $NameList) 
        {
            if ($Fuzzy)
            { 
                Write-Host "Beginning fuzzy search for user $Name. This may take some time!"
                $Users = Get-ADUser -Filter * -Properties $SearchType | Where-Object { $_.$SearchType -match $Name}
                if ($Users) { Write-Host "Found entries for $Name" } else { Write-Host "Could not find users with name $Name" }
            }
            else
            { 
                $Users = Get-ADUser -Filter "$SearchType -like '$Name'" -Properties DisplayName
            }
            ForEach($User in $Users) 
            {
                $OutputTable.Add([PSCustomObject]@{
                        Username = $User.SamAccountName
                        FullName = $User.DisplayName
                        Email = $User.EmailAddress
                })
            }
        }
    }

    End
    {
        return $OutputTable
    }
}