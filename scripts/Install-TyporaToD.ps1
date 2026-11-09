<#
.SYNOPSIS
  Download and silently install Typora onto the D: drive.

.DESCRIPTION
  Maps the usual C:\Program Files (x86)\Typora layout to
  D:\Program Files (x86)\Typora. Uses the official Inno Setup installer
  with /DIR so the install root stays on D:.

.PARAMETER InstallDir
  Target directory. Default: D:\Program Files (x86)\Typora

.PARAMETER Architecture
  Installer architecture: x64 (default), ia32, or arm64.

.PARAMETER AllUsers
  Install for all users (requires elevation). Default: $true.

.EXAMPLE
  # Elevated PowerShell:
  .\Install-TyporaToD.ps1

.EXAMPLE
  .\Install-TyporaToD.ps1 -InstallDir 'D:\Program Files (x86)\Typora' -Architecture x64
#>
[CmdletBinding()]
param(
    [string]$InstallDir = 'D:\Program Files (x86)\Typora',

    [ValidateSet('x64', 'ia32', 'arm64')]
    [string]$Architecture = 'x64',

    [bool]$AllUsers = $true
)

$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-DriveD {
    if (-not (Test-Path -LiteralPath 'D:\')) {
        throw 'D: drive was not found. Attach or create D: before running this script.'
    }
}

function Get-TyporaDownloadUrl {
    param([string]$Arch)

    # Official download CDN used by typora.io Windows builds.
    switch ($Arch) {
        'x64'   { return 'https://download.typora.io/windows/typora-setup-x64.exe' }
        'ia32'  { return 'https://download.typora.io/windows/typora-setup-ia32.exe' }
        'arm64' { return 'https://download.typora.io/windows/typora-setup-arm64.exe' }
        default { throw "Unsupported architecture: $Arch" }
    }
}

Assert-DriveD

if ($AllUsers -and -not (Test-IsAdministrator)) {
    throw 'All-users install requires an elevated PowerShell (Run as administrator).'
}

$parent = Split-Path -Parent $InstallDir
if (-not (Test-Path -LiteralPath $parent)) {
    Write-Host "Creating directory: $parent"
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$tempDir = Join-Path $env:TEMP 'typora-install-d'
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$url = Get-TyporaDownloadUrl -Arch $Architecture
$installer = Join-Path $tempDir ("typora-setup-{0}.exe" -f $Architecture)

Write-Host "Downloading Typora ($Architecture) ..."
Write-Host "  URL: $url"
# Some CDNs reject non-browser clients; send a normal desktop User-Agent.
$headers = @{
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
}
Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing -Headers $headers

if (-not (Test-Path -LiteralPath $installer)) {
    throw "Download failed: $installer"
}

$sizeMb = [math]::Round((Get-Item -LiteralPath $installer).Length / 1MB, 2)
Write-Host "Downloaded: $installer ($sizeMb MB)"

# Close a running Typora so the installer does not fail with exit code 5.
Get-Process -Name 'Typora' -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping running Typora (PID $($_.Id)) ..."
    $_ | Stop-Process -Force
}

$scopeSwitch = if ($AllUsers) { '/ALLUSERS' } else { '/CURRENTUSER' }
$args = @(
    '/VERYSILENT',
    '/SUPPRESSMSGBOXES',
    '/NORESTART',
    '/SP-',
    $scopeSwitch,
    ('/DIR="{0}"' -f $InstallDir),
    ('/LOG="{0}"' -f (Join-Path $tempDir 'typora-install.log'))
)

Write-Host "Installing to: $InstallDir"
Write-Host "Command: `"$installer`" $($args -join ' ')"

$proc = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
if ($proc.ExitCode -ne 0) {
    throw "Typora installer exited with code $($proc.ExitCode). See log: $(Join-Path $tempDir 'typora-install.log')"
}

$exe = Join-Path $InstallDir 'Typora.exe'
if (-not (Test-Path -LiteralPath $exe)) {
    throw "Install finished but Typora.exe was not found at: $exe"
}

Write-Host ''
Write-Host 'Typora installed successfully.'
Write-Host "  Install dir : $InstallDir"
Write-Host "  Executable  : $exe"
Write-Host "  Log         : $(Join-Path $tempDir 'typora-install.log')"
