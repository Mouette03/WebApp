# Script PowerShell pour générer le Dockerfile (équivalent à generate_dockerfile.py)
# Utile pour tester localement sans Python installé

$config = Get-Content "config.json" -Raw | ConvertFrom-Json
$template = Get-Content "dockerfile.template" -Raw -Encoding UTF8

# Remplace PHP_VERSION
$dockerfile = $template -replace '%%PHP_VERSION%%', $config.php_version

# Remplace SYSTEM_DEPENDENCIES avec indentation correcte
$systemDeps = ($config.system_dependencies | ForEach-Object { "    $_" }) -join " \`n"
$dockerfile = $dockerfile -replace '%%SYSTEM_DEPENDENCIES%%', $systemDeps

# Remplace PHP_EXTENSIONS avec indentation correcte
$phpExts = ($config.php_extensions | ForEach-Object { "    $_" }) -join " \`n"
$dockerfile = $dockerfile -replace '%%PHP_EXTENSIONS%%', $phpExts

# Remplace PECL_EXTENSIONS
$peclExts = $config.pecl_extensions -join " "
$dockerfile = $dockerfile -replace '%%PECL_EXTENSIONS%%', $peclExts

# Remplace PHP_INI_SETTINGS
$phpIniCommands = @()
foreach ($setting in $config.php_ini_settings.PSObject.Properties) {
    $phpIniCommands += "echo '$($setting.Name) = $($setting.Value)' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini"
}
$phpIniString = $phpIniCommands -join " && \`n    "
$dockerfile = $dockerfile -replace '%%PHP_INI_SETTINGS%%', $phpIniString

# Écrit le Dockerfile
$dockerfile | Out-File -FilePath "dockerfile" -Encoding UTF8 -NoNewline

Write-Host "dockerfile generated successfully from config.json" -ForegroundColor Green
