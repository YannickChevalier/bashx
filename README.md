# bashx

serveur Web à utiliser pour les TPs de sécurité

# Architecture

## Le fichier webserver.sh

Ce fichier contient les définitions de fonctions utilisées dans les
autres scripts, et lance les scripts listés dans la variable 'stages'.
Les entrées et sorties standard de chaque script sont connectées soit
au script précédent, soit au port 20080 de la machine (avec la
commande "nc" vers la fin du script).

## Le fichier http_parser.sh

Ce fichier lit des requêtes HTTP sur son entrée standard, et écrit les
réponses sur sa sortie standard. Il envoie au prochain script le
contenu de la requête sous la forme d'un tableau associatif, et met en
forme la réponse du prochain script en tant que réponse HTTP.


## Le fichier request_to_shell.sh

Ce fichier lit un tableau de paramètres sur son entrée standard,
extrait le contenu du paramètre "command", et envoie ce contenu au
script suivant. Il lit la réponse du script suivant, sous la forme
"nombre de lignes" suivi du contenu, et transfère cette réponse en
précisant sa longueur et son type (text/html) au script précédent.


## Les fichiers backend

Ces fichiers recoivent une commande sur leur entrée standard. Ils
l'exécutent, et renvoient le résultat sur leur sortie standard.


# Utilisation

## En mode découverte

On peut l'utiliser en allant dans le répertoire bashrc/src et en tapant:
     ./webserver.sh

Dans un navigateur, allez à l'adresse localhost:20080. Si vous avez réussi à 
installer une machine virtuelle, vous pouvez lancer le serveur sur cette 
machine, et rediriger (comme pour ssh) un port de la machine hôte vers le
port 20080 de cette machine. Il faut alors aussi changer l'adresse IP en
celle de la machine virtuelle au début du script webserver.sh

## Pour l'analyse de sécurité

Pour l'analyse de sécurité, on peut aussi lancer des requêtes depuis
la ligne de commande (cf. page 3 du TP).

# Travail

Il faut:
   - faire la liste des lignes du code qui sont souillées, c'est-à-dire
qui utilisent les données de l'utilisateur
   - regarder, pour chaque ligne, s'il est possible de causer une erreur
sur le script.

