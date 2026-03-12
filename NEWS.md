
# packageOejqs 0.1.0

## Première version

### Nouvelles fonctions

#### 📥 Chargement Qualtrics
- `extractLabels()` : extraction des labels depuis un export Qualtrics
- `applyValueLabels()` : application des labels sur les données brutes

#### 🔄 Transformation
- `recodeBinary()` : recodage de variables catégorielles en 0/1
- `recodeNumeric()` : recodage de variables numériques par table de correspondance
- `summariseItemsByGroup()` : statistiques descriptives d'items par groupe

#### 📊 Visualisation
- `plotPercentBar()` : graphique en barres avec pourcentages
- `plotGroupedBarCharts()` : barres groupées par variable de groupe
- `plotMultiBinBar()` : barres multiples pour items binaires
- `plotProportionHeatmap()` : heatmap de proportions / scores moyens

#### 🔧 Utilitaires
- `cleanTextCols()` : nettoyage des colonnes textuelles
- `rgbToHex()` : conversion RGB vers code hexadécimal
- `sourceIsolated()` : chargement isolé d'un script R

