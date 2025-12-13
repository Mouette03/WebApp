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

# Remplace la liste des outils système.
# Chaque élément est indenté de 4 espaces et se termine par un backslash.
system_tools = '\n'.join(f"    {tool} \\" for tool in config['system_tools'])
dockerfile_content = dockerfile_content.replace('%%SYSTEM_TOOLS%%', system_tools)

# Remplace la liste des extensions PHP (Core + PECL ensemble avec mlocati).
# Chaque élément est indenté de 4 espaces, sans backslash (mlocati gère la liste différemment)
php_exts = '\n'.join(f"    {ext}" for ext in config['php_extensions'])
dockerfile_content = dockerfile_content.replace('%%PHP_EXTENSIONS%%', php_exts)

# Crée le contenu du fichier php.ini avec les paramètres.
php_ini_lines = []
for key, value in config['php_ini_settings'].items():
    # Format simple : key = value
    if key == 'date.timezone':
        php_ini_lines.append(f'{key} = "{value}"')
    else:
        php_ini_lines.append(f'{key} = {value}')

php_ini_content = '\n'.join(php_ini_lines) if php_ini_lines else ''
dockerfile_content = dockerfile_content.replace('%%PHP_INI_SETTINGS%%', php_ini_content)

# Ouvre (ou crée) le fichier 'dockerfile' en mode écriture ('w').
with open('dockerfile', 'w', encoding='utf-8') as f:
    # Écrit le contenu final généré dans le fichier 'dockerfile'.
    f.write(dockerfile_content)

# Affiche un message pour confirmer que le fichier a été généré.
print("dockerfile generated successfully from config.json")
