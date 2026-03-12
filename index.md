# packageOejqs

> Outils internes pour le chargement de données Qualtrics, la
> transformation de données et la création de graphiques.

## Installation

``` r
# Installer depuis GitHub
# install.packages("pak")  # si pak n'est pas encore installé
pak::pak("Poncial/packageOejqs")
```

## Utilisation rapide

``` r
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

| Famille            | Fonctions                                                                                                                                                                                                                                                                                                                                                                                          |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 📥 **Qualtrics**   | [`extractLabels()`](https://poncial.github.io/packageOejqs/reference/extractLabels.md), `applyValueLabels()`                                                                                                                                                                                                                                                                                       |
| 🔄 **Transform**   | [`recodeBinary()`](https://poncial.github.io/packageOejqs/reference/recodeBinary.md), [`recodeNumeric()`](https://poncial.github.io/packageOejqs/reference/recodeNumeric.md), [`summariseItemsByGroup()`](https://poncial.github.io/packageOejqs/reference/summariseItemsByGroup.md)                                                                                                               |
| 📊 **Plot**        | [`plotGroupedBarCharts()`](https://poncial.github.io/packageOejqs/reference/plotGroupedBarCharts.md), [`plotMultiBinBar()`](https://poncial.github.io/packageOejqs/reference/plotMultiBinBar.md), [`plotPercentBar()`](https://poncial.github.io/packageOejqs/reference/plotPercentBar.md), [`plotProportionHeatmap()`](https://poncial.github.io/packageOejqs/reference/plotProportionHeatmap.md) |
| 🔧 **Utilitaires** | [`cleanTextCols()`](https://poncial.github.io/packageOejqs/reference/cleanTextCols.md), [`rgbToHex()`](https://poncial.github.io/packageOejqs/reference/rgbToHex.md), [`sourceIsolated()`](https://poncial.github.io/packageOejqs/reference/sourceIsolated.md)                                                                                                                                     |

## Documentation complète

👉
[poncial.github.io/packageOejqs](https://poncial.github.io/packageOejqs)
