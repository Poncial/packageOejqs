# Créer et sauvegarder des graphiques en barres groupés

Génère un graphique en barres pour chaque item d'une liste de résumés
statistiques, puis sauvegarde automatiquement chaque graphique au format
PNG.

Cette fonction est conçue pour fonctionner avec les sorties de
[`summariseItemsByGroup()`](summariseItemsByGroup.md), mais accepte
toute liste de `data.table` contenant au minimum une colonne de groupe,
une colonne de statistique centrale (`mean` ou `median`) et une colonne
d'erreur (`se`, `sd`, `ci` ou `iqr`).

## Usage

``` r
plotGroupedBarCharts(
  summaryList,
  typeQuestion = NULL,
  groupVar,
  groupVar2 = NULL,
  legendTitle = NULL,
  barColors = NULL,
  barWidth = 0.8,
  errorBarWidth = 0.2,
  statType = "mean",
  errorType = "se",
  flipAxes = FALSE,
  titre = NULL,
  sousTitre = NULL,
  titreAxeX = "Groupes",
  titreAxeY = "Valeur",
  yLimits = NULL,
  outputSubfolder = "01_Eleves",
  width = 7,
  height = 5,
  dpi = 300
)
```

## Arguments

- summaryList:

  Liste nommée de `data.table`, un élément par item. Typiquement
  produite par [`summariseItemsByGroup()`](summariseItemsByGroup.md).

- typeQuestion:

  \[optionnel\] Chaîne de caractères indiquant le type de question
  (p.ex. `"Likert"`, `"frequence"`). Utilisée uniquement dans le nom du
  fichier PNG sauvegardé. Si `NULL`, cet élément est omis du nom de
  fichier.

- groupVar:

  Nom de la variable de regroupement principale, représentée sur l'axe X
  (ou Y si `flipAxes = TRUE`).

- groupVar2:

  \[optionnel\] Nom de la seconde variable de regroupement, représentée
  via le remplissage des barres et la légende. Si `NULL`, un seul groupe
  est affiché.

- legendTitle:

  \[optionnel\] Titre personnalisé pour la légende de `groupVar2`. Si
  `NULL`, le nom de `groupVar2` est utilisé. Ignoré si
  `groupVar2 = NULL`.

- barColors:

  \[optionnel\] Vecteur de couleurs hexadécimales, une par niveau de
  groupe. Si `NULL`, utilise `"#9D9D9D"` pour un seul groupe ou la
  palette
  [`scales::hue_pal()`](https://scales.r-lib.org/reference/pal_hue.html)
  pour deux groupes.

- barWidth:

  Largeur des barres, entre 0 et 1. Défaut : `0.8`.

- errorBarWidth:

  Largeur des barres d'erreur. Défaut : `0.2`.

- statType:

  Statistique centrale affichée sur les barres. Valeurs acceptées :
  `"mean"` (défaut) ou `"median"`.

- errorType:

  Type de barre d'erreur. Valeurs acceptées :

  - `"se"` : erreur standard (défaut)

  - `"sd"` : écart-type

  - `"ci"` : intervalle de confiance

  - `"iqr"` : étendue interquartile

- flipAxes:

  Booléen. Si `TRUE`, inverse les axes X et Y via `coord_flip()` et
  affiche les étiquettes de valeur et d'effectif directement sur les
  barres. Défaut : `FALSE`.

- titre:

  \[optionnel\] Titre principal affiché sur chaque graphique.

- sousTitre:

  \[optionnel\] Sous-titre affiché sous le titre principal.

- titreAxeX:

  Titre de l'axe des X. Défaut : `"Groupes"`.

- titreAxeY:

  Titre de l'axe des Y. Défaut : `"Valeur"`.

- yLimits:

  \[optionnel\] Vecteur numérique de longueur 2 définissant les limites
  de l'axe des valeurs, p.ex. `c(0, 6)`. Utilise `coord_cartesian()`
  pour zoomer sans supprimer de données. Si `NULL`, les limites sont
  calculées automatiquement.

- outputSubfolder:

  Sous-dossier de destination dans `03_outputFiles/01_graphiques/`.
  Défaut : `"01_Eleves"`.

- width:

  Largeur du fichier PNG en pouces. Défaut : `7`.

- height:

  Hauteur du fichier PNG en pouces. Défaut : `5`.

- dpi:

  Résolution du fichier PNG en points par pouce. Défaut : `300`.

## Value

Retourne invisiblement une liste nommée d'objets `ggplot`, un par item.
Les graphiques sont également sauvegardés automatiquement sur disque
(voir section *Fichiers générés*).

## Fichiers générés

Les graphiques sont sauvegardés dans :

    03_outputFiles/01_graphiques/<outputSubfolder>/

Les noms de fichiers suivent le format :

    YYYYMMDD_<typeQuestion>_<groupVar>[_<groupVar2>]_<statType>_<item>.png

Par exemple :

    20250101_Likert_genre_moyenne_item1.png
    20250101_Likert_genre_modele_moyenne_item1.png

## Gestion des axes

Les limites de l'axe des valeurs sont toujours gérées via
`coord_cartesian()` (ou `coord_flip(ylim = ...)`), ce qui garantit
qu'aucune donnée n'est supprimée lors du zoom, contrairement à
`scale_y_continuous(limits = ...)`.

## See also

[`summariseItemsByGroup()`](summariseItemsByGroup.md) pour générer
`summaryList`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(data.table)

# --- Données fictives ---
set.seed(42)
dt <- data.table(
  genre  = sample(c("Femme", "Homme"), 120, replace = TRUE),
  modele = sample(c("A", "B", "C"), 120, replace = TRUE),
  item1  = sample(1:5, 120, replace = TRUE),
  item2  = sample(1:5, 120, replace = TRUE)
)

# --- Calcul des statistiques descriptives ---
summaryList <- summariseItemsByGroup(
  dt           = dt,
  varItems     = c("item1", "item2"),
  groupVar     = "genre",
  includeTotal = TRUE
)

# --- Exemple 1 : graphique simple, un seul groupe ---
plotGroupedBarCharts(
  summaryList = summaryList,
  groupVar    = "genre",
  titre       = "Résultats par genre",
  titreAxeY   = "Moyenne (échelle 1-5)",
  yLimits     = c(0, 5)
)

# --- Exemple 2 : deux variables de groupe ---
summaryList2 <- summariseItemsByGroup(
  dt           = dt,
  varItems     = c("item1", "item2"),
  groupVar     = "genre",
  groupVar2    = "modele",
  includeTotal = FALSE
)

plotGroupedBarCharts(
  summaryList  = summaryList2,
  groupVar     = "genre",
  groupVar2    = "modele",
  legendTitle  = "Modèle pédagogique",
  barColors    = c("#F39200", "#951B81", "#662483"),
  titre        = "Résultats par genre et modèle",
  yLimits      = c(0, 5)
)

# --- Exemple 3 : barres horizontales avec étiquettes ---
plotGroupedBarCharts(
  summaryList = summaryList,
  groupVar = "genre",
  typeQuestion = "Likert",
  flipAxes = TRUE,
  statType = "median",
  errorType = "iqr",
  titre = "Médiane par genre",
  titreAxeX = "Genre",
  titreAxeY = "Médiane",
  yLimits = c(0, 5),
  outputSubfolder = "02_Enseignants",
  width = 9,
  height = 6
)
} # }
```
