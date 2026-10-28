# Builds the DobsonGame UWP package for Xbox (x64, Release) on Windows.
# Requires: Visual Studio 2022 with the "Universal Windows Platform development" workload.
# Run from the folder that contains DobsonGame.sln, e.g.:
#   .\Build-UWP.ps1
param(
    [string]$Configuration = "Release",
    [string]$Platform = "x64"
)
$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path "$PSScriptRoot\AppPackages" | Out-Null

# --- Signing: use VS's test cert if it exists, otherwise make one ----------
# A sideloaded package must be signed, and the Xbox must trust the signer.
# The .cer exported here is what you install on the Xbox before the package
# (see README-XBOX.md). This is a test cert for your own dev kit, not a
# Store certificate.
$thumbprint = $null
$pfxPath = "$PSScriptRoot\DobsonGame\DobsonGame_TemporaryKey.pfx"
if (Test-Path $pfxPath) {
    Write-Host "Using existing test certificate: $pfxPath"
    $msbuildCertArgs = @("/p:PackageCertificateKeyFile=`"$pfxPath`"")
} else {
    Write-Host "No test certificate found - creating a self-signed one for this build..."
    $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=DobsonGame" `
        -KeyUsage DigitalSignature -FriendlyName "DobsonGame Test" `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
    Export-Certificate -Cert $cert -FilePath "$PSScriptRoot\AppPackages\DobsonGame.cer" | Out-Null
    $thumbprint = $cert.Thumbprint
    $msbuildCertArgs = @("/p:PackageCertificateThumbprint=$thumbprint", "/p:AppxPackageSigningEnabled=true")
    Write-Host "Certificate thumbprint: $thumbprint"
    Write-Host "Public certificate exported to AppPackages\DobsonGame.cer (install this on the Xbox first)."
}

# --- Find MSBuild ----------------------------------------------------------
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $installPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
    $msbuild = Join-Path $installPath "MSBuild\Current\Bin\MSBuild.exe"
} elseif (Get-Command msbuild -ErrorAction SilentlyContinue) {
    $msbuild = "msbuild"
} else {
    throw "MSBuild not found. Install Visual Studio 2022 with the UWP workload first."
}

# --- Build -----------------------------------------------------------------
& $msbuild DobsonGame.sln /t:Restore /p:Configuration=$Configuration /p:Platform=$Platform
& $msbuild DobsonGame.sln /t:Rebuild `
    /p:Configuration=$Configuration /p:Platform=$Platform `
    /p:AppxBundle=Always /p:AppxBundlePlatforms=$Platform `
    /p:UapAppxPackageBuildMode=SideloadOnly `
    /p:AppxPackageDir="$PSScriptRoot\AppPackages" `
    @msbuildCertArgs

Write-Host ""
Write-Host "Done. Look under AppPackages\ for the .msixbundle (and DobsonGame.cer)."
Write-Host "Install it on your Xbox dev kit with the steps in README-XBOX.md."
