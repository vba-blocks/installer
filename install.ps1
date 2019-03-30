# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

$ErrorActionPreference = 'Stop'

if ($args.Length -gt 0) {
  $Version = $args.Get(0)
}

$LibDir = "env:APPDATA\vba-blocks"
$BinDir ="$LibDir\bin"
$ZipFile = "$LibDir\vba-blocks.$Zip"

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

# TODO Create symlink from each add-in to "env:APPDATA\Microsoft\Addins"

# TODO Look into updating registry for HKCU\Software\Microsoft\Office\VERSION\APPLICATION\Security: AccessVBOM=1
# See https://github.com/vba-blocks/vba-blocks/blob/833e86d3f16aca2caa588d594d9361c2fddd5f0c/installer/actions/src/registry.rs#L89

Write-Output "vba-blocks was installed successfully!"
Write-Output "Run 'vba --help' to get started"
