# Importe le module json pour pouvoir lire et parser le fichier de configuration.
import json

# Ouvre le fichier de configuration 'config.json' en mode lecture ('r').
with open('config.json', 'r', encoding='utf-8') as f:
    # Charge le contenu JSON du fichier dans un dictionnaire Python.
    config = json.load(f)

# Ouvre le fichier 'dockerfile.template' en mode lecture.
with open('dockerfile.template', 'r', encoding='utf-8') as f:
    # Lit tout le contenu du template dans une chaîne de caractères.
    template = f.read()

# Remplace les placeholders (variables) dans le template par les valeurs du fichier de configuration.
# Remplace la version de PHP.
dockerfile_content = template.replace('%%PHP_VERSION%%', config['php_version'])

# Remplace la liste des dépendances système.
# Chaque élément est indenté de 4 espaces et se termine par un backslash (sauf le dernier).
system_deps = '\n'.join(f"    {dep} \\" for dep in config['system_dependencies'])
# Retire le dernier backslash
system_deps = system_deps.rstrip(' \\')
dockerfile_content = dockerfile_content.replace('%%SYSTEM_DEPENDENCIES%%', system_deps)

# Remplace la liste des extensions PHP.
# Chaque élément est indenté de 4 espaces et se termine par un backslash (sauf le dernier).
php_exts = '\n'.join(f"    {ext} \\" for ext in config['php_extensions'])
# Retire le dernier backslash
php_exts = php_exts.rstrip(' \\')
dockerfile_content = dockerfile_content.replace('%%PHP_EXTENSIONS%%', php_exts)

# Remplace la liste des extensions PECL (sur une seule ligne, séparées par des espaces).
dockerfile_content = dockerfile_content.replace('%%PECL_EXTENSIONS%%', ' '.join(config['pecl_extensions']))

# Crée une série de commandes 'echo' pour chaque paramètre de php.ini.
# Ces commandes sont enchaînées avec &&.
php_ini_settings = []
for key, value in config['php_ini_settings'].items():
    # Ajoute des guillemets pour date.timezone (format original)
    if key == 'date.timezone':
        php_ini_settings.append(f"echo '{key} = \"{value}\"' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini")
    else:
        php_ini_settings.append(f"echo '{key} = {value}' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini")

php_ini_commands = ' && \\\n    '.join(php_ini_settings) if php_ini_settings else 'true'
dockerfile_content = dockerfile_content.replace('%%PHP_INI_SETTINGS%%', php_ini_commands)

# Ouvre (ou crée) le fichier 'dockerfile' en mode écriture ('w').
with open('dockerfile', 'w', encoding='utf-8') as f:
    # Écrit le contenu final généré dans le fichier 'dockerfile'.
    f.write(dockerfile_content)

# Affiche un message pour confirmer que le fichier a été généré.
print("dockerfile generated successfully from config.json")
