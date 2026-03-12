# Changelog

## packageOejqs 0.1.0

### Première version

#### Nouvelles fonctions

##### 📥 Chargement Qualtrics

- [`extractLabels()`](../reference/extractLabels.md) : extraction des
  labels depuis un export Qualtrics
- `applyValueLabels()` : application des labels sur les données brutes

##### 🔄 Transformation

- [`recodeBinary()`](../reference/recodeBinary.md) : recodage de
  variables catégorielles en 0/1
- [`recodeNumeric()`](../reference/recodeNumeric.md) : recodage de
  variables numériques par table de correspondance
- [`summariseItemsByGroup()`](../reference/summariseItemsByGroup.md) :
  statistiques descriptives d’items par groupe

##### 📊 Visualisation

- [`plotPercentBar()`](../reference/plotPercentBar.md) : graphique en
  barres avec pourcentages
- [`plotGroupedBarCharts()`](../reference/plotGroupedBarCharts.md) :
  barres groupées par variable de groupe
- [`plotMultiBinBar()`](../reference/plotMultiBinBar.md) : barres
  multiples pour items binaires
- [`plotProportionHeatmap()`](../reference/plotProportionHeatmap.md) :
  heatmap de proportions / scores moyens

##### 🔧 Utilitaires

- [`cleanTextCols()`](../reference/cleanTextCols.md) : nettoyage des
  colonnes textuelles
- [`rgbToHex()`](../reference/rgbToHex.md) : conversion RGB vers code
  hexadécimal
- [`sourceIsolated()`](../reference/sourceIsolated.md) : chargement
  isolé d’un script R
