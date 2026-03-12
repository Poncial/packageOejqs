# Changelog

## packageOejqs 0.1.0

### Première version

#### Nouvelles fonctions

##### 📥 Chargement Qualtrics

- [`extractLabels()`](https://poncial.github.io/packageOejqs/reference/extractLabels.md)
  : extraction des labels depuis un export Qualtrics
- `applyValueLabels()` : application des labels sur les données brutes

##### 🔄 Transformation

- [`recodeBinary()`](https://poncial.github.io/packageOejqs/reference/recodeBinary.md)
  : recodage de variables catégorielles en 0/1
- [`recodeNumeric()`](https://poncial.github.io/packageOejqs/reference/recodeNumeric.md)
  : recodage de variables numériques par table de correspondance
- [`summariseItemsByGroup()`](https://poncial.github.io/packageOejqs/reference/summariseItemsByGroup.md)
  : statistiques descriptives d’items par groupe

##### 📊 Visualisation

- [`plotPercentBar()`](https://poncial.github.io/packageOejqs/reference/plotPercentBar.md)
  : graphique en barres avec pourcentages
- [`plotGroupedBarCharts()`](https://poncial.github.io/packageOejqs/reference/plotGroupedBarCharts.md)
  : barres groupées par variable de groupe
- [`plotMultiBinBar()`](https://poncial.github.io/packageOejqs/reference/plotMultiBinBar.md)
  : barres multiples pour items binaires
- [`plotProportionHeatmap()`](https://poncial.github.io/packageOejqs/reference/plotProportionHeatmap.md)
  : heatmap de proportions / scores moyens

##### 🔧 Utilitaires

- [`cleanTextCols()`](https://poncial.github.io/packageOejqs/reference/cleanTextCols.md)
  : nettoyage des colonnes textuelles
- [`rgbToHex()`](https://poncial.github.io/packageOejqs/reference/rgbToHex.md)
  : conversion RGB vers code hexadécimal
- [`sourceIsolated()`](https://poncial.github.io/packageOejqs/reference/sourceIsolated.md)
  : chargement isolé d’un script R
