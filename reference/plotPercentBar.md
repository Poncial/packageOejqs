# Générer des graphiques en barres de pourcentages

Cette fonction génère des graphiques en barres représentant la
distribution en pourcentage des modalités de réponse pour une ou
plusieurs variables d'intérêt. Les graphiques peuvent être groupés par
une ou deux variables de regroupement.

## Usage

``` r
plotPercentBar(
  dt,
  cols,
  outputDir,
  groupVars = NULL,
  valueLabels = NULL,
  legendTitle = NULL,
  barColors = c("#F39200", "#E71E73", "#951B81", "#E84E0F", "#C3004D"),
  fileFormat = "png",
  width = 8,
  height = 5,
  dpi = 300,
  xAxisTitle = NULL,
  yAxisTitle = "Pourcentage (%)",
  wrapWidth = 15,
  angleThreshold = 5,
  stacked = FALSE,
  labelThreshold = 1,
  barWidth = 0.8
)
```

## Arguments

- dt:

  `data.table`. La table de données source. Doit être un objet
  `data.table`.

- cols:

  `character`. Vecteur de noms de colonnes pour lesquelles générer les
  graphiques. Elles correspondent à une question. Chaque colonne donnera
  lieu à un graphique distinct.

- outputDir:

  `character`. Chemin du répertoire de sortie où les fichiers seront
  sauvegardés. Le répertoire est créé automatiquement s'il n'existe pas.

- groupVars:

  `character` ou `NULL`. Vecteur de regroupement (maximum 2). Si `NULL`
  (défaut), aucun regroupement n'est appliqué. Avec une variable, un
  `facet_wrap` est utilisé. Avec deux variables, un `facet_grid` est
  utilisé (mode non empilé) ou la première variable est placée en axe x
  et la seconde en `facet_wrap` (mode empilé).

- valueLabels:

  `character` ou `NULL`. Vecteur nommé de labels à appliquer aux
  modalités. Les noms doivent correspondre aux valeurs présentes dans
  `cols`. Si `NULL` (défaut), les valeurs brutes sont utilisées.

- legendTitle:

  `character` Titre de la légende

- barColors:

  `character`. Vecteur de couleurs hexadécimales utilisées pour les
  barres. Par défaut :
  `c("#F39200", "#E71E73", "#951B81", "#E84E0F", "#C3004D")`. Si le
  nombre de couleurs est inférieur au nombre de modalités, un
  avertissement est émis et les couleurs sont recyclées.

- fileFormat:

  `character`. Format d'export des graphiques. Valeurs acceptées :
  `"png"` (défaut), `"pdf"`, `"svg"`, `"jpeg"`, `"tiff"`.

- width:

  `numeric`. Largeur du graphique en pouces. Doit être strictement
  positif. Par défaut : `8`.

- height:

  `numeric`. Hauteur du graphique en pouces. Doit être strictement
  positif. Par défaut : `5`.

- dpi:

  `numeric`. Résolution du graphique en points par pouce. Doit être
  strictement positif. Par défaut : `300`.

- xAxisTitle:

  `character` ou `NULL`. Titre de l'axe x. Si `NULL` (défaut), le nom de
  la variable est utilisé.

- yAxisTitle:

  `character`. Titre de l'axe y. Par défaut : `"Pourcentage (%)"`.

- wrapWidth:

  Entier. Nombre de caractères maximum avant retour à la ligne
  automatique des étiquettes de l'axe des x. Par défaut `15`.

- angleThreshold:

  Entier. Nombre d'étiquettes sur l'axe x à partir duquel l'angle est
  appliqué pour éviter les chevauchements. Par défaut `5`.

- stacked:

  `logical`. Si `TRUE`, les barres sont empilées et normalisées à 100%.
  Si `FALSE` (défaut), les barres sont groupées côte à côte.

- labelThreshold:

  `numeric`. Seuil minimal en pourcentage (entre 0 et 100) en dessous
  duquel les labels ne sont pas affichés sur les segments en mode empilé
  (`stacked = TRUE`). Par défaut : `1`. Sans effet en mode non empilé.

- barWidth:

  largeur des barres. Par défaut = `.8`

## Value

Retourne invisiblement une liste de graphiques `ggplot2`, un par élément
de `cols`. Les graphiques sont également sauvegardés dans `outputDir`
avec un nom de fichier structuré comme suit :
`YYYYMMDD_<col>[_by_<groupVars>][_stacked].<fileFormat>`.

## Details

Les valeurs manquantes (`NA`) sont exclues du calcul des pourcentages.
Les pourcentages sont calculés au sein de chaque combinaison de
`question x groupVars`.

En mode empilé (`stacked = TRUE`), l'axe y est normalisé à 100% via
`position = "fill"`. Les labels des segments inférieurs à
`labelThreshold` ne sont pas affichés afin de préserver la lisibilité.

## Examples

``` r
if (FALSE) { # \dontrun{
library(data.table)
library(ggplot2)

# Création d'un jeu de données exemple
set.seed(42)
dtEx <- data.table(
  q1 = sample(c("Oui", "Non", "NSP"), 200, replace = TRUE),
  q2 = sample(c("Satisfait", "Neutre", "Insatisfait"), 200, replace = TRUE),
  region = sample(c("Nord", "Sud"), 200, replace = TRUE),
  genre = sample(c("Homme", "Femme"), 200, replace = TRUE)
)

# Exemple 1 : graphiques simples sans regroupement
plotPercentBar(
  dt = dtEx,
  cols = c("q1", "q2"),
  outputDir = "output/graphs"
)

# Exemple 2 : graphiques avec une variable de regroupement
plotPercentBar(
  dt = dtEx,
  cols = c("q1", "q2"),
  outputDir = "output/graphs",
  groupVars = "region"
)

# Exemple 3 : graphiques empilés avec deux variables de regroupement
plotPercentBar(
  dt = dtEx,
  cols = c("q1", "q2"),
  outputDir = "output/graphs",
  groupVars = c("region", "genre"),
  stacked = TRUE,
  labelThreshold = 8
)

# Exemple 4 : avec labels personnalisés et couleurs modifiées
plotPercentBar(
  dt = dtEx,
  cols = "q1",
  outputDir = "output/graphs",
  valueLabels = c("Oui" = "Oui", "Non" = "Non", "NSP" = "Ne sait pas"),
  barColors = c("#F39200", "#E71E73", "#951B81"),
  fileFormat = "pdf"
)
} # }
```
