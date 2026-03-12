# Charger des données Qualtrics

## Contexte

Quand on exporte des données depuis Qualtrics, on obtient un fichier CSV
avec **deux lignes d’en-tête** :

- La **ligne 1** : les noms de colonnes techniques (`Q1`, `Q2_1`…)
- La **ligne 2** : les vrais intitulés des questions
- La **ligne 3** : les noms des niveaux de réponse (`1`, `2`, `3`… ou
  `Tout à fait d'accord`…)

Le package gère cette structure automatiquement.

------------------------------------------------------------------------

## Étape 1 — Extraire les labels avec `extractLabels()`

``` r
library(packageOejqs)

# Extraire la correspondance codes <-> étiquettes
labels <- extractLabels("chemin/vers/mon_export.csv")

# Aperçu du résultat
print(labels)
#>    colName rawValue          labelValue
#> 1:      Q1        1  Tout à fait d'accord
#> 2:      Q1        2      Plutôt d'accord
#> 3:      Q1        3  Plutôt pas d'accord
#> 4:      Q1        4  Pas du tout d'accord
```

> 💡 **Note :**
> [`extractLabels()`](https://poncial.github.io/packageOejqs/reference/extractLabels.md)
> retourne un `data.table` avec trois colonnes : le nom de la variable,
> le code brut, et l’étiquette lisible.

------------------------------------------------------------------------

## Étape 2 — Appliquer les labels avec `applyValueLabels()`

``` r
# Charger les données brutes (sans les deux premières lignes d'en-tête)
donnees_brutes <- data.table::fread("chemin/vers/mon_export.csv", skip = 2)

# Appliquer les labels
donnees <- applyValueLabels(
  dt     = donnees_brutes,
  labels = labels
)
```

------------------------------------------------------------------------

## Résultat attendu

``` r
# Avant
donnees_brutes[1:3, .(Q1)]
#>    Q1
#> 1:  1
#> 2:  3
#> 3:  2

# Après
donnees[1:3, .(Q1)]
#>                    Q1
#> 1:  Tout à fait d'accord
#> 2:    Plutôt pas d'accord
#> 3:        Plutôt d'accord
```

------------------------------------------------------------------------

## Cas particuliers

### Mon fichier a des colonnes textuelles sales

Utilise
[`cleanTextCols()`](https://poncial.github.io/packageOejqs/reference/cleanTextCols.md)
après le chargement pour normaliser les espaces, la ponctuation et les
caractères spéciaux :

``` r
donnees <- cleanTextCols(donnees)
```

### Je veux travailler sur plusieurs fichiers

``` r
# Charger et préparer plusieurs exports en une fois
fichiers <- list.files("data/", pattern = "\\.csv$", full.names = TRUE)

liste_donnees <- purrr::map(fichiers, \(f) {
  labels <- extractLabels(f)
  brut   <- data.table::fread(f, skip = 2)
  applyValueLabels(brut, labels)
})
```
