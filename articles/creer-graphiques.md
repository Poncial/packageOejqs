# Créer des graphiques

``` r
library(packageOejqs)
library(data.table)
```

------------------------------------------------------------------------

## Quelle fonction choisir ?

| Situation                                    | Fonction recommandée                                                                                   |
|----------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Une seule question, répartition des réponses | [`plotPercentBar()`](https://poncial.github.io/packageOejqs/reference/plotPercentBar.md)               |
| Une question, comparaison entre groupes      | [`plotGroupedBarCharts()`](https://poncial.github.io/packageOejqs/reference/plotGroupedBarCharts.md)   |
| Plusieurs questions binaires (Oui/Non)       | [`plotMultiBinBar()`](https://poncial.github.io/packageOejqs/reference/plotMultiBinBar.md)             |
| Scores moyens, plusieurs items x groupes     | [`plotProportionHeatmap()`](https://poncial.github.io/packageOejqs/reference/plotProportionHeatmap.md) |

------------------------------------------------------------------------

## `plotPercentBar()` — Répartition d’une question

**Quand l’utiliser ?** Pour afficher la distribution des réponses à une
seule question sous forme de barres en pourcentage.

``` r
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

| Paramètre        | Rôle                                               | Valeur par défaut |
|------------------|----------------------------------------------------|-------------------|
| `question`       | Nom de la colonne à afficher                       | —                 |
| `title`          | Titre du graphique                                 | `""`              |
| `wrapWidth`      | Largeur max des étiquettes avant retour à la ligne | `20`              |
| `angleThreshold` | Nb d’étiquettes avant rotation automatique         | `5`               |

------------------------------------------------------------------------

## `plotGroupedBarCharts()` — Comparaison entre groupes

**Quand l’utiliser ?** Pour comparer les réponses à une question selon
une variable de groupe (département, genre, tranche d’âge…).

``` r
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

------------------------------------------------------------------------

## `plotMultiBinBar()` — Plusieurs questions binaires

**Quand l’utiliser ?** Pour afficher le taux de réponse “Oui” sur
plusieurs questions binaires (cases à cocher, items Vrai/Faux…).

``` r
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

> 💡 **Astuce :** utilise
> [`recodeBinary()`](https://poncial.github.io/packageOejqs/reference/recodeBinary.md)
> au préalable pour préparer tes données si elles sont encore sous forme
> textuelle (Oui/Non).

------------------------------------------------------------------------

## `plotProportionHeatmap()` — Heatmap de scores

**Quand l’utiliser ?** Pour visualiser les scores moyens de plusieurs
items en fonction d’un groupe.

``` r
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

- 🟠 **Couleur chaude** -\> proportion élevée
- 🟣 **Couleur froide** -\> proportion faible
