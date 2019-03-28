#!/usr/bin/env pwsh

# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

$ErrorActionPreference = 'Stop'

if ($args.Length -gt 0) {
  $Version = $args.Get(0)
}

if ($PSVersionTable.PSEdition -ne 'Core') {
  $IsWindows = $true
  $IsMacOS = $false
}

$BinDir = if ($IsWindows) {
  "$Home\.vba-blocks\bin"
} else {
  "$Home/.vba-blocks/bin"
}

$Zip = if ($IsWindows) {
  'zip'
} else {
  'gz'
}

$VbaBlocksZip = if ($IsWindows) {
  "$BinDir\vba-blocks.$Zip"
} else {
  "$BinDir/vba-blocks.$Zip"
}

$VbaBlocksExe = if ($IsWindows) {
  "$BinDir\vba-blocks.exe"
} else {
  "$BinDir/vba-blocks"
}

$OS = if ($IsWindows) {
  'win'
} else {
  if ($IsMacOS) {
    'osx'
  } else {
    'linux'
  }
}

$VbaBlocksUri = if (!$Version) {
  $Response = Invoke-WebRequest 'https://github.com/vba-blocks/vba-blocks/releases'
  if ($PSVersionTable.PSEdition -eq 'Core') {
    $Response.Links |
      Where-Object { $_.href -like "/vba-blocks/vba-blocks/releases/download/*/vba-blocks_${OS}_x64.$Zip" } |
      ForEach-Object { 'https://github.com' + $_.href } |
      Select-Object -First 1
  } else {
    $HTMLFile = New-Object -Com HTMLFile
    if ($HTMLFile.IHTMLDocument2_write) {
      $HTMLFile.IHTMLDocument2_write($Response.Content)
    } else {
      $ResponseBytes = [Text.Encoding]::Unicode.GetBytes($Response.Content)
      $HTMLFile.write($ResponseBytes)
    }
    $HTMLFile.getElementsByTagName('a') |
      Where-Object { $_.href -like "about:/vba-blocks/vba-blocks/releases/download/*/vba-blocks_${OS}_x64.$Zip" } |
      ForEach-Object { $_.href -replace 'about:', 'https://github.com' } |
      Select-Object -First 1
  }
} else {
  "https://github.com/vba-blocks/vba-blocks/releases/download/$Version/vba-blocks_${OS}_x64.$Zip"
}

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

Invoke-WebRequest $VbaBlocksUri -Out $VbaBlocksZip

if ($IsWindows) {
  Expand-Archive $VbaBlocksZip -Destination $BinDir -Force
  Remove-Item $VbaBlocksZip
} else {
  gunzip -df $VbaBlocksZip
}

if ($IsWindows) {
  $User = [EnvironmentVariableTarget]::User
  $Path = [Environment]::GetEnvironmentVariable('Path', $User)
  if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
    [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
    $Env:Path += ";$BinDir"
  }
  Write-Output "vba-blocks was installed successfully to $VbaBlocksExe"
  Write-Output "Run 'vba-blocks help' to get started"
} else {
  chmod +x "$BinDir/vba-blocks"
  Write-Output "vba-blocks was installed successfully to $VbaBlocksExe"
  if (Get-Command vba-blocks -ErrorAction SilentlyContinue) {
    Write-Output "Run 'vba-blocks help' to get started"
  } else {
    Write-Output "Manually add the directory to your `$HOME/.bash_profile (or similar)"
    Write-Output "  export PATH=`"${BinDir}:`$PATH`""
    Write-Output "Run '$VbaBlocksExe help' to get started"
  }
}
