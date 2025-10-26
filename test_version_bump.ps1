# Script pour tester l'incrémentation de version localement

$currentVersion = Get-Content "VERSION" -Raw
$currentVersion = $currentVersion.Trim()

Write-Host "Version actuelle : $currentVersion" -ForegroundColor Cyan

# Découpe la version
$parts = $currentVersion -split '\.'
$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2]

# Incrémente PATCH
$newPatch = $patch + 1
$newVersion = "$major.$minor.$newPatch"

Write-Host "Nouvelle version : $newVersion" -ForegroundColor Green
Write-Host ""
Write-Host "Pour appliquer ce changement, le workflow GitHub Actions le fera automatiquement." -ForegroundColor Yellow
Write-Host "Si vous voulez le faire manuellement, exécutez :" -ForegroundColor Yellow
Write-Host "  echo $newVersion > VERSION" -ForegroundColor White
