# This file contains functions for finding & manipulating users.

# Gets a list of users with a given name.
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
        Specifies whether to check for legal names 'DisplayName' or logon names 'LoginName'

        Valid options:
        - "DisplayName" : Search using legal names (John Smith).
        - "LoginName" : Search using logon names (jsmith).

        .EXAMPLE
        PS C:\>Get-PSUtilADUsers -Path "C:\Users\You\Documents\names.txt" -SearchType "DisplayName"

        Retrieves user details based on legal name search from given file (John Smith).

        .EXAMPLE
        PS C:\>Get-PSUtilADUsers - Path "C:\Users\You\Documents\names.txt" -SearchType "LoginName"
        
        Retrieves user details based on login name search from given file (jsmith2).
    #>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DisplayName", "LoginName")]
        [string]$SearchType
    )
    Begin 
    {
        # Initialise results array.
        $OutputTable = [System.Collections.Generic.List[PSObject]]::new()

        $SearchTypeMap = @{
            "DisplayName" = "DisplayName"
            "LoginName" = "SamAccountName"
        }
    }
    Process 
    {
        $NameList = Get-Content $Path
        $SearchAttrib = $SearchTypeMap[$SearchType]

        ForEach($Name in $NameList) 
        {
            $Users = Get-ADUser -Filter "$SearchAttrib -like '$Name'" -Properties DisplayName
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
