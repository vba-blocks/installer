# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

$ErrorActionPreference = 'Stop'

if ($args.Length -gt 0) {
  $Version = $args.Get(0)
}

$LibDir = "$env:APPDATA\vba-blocks"
$BinDir ="$LibDir\bin"
$ZipFile = "$LibDir\vba-blocks.zip"
$AddinsDir = "$LibDir\addins\build"

$ReleaseUri = if (!$Version) {
  $Response = Invoke-WebRequest "https://github.com/vba-blocks/vba-blocks/releases"

  $HTMLFile = New-Object -Com HTMLFile
  if ($HTMLFile.IHTMLDocument2_write) {
    $HTMLFile.IHTMLDocument2_write($Response.Content)
  } else {
    $ResponseBytes = [Text.Encoding]::Unicode.GetBytes($Response.Content)
    $HTMLFile.write($ResponseBytes)
  }
  $HTMLFile.getElementsByTagName('a') |
    Where-Object { $_.href -like "about:/vba-blocks/vba-blocks/releases/download/*/vba-blocks-win.zip" } |
    ForEach-Object { $_.href -replace 'about:', 'https://github.com' } |
    Select-Object -First 1
} else {
  "https://github.com/vba-blocks/vba-blocks/releases/download/$Version/vba-blocks-win.zip"
}

if (!(Test-Path $LibDir)) {
  New-Item $LibDir -ItemType Directory | Out-Null
}

Write-Output "[1/5] Downloading vba-blocks..."
Write-Output "($ReleaseUri)"
Invoke-WebRequest $ReleaseUri -Out $ZipFile

Write-Output "[2/5] Extracting vba-blocks..."
Expand-Archive $ZipFile -Destination $LibDir -Force
Remove-Item $ZipFile

Write-Output "[3/5] Adding vba-blocks to PATH..."
$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
  $Env:Path += ";$BinDir"
}

function New-Shortcut ($Src, $Dest) {
  Try {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Dest)
    $Shortcut.TargetPath = $Src
    $Shortcut.Save()
  } Catch {
    Write-Output "Failed to link add-ins, they can instead be found in $AddinsDir."
  }
}

Write-Output "[4/5] Creating shortcut to add-ins..."
New-Shortcut "$AddinsDir" "$env:AppData\Microsoft\Addins\vba-blocks Add-ins.lnk"

function Enable-VBOM ($App) {
  Try {
    $CurVer = Get-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\$App.Application\CurVer -ErrorAction Stop
    $Version = $CurVer.'(default)'.replace("$App.Application.", "") + ".0"

    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\$Version\$App\Security -Name AccessVBOM -Value 1 -ErrorAction Stop
  } Catch {
    Write-Output "Failed to enable access to VBA project object model for $App."
  }
}

Write-Output "[5/5] Enabling access to VBA project object model..."
Enable-VBOM "Excel"
# TODO Enable-VBOM "Word"
# TODO Enable-VBOM "PowerPoint"
# TODO Enable-VBOM "Access"

Write-Output ""
Write-Output "Success! vba-blocks was installed successfully."
Write-Output "Run 'vba --help' to get started"
