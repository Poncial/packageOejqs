# Démarrage rapide

## Installation

``` r
# Étape 1 : installer pak si nécessaire (à faire une seule fois)
install.packages("pak")

# Étape 2 : installer packageOejqs depuis GitHub
pak::pak("Poncial/packageOejqs")
```

## Charger le package

``` r
library(packageOejqs)
```

------------------------------------------------------------------------

## Workflow typique en 3 étapes

### Étape 1 — Charger des données Qualtrics 📥

``` r
# Extraire les labels depuis un export Qualtrics
labels <- extractLabels("mon_export_qualtrics.csv")

# Appliquer les labels sur les données brutes
donnees <- applyValueLabels(donnees_brutes, labels)
```

> 💡 **C’est quoi un “label” ?** Dans Qualtrics, les réponses sont
> souvent stockées sous forme de codes numériques (1, 2, 3…).
> [`extractLabels()`](../reference/extractLabels.md) récupère la
> correspondance entre ces codes et les vraies étiquettes (“Tout à fait
> d’accord”, “Plutôt d’accord”…).

------------------------------------------------------------------------

### Étape 2 — Transformer les données 🔄

``` r
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

------------------------------------------------------------------------

### Étape 3 — Visualiser 📊

``` r
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

------------------------------------------------------------------------

## En cas de problème

- 📖 Consulte la [référence des fonctions](../reference/index.md)
- 🐛 Signale un bug sur [GitHub
  Issues](https://github.com/Poncial/packageOejqs/issues)
- 💬 Contacte l’équipe en interne
