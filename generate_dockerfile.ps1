# Script PowerShell pour générer le Dockerfile (équivalent à generate_dockerfile.py)
# Utile pour tester localement sans Python installé

$config = Get-Content "config.json" -Raw | ConvertFrom-Json
$template = Get-Content "dockerfile.template" -Raw -Encoding UTF8

# Remplace PHP_VERSION
$dockerfile = $template -replace '%%PHP_VERSION%%', $config.php_version

# Remplace SYSTEM_TOOLS avec indentation correcte
$systemTools = ($config.system_tools | ForEach-Object { "    $_ \" }) -join "`n"
$dockerfile = $dockerfile -replace '%%SYSTEM_TOOLS%%', $systemTools

# Remplace PHP_EXTENSIONS (Core + PECL ensemble, sur une seule ligne)
$phpExts = $config.php_extensions -join " "
$dockerfile = $dockerfile -replace '%%PHP_EXTENSIONS%%', $phpExts

# Remplace PHP_INI_SETTINGS (format INI simple)
$phpIniLines = @()
foreach ($setting in $config.php_ini_settings.PSObject.Properties) {
    if ($setting.Name -eq 'date.timezone') {
        $phpIniLines += "$($setting.Name) = `"$($setting.Value)`""
    } else {
        $phpIniLines += "$($setting.Name) = $($setting.Value)"
    }
}
$phpIniContent = $phpIniLines -join "`n"
$dockerfile = $dockerfile -replace '%%PHP_INI_SETTINGS%%', $phpIniContent

# Écrit le Dockerfile
$dockerfile | Out-File -FilePath "dockerfile" -Encoding UTF8 -NoNewline

Write-Host "dockerfile generated successfully from config.json" -ForegroundColor Green
