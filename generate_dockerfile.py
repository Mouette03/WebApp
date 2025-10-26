# Importe le module json pour pouvoir lire et parser le fichier de configuration.
import json

# Ouvre le fichier de configuration 'config.json' en mode lecture ('r').
with open('config.json', 'r') as f:
    # Charge le contenu JSON du fichier dans un dictionnaire Python.
    config = json.load(f)

# Ouvre le fichier 'dockerfile.template' en mode lecture.
with open('dockerfile.template', 'r') as f:
    # Lit tout le contenu du template dans une chaîne de caractères.
    template = f.read()

# Remplace les placeholders (variables) dans le template par les valeurs du fichier de configuration.
# Remplace la version de PHP.
dockerfile_content = template.replace('%%PHP_VERSION%%', config['php_version'])
# Remplace la liste des dépendances système. ' \\\n    '.join(...) formate la liste pour qu'elle soit lisible dans le Dockerfile.
dockerfile_content = dockerfile_content.replace('%%SYSTEM_DEPENDENCIES%%', ' \\\n    '.join(config['system_dependencies']))
# Remplace la liste des extensions PHP.
dockerfile_content = dockerfile_content.replace('%%PHP_EXTENSIONS%%', ' \\\n    '.join(config['php_extensions']))
# Remplace la liste des extensions PECL.
dockerfile_content = dockerfile_content.replace('%%PECL_EXTENSIONS%%', ' '.join(config['pecl_extensions']))

# Crée une liste de commandes 'echo' pour chaque paramètre de php.ini.
php_ini_settings = []
for key, value in config['php_ini_settings'].items():
    php_ini_settings.append(f"echo '{key} = {value}'")

# Remplace le placeholder des paramètres php.ini par une chaîne de commandes qui les ajoute au fichier de configuration.
# ' >> fichier' ajoute le texte à la fin du fichier.
dockerfile_content = dockerfile_content.replace('%%PHP_INI_SETTINGS%%', ' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && '.join(php_ini_settings) + ' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini')

# Ouvre (ou crée) le fichier 'dockerfile' en mode écriture ('w').
with open('dockerfile', 'w') as f:
    # Écrit le contenu final généré dans le fichier 'dockerfile'.
    f.write(dockerfile_content)

# Affiche un message pour confirmer que le fichier a été généré.
print("dockerfile generated successfully from config.json")
