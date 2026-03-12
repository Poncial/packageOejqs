# sourceIsolated: Exécuter un script R dans un environnement temporaire isolé

Cette fonction permet de sourcer un script R dans un environnement
séparé, afin que tous les objets intermédiaires créés par le script ne
polluent pas le workspace global. Seuls les objets explicitement
retournés sont extraits.

## Usage

``` r
sourceIsolated(scriptPath, returnObjects = NULL)
```

## Arguments

- scriptPath:

  Character. Chemin vers le fichier R à exécuter.

- returnObjects:

  Character vector. Noms des objets à extraire de l'environnement
  temporaire. Si NULL (par défaut), retourne tous les objets créés.

## Value

Une liste contenant les objets spécifiés par `returnObjects` (ou tous
les objets du script si `returnObjects = NULL`).

## Details

- L'environnement temporaire hérite du
  [`globalenv()`](https://rdrr.io/r/base/environment.html), ce qui
  permet d'accéder aux packages déjà chargés (par ex. via
  `pacman::p_load()`) et aux fonctions globales.

- Les objets créés dans le script mais non listés dans `returnObjects`
  sont automatiquement jetés.

- Cette approche évite la pollution du workspace avec des objets
  intermédiaires.

## Examples

``` r
# Créer un script temporaire pour l'exemple
tmpScript <- tempfile(fileext = ".R")
writeLines(
  c(
    "x_intermediaire <- 42",
    "y_intermediaire <- x_intermediaire * 2",
    "resultatFinal   <- y_intermediaire + 10"
  ),
  con = tmpScript
)

# Cas 1 : extraire un seul objet — les intermédiaires sont ignorés
out <- sourceIsolated(tmpScript, returnObjects = "resultatFinal")
out$resultatFinal # 94
#> [1] 94

# Cas 2 : extraire tous les objets créés par le script
out <- sourceIsolated(tmpScript)
names(out) # "x_intermediaire" "y_intermediaire" "resultatFinal"
#> [1] "resultatFinal"   "x_intermediaire" "y_intermediaire"

# Vérifier que les intermédiaires ne polluent pas le workspace
exists("x_intermediaire") # FALSE
#> [1] FALSE

# Nettoyage
file.remove(tmpScript)
#> [1] TRUE
```
