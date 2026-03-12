# ==============================================================
# create_pkgdown_files.R
#
# Script de création automatique de tous les fichiers pkgdown
# pour packageOejqs.
#
# Usage :
#   1. Placer ce script à la RACINE de ton package
#   2. Ouvrir le projet dans RStudio
#   3. Exécuter : source("create_pkgdown_files.R")
#
# Ce script crée :
#   - _pkgdown.yml
#   - README.md
#   - NEWS.md
#   - vignettes/demarrage-rapide.Rmd
#   - vignettes/charger-qualtrics.Rmd
#   - vignettes/transformer-donnees.Rmd
#   - vignettes/creer-graphiques.Rmd
#   - dev/dev_history_pkgdown.R
# ==============================================================

# -- Vérification : on est bien à la racine du package ---------
if (!file.exists("DESCRIPTION")) {
  stop(
    "Ce script doit être exécuté depuis la racine du package.\n",
    "Assure-toi que ton working directory est bien le dossier du package.\n",
    "Tu peux le vérifier avec : getwd()"
  )
}

# -- Helper : écrire un fichier avec un message de confirmation
writeFileVerbose <- function(path, content) {
  # Créer le dossier parent si nécessaire
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(content, path, useBytes = FALSE)
  message("  [OK] ", path)
}

message("\n=== Création des fichiers pkgdown pour packageOejqs ===\n")

# ==============================================================
# 1. _pkgdown.yml
# ==============================================================
writeFileVerbose("_pkgdown.yml", '
url: https://poncial.github.io/packageOejqs

template:
  bootstrap: 5
  bslib:
    # -- Typographie -----------------------------------------------
    base_font:
      google: "Inter"
    heading_font:
      google: "Inter"
    code_font:
      google: "Fira Code"

    # -- Couleurs principales --------------------------------------
    primary:         "#F39200"   # orange
    secondary:       "#662483"   # violet foncé
    success:         "#F39200"
    info:            "#951B81"   # violet moyen
    danger:          "#E84E0F"   # rouge-orange
    warning:         "#E71E73"   # rose

    # -- UI --------------------------------------------------------
    navbar-bg:                 "#662483"
    navbar-light-color:        "#ffffff"
    navbar-light-hover-color:  "#F39200"
    navbar-light-active-color: "#F39200"
    footer-bg:                 "#575783"
    link-color:                "#951B81"
    link-hover-color:          "#F39200"
    border-radius:             "0.5rem"
    font-size-base:            "1rem"

# -- Navbar --------------------------------------------------------
navbar:
  structure:
    left:  [intro, reference, articles, news]
    right: [github]
  components:
    intro:
      text: "Démarrage rapide"
      href: articles/demarrage-rapide.html
    reference:
      text: "Fonctions"
      href: reference/index.html
    articles:
      text: "Guides"
      menu:
        - text: "\U0001F680 Démarrage rapide"
          href: articles/demarrage-rapide.html
        - text: "\U0001F4E5 Charger des données Qualtrics"
          href: articles/charger-qualtrics.html
        - text: "\U0001F504 Transformer des données"
          href: articles/transformer-donnees.html
        - text: "\U0001F4CA Créer des graphiques"
          href: articles/creer-graphiques.html
    news:
      text: "Nouveautés"
      href: news/index.html
    github:
      icon: fab fa-github
      href: https://github.com/Poncial/packageOejqs
      aria-label: GitHub

# -- Page d\'accueil -----------------------------------------------
home:
  title: "packageOejqs — Outils Équipe"
  description: >
    Package interne pour le chargement de données Qualtrics,
    la transformation de données et la création de graphiques.
  links:
    - text: "\U0001F4E6 Installer le package"
      href: "#installation"
  sidebar:
    structure: [links, license, community, citation, authors, dev]

# -- Référence des fonctions --------------------------------------
reference:
  - title: "\U0001F4E5 Chargement Qualtrics"
    desc: >
      Fonctions pour importer et préparer les données exportées
      depuis Qualtrics. Point de départ recommandé.
    contents:
      - extractLabels
      - applyValueLabels

  - title: "\U0001F504 Transformation de données"
    desc: >
      Fonctions pour retravailler et résumer les données
      après leur chargement.
    contents:
      - recodeBinary
      - recodeNumeric
      - summariseItemsByGroup

  - title: "\U0001F4CA Visualisation"
    desc: >
      Fonctions pour créer des graphiques prêts à l\'emploi,
      adaptés aux données d\'enquête.
    contents:
      - plotGroupedBarCharts
      - plotMultiBinBar
      - plotPercentBar
      - plotProportionHeatmap

  - title: "\U0001F527 Utilitaires"
    desc: >
      Fonctions d\'usage général pour nettoyer, convertir
      ou organiser les données et l\'environnement.
    contents:
      - cleanTextCols
      - rgbToHex
      - sourceIsolated

# -- Articles / Vignettes -----------------------------------------
articles:
  - title: "Guides d\'utilisation"
    navbar: ~
    contents:
      - demarrage-rapide
      - charger-qualtrics
      - transformer-donnees
      - creer-graphiques

# -- Pied de page -------------------------------------------------
footer:
  structure:
    left: developed_by
    right: built_with
')

# ==============================================================
# 2. README.md
# ==============================================================
writeFileVerbose("README.md", '
# packageOejqs

> Outils internes pour le chargement de données Qualtrics, la
> transformation de données et la création de graphiques.

<!-- badges: start -->
[![R CMD Check](https://github.com/Poncial/packageOejqs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Poncial/packageOejqs/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Poncial/packageOejqs/actions/workflows/pkgdown.yaml/badge.svg)](https://poncial.github.io/packageOejqs)
<!-- badges: end -->

## Installation

```r
# Installer depuis GitHub
# install.packages("pak")  # si pak n\'est pas encore installé
pak::pak("Poncial/packageOejqs")
```

## Utilisation rapide

```r
library(packageOejqs)

# 1. Charger et préparer des données Qualtrics
labels  <- extractLabels("mon_export_qualtrics.csv")
donnees <- applyValueLabels(donnees_brutes, labels)

# 2. Transformer
donnees_recodees <- recodeBinary(donnees, cols = c("q1", "q2"), valPos = "Oui")
resume           <- summariseItemsByGroup(donnees, items = c("q1", "q2"), groupVar = "groupe")

# 3. Visualiser
plotPercentBar(donnees, question = "q1", title = "Satisfaction globale")
plotProportionHeatmap(resume)
```

## Familles de fonctions

| Famille | Fonctions |
|---|---|
| \U0001F4E5 **Qualtrics** | `extractLabels()`, `applyValueLabels()` |
| \U0001F504 **Transform** | `recodeBinary()`, `recodeNumeric()`, `summariseItemsByGroup()` |
| \U0001F4CA **Plot** | `plotGroupedBarCharts()`, `plotMultiBinBar()`, `plotPercentBar()`, `plotProportionHeatmap()` |
| \U0001F527 **Utilitaires** | `cleanTextCols()`, `rgbToHex()`, `sourceIsolated()` |

## Documentation complète

\U0001F449 [poncial.github.io/packageOejqs](https://poncial.github.io/packageOejqs)
')

# ==============================================================
# 3. NEWS.md
# ==============================================================
writeFileVerbose("NEWS.md", '
# packageOejqs 0.1.0

## Première version

### Nouvelles fonctions

#### \U0001F4E5 Chargement Qualtrics
- `extractLabels()` : extraction des labels depuis un export Qualtrics
- `applyValueLabels()` : application des labels sur les données brutes

#### \U0001F504 Transformation
- `recodeBinary()` : recodage de variables catégorielles en 0/1
- `recodeNumeric()` : recodage de variables numériques par table de correspondance
- `summariseItemsByGroup()` : statistiques descriptives d\'items par groupe

#### \U0001F4CA Visualisation
- `plotPercentBar()` : graphique en barres avec pourcentages
- `plotGroupedBarCharts()` : barres groupées par variable de groupe
- `plotMultiBinBar()` : barres multiples pour items binaires
- `plotProportionHeatmap()` : heatmap de proportions / scores moyens

#### \U0001F527 Utilitaires
- `cleanTextCols()` : nettoyage des colonnes textuelles
- `rgbToHex()` : conversion RGB vers code hexadécimal
- `sourceIsolated()` : chargement isolé d\'un script R
')

# ==============================================================
# 4. vignettes/demarrage-rapide.Rmd
# ==============================================================
writeFileVerbose("vignettes/demarrage-rapide.Rmd", '---
title: "Démarrage rapide"
description: >
  Installez le package et lancez vos premières analyses en 5 minutes.
output: rmarkdown::html_vignette
vignette: >
  %\\VignetteIndexEntry{Démarrage rapide}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)
```

## Installation

```{r installation}
# Étape 1 : installer pak si nécessaire (à faire une seule fois)
install.packages("pak")

# Étape 2 : installer packageOejqs depuis GitHub
pak::pak("Poncial/packageOejqs")
```

## Charger le package

```{r chargement}
library(packageOejqs)
```

---

## Workflow typique en 3 étapes

### Étape 1 — Charger des données Qualtrics \U0001F4E5

```{r qualtrics}
# Extraire les labels depuis un export Qualtrics
labels <- extractLabels("mon_export_qualtrics.csv")

# Appliquer les labels sur les données brutes
donnees <- applyValueLabels(donnees_brutes, labels)
```

> \U0001F4A1 **C\'est quoi un "label" ?** Dans Qualtrics, les réponses sont souvent
> stockées sous forme de codes numériques (1, 2, 3...). `extractLabels()`
> récupère la correspondance entre ces codes et les vraies étiquettes
> ("Tout à fait d\'accord", "Plutôt d\'accord"...).

---

### Étape 2 — Transformer les données \U0001F504

```{r transformation}
# Recoder des variables binaires (ex: Oui/Non -> 1/0)
donnees <- recodeBinary(
  dt     = donnees,
  cols   = c("q1", "q2", "q3"),
  valPos = "Oui"
)

# Résumer plusieurs items par groupe
resume <- summariseItemsByGroup(
  dt       = donnees,
  items    = c("satisfaction_1", "satisfaction_2"),
  groupVar = "departement"
)
```

---

### Étape 3 — Visualiser \U0001F4CA

```{r visualisation}
# Graphique en barres avec pourcentages
plotPercentBar(
  dt       = donnees,
  question = "satisfaction_globale",
  title    = "Satisfaction globale"
)

# Heatmap de proportions par groupe
plotProportionHeatmap(
  dt       = resume,
  groupVar = "departement"
)
```

---

## En cas de problème

- \U0001F4D6 Consulte la [référence des fonctions](../reference/index.html)
- \U0001F41B Signale un bug sur [GitHub Issues](https://github.com/Poncial/packageOejqs/issues)
- \U0001F4AC Contacte l\'équipe en interne
')

# ==============================================================
# 5. vignettes/charger-qualtrics.Rmd
# ==============================================================
writeFileVerbose("vignettes/charger-qualtrics.Rmd", '---
title: "Charger des données Qualtrics"
description: >
  Comment importer et préparer un export Qualtrics avec extractLabels()
  et applyValueLabels().
output: rmarkdown::html_vignette
vignette: >
  %\\VignetteIndexEntry{Charger des données Qualtrics}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)
```

## Contexte

Quand on exporte des données depuis Qualtrics, on obtient un fichier CSV
avec **deux lignes d\'en-tête** :

- La **ligne 1** : les noms de colonnes techniques (`Q1`, `Q2_1`...)
- La **ligne 2** : les vrais intitulés des questions
- La **ligne 3** : les noms des niveaux de réponse (`1`, `2`, `3`...
  ou `Tout à fait d\'accord`...)

Le package gère cette structure automatiquement.

---

## Étape 1 — Extraire les labels avec `extractLabels()`

```{r extract}
library(packageOejqs)

# Extraire la correspondance codes <-> étiquettes
labels <- extractLabels("chemin/vers/mon_export.csv")

# Aperçu du résultat
print(labels)
#>    colName rawValue          labelValue
#> 1:      Q1        1  Tout à fait d\'accord
#> 2:      Q1        2      Plutôt d\'accord
#> 3:      Q1        3  Plutôt pas d\'accord
#> 4:      Q1        4  Pas du tout d\'accord
```

> \U0001F4A1 **Note :** `extractLabels()` retourne un `data.table` avec trois
> colonnes : le nom de la variable, le code brut, et l\'étiquette lisible.

---

## Étape 2 — Appliquer les labels avec `applyValueLabels()`

```{r apply}
# Charger les données brutes (sans les deux premières lignes d\'en-tête)
donnees_brutes <- data.table::fread("chemin/vers/mon_export.csv", skip = 2)

# Appliquer les labels
donnees <- applyValueLabels(
  dt     = donnees_brutes,
  labels = labels
)
```

---

## Résultat attendu

```{r resultat}
# Avant
donnees_brutes[1:3, .(Q1)]
#>    Q1
#> 1:  1
#> 2:  3
#> 3:  2

# Après
donnees[1:3, .(Q1)]
#>                    Q1
#> 1:  Tout à fait d\'accord
#> 2:    Plutôt pas d\'accord
#> 3:        Plutôt d\'accord
```

---

## Cas particuliers

### Mon fichier a des colonnes textuelles sales

Utilise `cleanTextCols()` après le chargement pour normaliser les
espaces, la ponctuation et les caractères spéciaux :

```{r clean}
donnees <- cleanTextCols(donnees)
```

### Je veux travailler sur plusieurs fichiers

```{r multi}
# Charger et préparer plusieurs exports en une fois
fichiers <- list.files("data/", pattern = "\\\\.csv$", full.names = TRUE)

liste_donnees <- purrr::map(fichiers, \\(f) {
  labels <- extractLabels(f)
  brut   <- data.table::fread(f, skip = 2)
  applyValueLabels(brut, labels)
})
```
')

# ==============================================================
# 6. vignettes/transformer-donnees.Rmd
# ==============================================================
writeFileVerbose("vignettes/transformer-donnees.Rmd", '---
title: "Transformer des données"
description: >
  Recoder des variables et résumer des items par groupe avec
  recodeBinary(), recodeNumeric() et summariseItemsByGroup().
output: rmarkdown::html_vignette
vignette: >
  %\\VignetteIndexEntry{Transformer des données}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)
```

```{r library}
library(packageOejqs)
library(data.table)
```

---

## Recoder des variables binaires — `recodeBinary()`

Transforme des variables catégorielles en variables **0/1**, utile pour
les questions Oui/Non ou Vrai/Faux.

```{r recodeBinary}
dt <- data.table(
  id = 1:4,
  q1 = c("Oui", "Non", "Oui", "Oui"),
  q2 = c("Non", "Non", "Oui", "Non")
)

# Recoder : "Oui" -> 1, tout le reste -> 0
dt_recodee <- recodeBinary(
  dt     = dt,
  cols   = c("q1", "q2"),
  valPos = "Oui"
)

print(dt_recodee)
#>    id q1 q2
#> 1:  1  1  0
#> 2:  2  0  0
#> 3:  3  1  1
#> 4:  4  1  0
```

> \U0001F4A1 Le paramètre `valPos` indique quelle modalité doit être codée `1`.
> Toutes les autres modalités (y compris `NA`) sont codées `0`.

---

## Recoder des variables numériques — `recodeNumeric()`

Transforme des **scores numériques** selon une table de correspondance.
Utile pour inverser une échelle ou regrouper des modalités.

```{r recodeNumeric}
dt <- data.table(
  id    = 1:5,
  score = c(1, 2, 3, 4, 5)
)

# Inverser une échelle de Likert 1-5
dt_inverse <- recodeNumeric(
  dt         = dt,
  cols       = "score",
  sourceVals = c(1, 2, 3, 4, 5),
  destVals   = c(5, 4, 3, 2, 1)
)

print(dt_inverse)
#>    id score
#> 1:  1     5
#> 2:  2     4
#> 3:  3     3
#> 4:  4     2
#> 5:  5     1
```

---

## Résumer des items par groupe — `summariseItemsByGroup()`

Calcule des **statistiques descriptives** pour un ensemble d\'items,
ventilées par groupe.

```{r summarise}
dt <- data.table(
  groupe = c("A", "A", "B", "B", "A"),
  item1  = c(4, 5, 2, 3, 4),
  item2  = c(3, 4, 5, 1, 3)
)

resume <- summariseItemsByGroup(
  dt       = dt,
  items    = c("item1", "item2"),
  groupVar = "groupe"
)

print(resume)
```

> \U0001F4A1 **Astuce :** le résultat de `summariseItemsByGroup()` est directement
> utilisable comme input pour `plotProportionHeatmap()`.

---

## Enchaîner les transformations

```{r pipeline}
# Workflow complet : charger -> transformer -> résumer
resume_final <- data.table::fread("mon_export.csv", skip = 2) |>
  (\\(dt) applyValueLabels(dt, extractLabels("mon_export.csv")))() |>
  recodeBinary(cols = c("q1", "q2"), valPos = "Oui") |>
  summariseItemsByGroup(items = c("q1", "q2"), groupVar = "departement")
```
')

# ==============================================================
# 7. vignettes/creer-graphiques.Rmd
# ==============================================================
writeFileVerbose("vignettes/creer-graphiques.Rmd", '---
title: "Créer des graphiques"
description: >
  Guide visuel pour les 4 fonctions de visualisation du package :
  plotPercentBar(), plotGroupedBarCharts(), plotMultiBinBar()
  et plotProportionHeatmap().
output: rmarkdown::html_vignette
vignette: >
  %\\VignetteIndexEntry{Créer des graphiques}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse  = TRUE,
  comment   = "#>",
  fig.width = 7,
  fig.height = 4,
  eval      = FALSE
)
```

```{r library}
library(packageOejqs)
library(data.table)
```

---

## Quelle fonction choisir ?

| Situation | Fonction recommandée |
|---|---|
| Une seule question, répartition des réponses | `plotPercentBar()` |
| Une question, comparaison entre groupes | `plotGroupedBarCharts()` |
| Plusieurs questions binaires (Oui/Non) | `plotMultiBinBar()` |
| Scores moyens, plusieurs items x groupes | `plotProportionHeatmap()` |

---

## `plotPercentBar()` — Répartition d\'une question

**Quand l\'utiliser ?** Pour afficher la distribution des réponses à
une seule question sous forme de barres en pourcentage.

```{r percentbar}
dt <- data.table(
  satisfaction = c(
    "Très satisfait", "Satisfait", "Satisfait",
    "Peu satisfait",  "Très satisfait", "Satisfait"
  )
)

plotPercentBar(
  dt       = dt,
  question = "satisfaction",
  title    = "Niveau de satisfaction"
)
```

**Paramètres utiles :**

| Paramètre | Rôle | Valeur par défaut |
|---|---|---|
| `question` | Nom de la colonne à afficher | — |
| `title` | Titre du graphique | `""` |
| `wrapWidth` | Largeur max des étiquettes avant retour à la ligne | `20` |
| `angleThreshold` | Nb d\'étiquettes avant rotation automatique | `5` |

---

## `plotGroupedBarCharts()` — Comparaison entre groupes

**Quand l\'utiliser ?** Pour comparer les réponses à une question selon
une variable de groupe (département, genre, tranche d\'âge...).

```{r groupedbar}
dt <- data.table(
  satisfaction = c("Satisfait", "Peu satisfait", "Satisfait", "Satisfait"),
  departement  = c("RH", "RH", "IT", "IT")
)

plotGroupedBarCharts(
  dt       = dt,
  question = "satisfaction",
  groupVar = "departement",
  title    = "Satisfaction par département"
)
```

---

## `plotMultiBinBar()` — Plusieurs questions binaires

**Quand l\'utiliser ?** Pour afficher le taux de réponse "Oui" sur
plusieurs questions binaires (cases à cocher, items Vrai/Faux...).

```{r multibinbar}
dt <- data.table(
  id = 1:5,
  q1 = c(1, 1, 0, 1, 1),
  q2 = c(0, 1, 1, 0, 1),
  q3 = c(1, 0, 1, 1, 0)
)

plotMultiBinBar(
  dt       = dt,
  items    = c("q1", "q2", "q3"),
  question = "Résultats par item",
  labels   = c("Item A", "Item B", "Item C")
)
```

> \U0001F4A1 **Astuce :** utilise `recodeBinary()` au préalable pour préparer
> tes données si elles sont encore sous forme textuelle (Oui/Non).

---

## `plotProportionHeatmap()` — Heatmap de scores

**Quand l\'utiliser ?** Pour visualiser les scores moyens de plusieurs
items en fonction d\'un groupe.

```{r heatmap}
# Typiquement, le résultat de summariseItemsByGroup()
resume <- data.table(
  groupe     = c("A", "A", "B", "B"),
  item       = c("item1", "item2", "item1", "item2"),
  proportion = c(0.80, 0.60, 0.45, 0.75)
)

plotProportionHeatmap(
  dt       = resume,
  groupVar = "groupe",
  title    = "Scores par groupe et item"
)
```

**Lecture du graphique :**

- \U0001F7E0 **Couleur chaude** -> proportion élevée
- \U0001F7E3 **Couleur froide** -> proportion faible
')

# ==============================================================
# 8. dev/dev_history_pkgdown.R
# ==============================================================
writeFileVerbose("dev/dev_history_pkgdown.R", '# ==============================================================
# dev/dev_history_pkgdown.R
# Script de mise en place et de déploiement pkgdown
# ==============================================================

# -- 1. Initialiser pkgdown (une seule fois) -------------------
usethis::use_pkgdown()

# -- 2. Ajouter les dépendances nécessaires aux vignettes ------
usethis::use_package("knitr",     type = "Suggests")
usethis::use_package("rmarkdown", type = "Suggests")

# -- 3. Prévisualiser le site en local -------------------------
pkgdown::build_site()

# Ou pour ne reconstruire qu\'une partie :
pkgdown::build_home()       # page d\'accueil (README)
pkgdown::build_reference()  # page des fonctions
pkgdown::build_articles()   # vignettes
pkgdown::build_news()       # NEWS.md

# -- 4. Déployer sur GitHub Pages (automatique via CI) ---------
usethis::use_pkgdown_github_pages()
# Cela :
#   - Crée .github/workflows/pkgdown.yaml
#   - Active GitHub Pages sur la branche gh-pages
#   - Le site se met à jour à chaque push sur main

# -- 5. URL du site après déploiement --------------------------
# https://poncial.github.io/packageOejqs
')

# ==============================================================
# Résumé final
# ==============================================================
message("\n=== Tous les fichiers ont été créés avec succès ! ===\n")
message("Prochaines étapes :")
message("  1. usethis::use_pkgdown()")
message("  2. usethis::use_package('knitr',     type = 'Suggests')")
message("  3. usethis::use_package('rmarkdown', type = 'Suggests')")
message("  4. pkgdown::build_site()   # prévisualiser en local")
message("  5. usethis::use_pkgdown_github_pages()   # déployer\n")
