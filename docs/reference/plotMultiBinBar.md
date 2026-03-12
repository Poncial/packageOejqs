# Graphique en barres horizontales pour variables binaires (choix multiples)

Génère un graphique en barres horizontales triées par ordre décroissant
de pourcentage, adapté aux questions à choix multiples (variables 0/1).
Le graphique mentionne explicitement que plusieurs réponses sont
possibles et affiche le N total de répondants.

Sans variable de regroupement, un seul graphique est produit. Avec une
variable de regroupement, un `facet_wrap` est utilisé. Avec deux
variables de regroupement, un `facet_grid` est utilisé (première
variable en lignes, seconde en colonnes).

Les items sont triés selon leur pourcentage global (sans groupement), ce
qui permet de conserver une référence de lecture cohérente entre les
facettes.

## Usage

``` r
plotMultiBinBar(
  dt,
  cols,
  labels = NULL,
  groupVars = NULL,
  question = NULL,
  outputDir,
  fileFormat = "png",
  barColor = "#662483",
  width = 8,
  height = 5,
  dpi = 300,
  xAxisTitle = NULL,
  graphTitle = NULL,
  subTitle = NULL,
  fontSize = 11,
  labelSize = 3
)
```

## Arguments

- dt:

  [data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)
  Table de données source.

- cols:

  [character](https://rdrr.io/r/base/character.html) Noms des colonnes
  binaires (0/1) à analyser.

- labels:

  [character](https://rdrr.io/r/base/character.html) Labels affichés à
  la place des noms de colonnes. Doit être de même longueur que `cols`.
  Si NULL, les noms de colonnes sont utilisés.

- groupVars:

  [character](https://rdrr.io/r/base/character.html) Vecteur de 0, 1 ou
  2 noms de variables catégorielles pour le regroupement. Default :
  NULL.

- question:

  Chaîne de caractères. Titre de la question affiché en titre du
  graphique.

- outputDir:

  [character](https://rdrr.io/r/base/character.html) Répertoire de
  sauvegarde du graphique.

- fileFormat:

  [character](https://rdrr.io/r/base/character.html) Format de sortie :
  "png", "pdf" ou "svg". Default : "png".

- barColor:

  [character](https://rdrr.io/r/base/character.html) Couleur des barres.
  Default : "#662483".

- width:

  [numeric](https://rdrr.io/r/base/numeric.html) Largeur en pouces.
  Default : 8.

- height:

  [numeric](https://rdrr.io/r/base/numeric.html) Hauteur en pouces.
  Default : 5.

- dpi:

  [numeric](https://rdrr.io/r/base/numeric.html) Résolution (ignorée
  pour pdf). Default : 300.

- xAxisTitle:

  [character](https://rdrr.io/r/base/character.html) Titre de l'axe X.
  Default : NULL.

- graphTitle:

  [character](https://rdrr.io/r/base/character.html) Titre principal du
  graphique. Default : NULL.

- subTitle:

  [character](https://rdrr.io/r/base/character.html) Sous-titre du
  graphique. Default : NULL.

- fontSize:

  [numeric](https://rdrr.io/r/base/numeric.html) Taille de base des
  textes. Default : 11.

- labelSize:

  [numeric](https://rdrr.io/r/base/numeric.html) Taille des étiquettes
  de valeurs sur les barres. Default : 3.

## Value

Invisiblement, le chemin complet du fichier sauvegardé.

## Examples

``` r
if (FALSE) { # \dontrun{
dtEx <- data.table::data.table(
  smartphone = sample(0:1, 200, replace = TRUE),
  ordinateur = sample(0:1, 200, replace = TRUE),
  tablette   = sample(0:1, 200, replace = TRUE),
  console    = sample(0:1, 200, replace = TRUE),
  television = sample(0:1, 200, replace = TRUE),
  region     = sample(c("Nord", "Sud"), 200, replace = TRUE),
  genre      = sample(c("Homme", "Femme"), 200, replace = TRUE)
)

# Sans regroupement
plotMultiBinBar(
  dt        = dtEx,
  cols      = c("smartphone", "ordinateur", "tablette"),
  outputDir = "output/graphs"
)

# Avec une variable de regroupement
plotMultiBinBar(
  dt        = dtEx,
  cols      = c("smartphone", "ordinateur", "tablette"),
  groupVars = "genre",
  outputDir = "output/graphs"
)

# Avec deux variables de regroupement
plotMultiBinBar(
  dt        = dtEx,
  cols      = c("smartphone", "ordinateur", "tablette"),
  groupVars = c("genre", "region"),
  outputDir = "output/graphs"
)
} # }
```
