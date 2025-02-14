# Import version number
$manifest = Import-PowerShellDataFile "$PSScriptRoot\PSUtils.psd1"
$version = $manifest.ModuleVersion

# Change Powershell titlebar
try 
{
    $host.UI.RawUI.WindowTitle="PSUtils v$version"    
}
catch {}

# Print module logo
$logo = @"
____________________  _________________       
___  __ \_  ___/_  / / /_  /___(_)__  /_______
__  /_/ /____ \_  / / /_  __/_  /__  /__  ___/
_  ____/____/ // /_/ / / /_ _  / _  / _(__  ) 
/_/     /____/ \____/  \__/ /_/  /_/  /____/ 

PS Utils v$version
"@

Write-Host $logo -ForeGroundColor Yellow