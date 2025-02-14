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
    ____                               __         ______  ____  _ __    
   / __ \____ _      _____  __________/ /_  ___  / / / / / / /_(_) /____
  / /_/ / __ \ | /| / / _ \/ ___/ ___/ __ \/ _ \/ / / / / / __/ / / ___/
 / ____/ /_/ / |/ |/ /  __/ /  (__  ) / / /  __/ / / /_/ / /_/ / (__  ) 
/_/    \____/|__/|__/\___/_/  /____/_/ /_/\___/_/_/\____/\__/_/_/____/  

Powershell Utils v$version
"@

Write-Host $logo -ForeGroundColor Cyan