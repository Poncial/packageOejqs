
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
# install.packages("pak")  # si pak n'est pas encore installé
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
| 📥 **Qualtrics** | `extractLabels()`, `applyValueLabels()` |
| 🔄 **Transform** | `recodeBinary()`, `recodeNumeric()`, `summariseItemsByGroup()` |
| 📊 **Plot** | `plotGroupedBarCharts()`, `plotMultiBinBar()`, `plotPercentBar()`, `plotProportionHeatmap()` |
| 🔧 **Utilitaires** | `cleanTextCols()`, `rgbToHex()`, `sourceIsolated()` |

## Documentation complète

👉 [poncial.github.io/packageOejqs](https://poncial.github.io/packageOejqs)

