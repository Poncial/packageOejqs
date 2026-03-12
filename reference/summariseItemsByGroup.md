# Calculer des statistiques descriptives par groupe pour des items numériques

Cette fonction calcule des mesures de tendance centrale et de dispersion
pour plusieurs items de questionnaire (Likert, échelles de fréquence ou
réponses codées numériquement), regroupés par une variable de groupe
spécifiée (par exemple : genre, tranche d'âge, condition expérimentale).

## Usage

``` r
summariseItemsByGroup(
  dt,
  varItems,
  groupVar,
  groupVar2 = NULL,
  includeTotal = TRUE,
  totalLabel = "all",
  ciLevel = 0.95,
  sdMultiplier = 1,
  reorderLevels = NULL,
  reorderLevels2 = NULL
)
```

## Arguments

- dt:

  Un `data.table` contenant les données.

- varItems:

  Vecteur de caractères indiquant les noms des colonnes correspondant
  aux items à résumer (Likert, ordinal, fréquence, ou MCQ codé
  numériquement).

- groupVar:

  Nom de la variable de regroupement (ex : `"genre"`, `"ageGroup"`,
  `"modele"`).

- groupVar2:

  Nom de la variable de regroupement secondaire

- includeTotal:

  Booléen. Indique si un résumé global sur tous les groupes doit être
  calculé. Par défaut `TRUE`.

- totalLabel:

  Nom utilisé pour le groupe global si `includeTotal = TRUE`. Par défaut
  `"all"`.

- ciLevel:

  Niveau de confiance pour l'intervalle de confiance (par défaut 0.95).

- sdMultiplier:

  Multiplicateur appliqué à l'écart-type (utile pour les graphiques, par
  défaut 1).

- reorderLevels:

  Vecteur de caractères indiquant l'ordre des niveaux du facteur du
  groupe. Si `NULL`, l'ordre est conservé tel quel.

- reorderLevels2:

  Vecteur de caractères indiquant l'ordre des niveaux du facteur du
  groupe 2. Si `NULL`, l'ordre est conservé tel quel.

## Value

Une liste nommée de `data.table`, une table par item. Chaque table
contient :

- `item` : nom de l'item

- la variable de groupe (ex : `modele`, `genre`)

- `mean` : moyenne

- `sd` : écart-type (multiplié par `sdMultiplier`)

- `se` : erreur standard

- `ci` : demi-largeur de l'intervalle de confiance

- `median` : médiane

- `iqr` : étendue interquartile

- `n` : nombre d'observations non manquantes

## Details

Il est possible de calculer également les statistiques pour l'ensemble
de l'échantillon ("total") et d'obtenir les résultats sous forme de
liste de tables par item, pratique pour la visualisation.

Toutes les statistiques sont calculées en supprimant les valeurs
manquantes de manière pairwise. L'intervalle de confiance repose sur
l'approximation normale : \$\$z\_{1-\alpha/2} \times
\frac{sd}{\sqrt{n}}\$\$ où \\z\\ dépend du niveau de confiance
`ciLevel`.

Cette fonction est adaptée pour les items **ordinaux ou numériques**.
Pour des variables purement nominales (MCQ), il est préférable de
calculer des proportions avec une fonction dédiée.

## Examples

``` r
library(data.table)
library(forcats)

# Exemple simulé
set.seed(123)
dtExemple <- data.table(
  genre = rep(c("Homme", "Femme"), each = 5),
  ageGroup = rep(c("10-12", "13-15"), times = 5),
  Q1 = sample(1:5, 10, replace = TRUE),
  Q2 = sample(1:5, 10, replace = TRUE)
)

# Calcul par genre
resGenre <- summariseItemsByGroup(
  dt = dtExemple,
  varItems = c("Q1", "Q2"),
  groupVar = "genre",
  includeTotal = TRUE,
  totalLabel = "Tous",
  ciLevel = 0.95
)

# Accéder au résumé pour Q1
resGenre$Q1
#>     genre   item  mean        sd        se        ci median   iqr     n
#>    <char> <fctr> <num>     <num>     <num>     <num>  <num> <num> <int>
#> 1:  Homme     Q1   2.6 0.5477226 0.2449490 0.4800912      3     1     5
#> 2:  Femme     Q1   3.0 1.5811388 0.7071068 1.3859038      3     2     5
#> 3:   Tous     Q1   2.8 1.1352924 0.3590110 0.7036486      3     1    10
```
