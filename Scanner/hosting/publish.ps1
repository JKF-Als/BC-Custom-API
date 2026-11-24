# Kopierer scanner-appen (Scanner/app) op på Linux-serveren.
#
# Brug:  .\Scanner\hosting\publish.ps1 -Server bruger@server.jkfuniverse.com
#
# Kræver ssh-adgang til serveren og sudo-ret dér. Filerne lægges først i en
# midlertidig mappe i din hjemmemappe og flyttes så til /var/www/jkf-lager.
# Du bliver evt. spurgt om ssh- og sudo-adgangskode undervejs.

param(
    [Parameter(Mandatory = $true)][string]$Server,
    [string]$Target = '/var/www/jkf-lager'
)

$ErrorActionPreference = 'Stop'
$appDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'app'
$upload = 'jkf-lager-upload'

Write-Host "Kopierer $appDir til ${Server}:~/$upload ..." -ForegroundColor Cyan
ssh $Server "rm -rf ~/$upload && mkdir -p ~/$upload"
if ($LASTEXITCODE -ne 0) { throw 'Kunne ikke forbinde til serveren.' }
scp -r "$appDir/*" "${Server}:~/$upload/"
if ($LASTEXITCODE -ne 0) { throw 'Kopiering fejlede.' }

Write-Host "Flytter til $Target ..." -ForegroundColor Cyan
ssh -t $Server "sudo mkdir -p $Target && (command -v rsync >/dev/null && sudo rsync -a --delete ~/$upload/ $Target/ || (sudo rm -rf $Target/* && sudo cp -r ~/$upload/. $Target/)) && sudo chown -R www-data:www-data $Target && rm -rf ~/$upload"
if ($LASTEXITCODE -ne 0) { throw 'Flytning på serveren fejlede.' }

Write-Host 'Færdig. Scannerne henter den nye version næste gang appen åbnes.' -ForegroundColor Green
