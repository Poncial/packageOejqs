# Générer une heatmap des proportions d'une variable ordinale selon une variable Likert

Cette fonction calcule et visualise la distribution conditionnelle de
`yVar` au sein de chaque modalité de `xVar`, avec possibilité de
facettage (0 à 2 variables). Deux modes sont disponibles :

- `"proportion"` : proportions brutes \\P(y \mid x, groupes)\\

- `"deviation_uniform"` : écart à une référence uniforme \\1 / K\\

## Usage

``` r
plotProportionHeatmap(
  data,
  xVar,
  yVar,
  groupVars = NULL,
  groupLabelForFile = NULL,
  mode = c("proportion", "deviation_uniform"),
  xAxisTitle = NULL,
  yAxisTitle = NULL,
  showTitle = FALSE,
  plotTitle = NULL,
  xValueLabels = NULL,
  yValueLabels = NULL,
  outputDir = "outputs/heatmaps",
  fileFormat = "png",
  width = 10,
  height = 7,
  dpi = 300,
  naRm = TRUE,
  dropUnusedLevels = FALSE,
  fillColors = c("#575783", "#662483", "#951B81", "#E71E73", "#F39200"),
  midpoint = NULL,
  warnUnmapped = TRUE
)
```

## Arguments

- data:

  `data.frame` ou `data.table` contenant les variables.

- xVar:

  `character(1)`. Nom de la variable Likert affichée en abscisse.

- yVar:

  `character(1)`. Nom de la variable ordinale affichée en ordonnée.

- groupVars:

  `character`. Vecteur de 0 à 2 variables de regroupement pour les
  facettes.

- groupLabelForFile:

  `character(1)` optionnel. Label personnalisé à insérer dans le nom de
  fichier (ex. `"genre"`). Si `NULL`, utilise `groupVars` ou `"all"`.

- mode:

  `character(1)`. `"proportion"` (défaut) ou `"deviation_uniform"`.

- xAxisTitle:

  `character(1)` optionnel. Titre de l'axe x.

- yAxisTitle:

  `character(1)` optionnel. Titre de l'axe y.

- showTitle:

  `logical(1)`. Afficher un titre de graphique (`FALSE` par défaut).

- plotTitle:

  `character(1)` optionnel. Titre personnalisé (utilisé si
  `showTitle = TRUE`).

- xValueLabels:

  `character` nommé optionnel. Mapping des valeurs de `xVar` (ex.
  `c("1"="Pas du tout d'accord", ...)`).

- yValueLabels:

  `character` nommé optionnel. Mapping des valeurs de `yVar`.

- outputDir:

  `character(1)`. Dossier de sortie pour l'export.

- fileFormat:

  `character(1)`. Format de sortie : `"png"`, `"pdf"`, `"jpeg"`,
  `"jpg"`, `"tiff"` ou `"bmp"`.

- width:

  `numeric(1)`. Largeur du graphique exporté.

- height:

  `numeric(1)`. Hauteur du graphique exporté.

- dpi:

  `numeric(1)`. Résolution pour les formats raster.

- naRm:

  `logical(1)`. Supprimer les lignes avec NA sur les variables
  utilisées.

- dropUnusedLevels:

  `logical(1)`. Argument passé aux facettes ggplot.

- fillColors:

  `character`. Couleurs de remplissage : au moins 2 en mode
  `"proportion"`, au moins 3 en mode `"deviation_uniform"`.

- midpoint:

  `numeric(1)` optionnel. Point milieu pour `"deviation_uniform"`. Si
  `NULL`, utilise 0.

- warnUnmapped:

  `logical(1)`. Afficher un warning si certaines valeurs observées ne
  sont pas présentes dans `xValueLabels`/`yValueLabels`.

## Value

Une liste avec :

- plot:

  Objet `ggplot`.

- aggregatedData:

  `data.table` agrégée (comptages, total, proportion, déviation).

- outputPath:

  Chemin complet du fichier exporté.

- fileName:

  Nom du fichier exporté.

- mode:

  Mode utilisé.

- uniformReference:

  Référence uniforme \\1/K\\ utilisée pour la déviation.

## Details

Le graphique est exporté automatiquement dans `outputDir`. Le dossier
est créé s'il n'existe pas.

Structure du nom de fichier :
`valDate_groupLabel_xVar_by_yVar_mode_heatmap.fileFormat` avec
`valDate <- format(Sys.Date(), "%Y%m%d")`.

## Examples

``` r
if (FALSE) { # \dontrun{
labLikert <- c(
  "1" = "Pas du tout d'accord",
  "2" = "Plutôt pas d'accord",
  "3" = "Ni d'accord ni pas d'accord",
  "4" = "Plutôt d'accord",
  "5" = "Tout à fait d'accord"
)

res <- plotProportionHeatmap(
  data = dtEleves,
  xVar = "qid59",
  yVar = "qid67",
  groupVars = "sexe",
  groupLabelForFile = "genre",
  mode = "proportion",
  showTitle = FALSE,
  xAxisTitle = "Niveau d'accord",
  yAxisTitle = "Réponse ordinale",
  xValueLabels = labLikert,
  yValueLabels = labLikert,
  outputDir = "outputs/heatmaps"
)

print(res$plot)
res$outputPath
} # }
```
