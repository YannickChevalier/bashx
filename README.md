# bashx

serveur Web à utiliser pour les TPs de sécurité

# Architecture

## Le fichier webserver.sh

Ce fichier contient les définitions de fonctions utilisées dans les
autres scripts, et lance les scripts listés dans la variable 'stages'.
Les entrées et sorties standard de chaque script sont connectées soit
au script précédent, soit au port 80 de la machine (avec la
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

