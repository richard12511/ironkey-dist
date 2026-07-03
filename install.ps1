# install.ps1 — install the ironkey CLI (native Windows)
$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:IRONKEY_BASE_URL) { $env:IRONKEY_BASE_URL } else { "https://github.com/richard12511/ironkey-dist/releases/latest/download" }
$InstallDir = if ($env:IRONKEY_INSTALL_DIR) { $env:IRONKEY_INSTALL_DIR } else { "$env:LOCALAPPDATA\Programs\ironkey" }
$Asset = "ironkey-windows-x64.exe"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$exe = Join-Path $InstallDir "ironkey.exe"
$tmp = Join-Path $env:TEMP "ironkey-dl.exe"
$sums = Join-Path $env:TEMP "ironkey-checksums.txt"

Write-Host "Downloading $Asset …"
Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/$Asset" -OutFile $tmp
Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/checksums.txt" -OutFile $sums

$match = Select-String -Path $sums -Pattern " $([regex]::Escape($Asset))$"
if (-not $match) { throw "no checksum entry for $Asset" }
$want = $match.Line.Split(" ")[0]
$got = (Get-FileHash -Algorithm SHA256 $tmp).Hash.ToLower()
if ($want -ne $got) { throw "checksum mismatch for $Asset" }

Move-Item -Force $tmp $exe
Write-Host "Installed ironkey to $exe"

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
  $newPath = if ([string]::IsNullOrEmpty($userPath)) { $InstallDir } else { "$userPath;$InstallDir" }
  [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
  Write-Host "Added $InstallDir to your PATH — reopen your terminal."
}
