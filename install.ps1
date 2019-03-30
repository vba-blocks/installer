# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

$ErrorActionPreference = 'Stop'

if ($args.Length -gt 0) {
  $Version = $args.Get(0)
}

$LibDir = "$env:APPDATA\vba-blocks"
$BinDir ="$LibDir\bin"
$ZipFile = "$LibDir\vba-blocks.$Zip"
$AddinsDir = "$LibDir\addins\build"

$ReleaseUri = if (!$Version) {
  $Response = Invoke-WebRequest 'https://github.com/vba-blocks/vba-blocks/releases'
  $Response.Links |
    Where-Object { $_.href -like "/vba-blocks/vba-blocks/releases/download/*/vba-blocks-*-win.zip" } |
    ForEach-Object { 'https://github.com' + $_.href } |
    Select-Object -First 1
} else {
  "https://github.com/vba-blocks/vba-blocks/releases/download/$Version/vba-blocks-$Version-win.zip"
}

if (!(Test-Path $LibDir)) {
  New-Item $LibDir -ItemType Directory | Out-Null
}

Invoke-WebRequest $ReleaseUri -Out $ZipFile

Expand-Archive $ZipFile -Destination $LibDir -Force
Remove-Item $ZipFile

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

Enable-VBOM "Excel"
# TODO Enable-VBOM "Word"
# TODO Enable-VBOM "PowerPoint"
# TODO Enable-VBOM "Access"

Write-Output "vba-blocks was installed successfully!"
Write-Output "Run 'vba --help' to get started"
