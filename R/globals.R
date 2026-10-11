# globals.R
# Déclaration des variables globales pour R CMD CHECK
# Nécessaire pour data.table (`:=`, `.SD`, `.N`, etc.)
# et ggplot2 (`.data`, variables esthétiques)

# -- Suppression des faux positifs R CMD CHECK ---------------------
utils::globalVariables(c(
  # -- data.table : opérateurs et pronoms spéciaux --
  ".",

  # -- data.table : variables ..col (passage de vecteurs de noms) --
  "..keepCols",
  "..requiredCols",
  "..selectedVar",
  "..textCols",
  "..varItems",


  # -- ggplot2 : pronom tidy eval --
  ".data",

  # -- Variables de colonnes (data.table j/by) --
  "Destination",
  "Source",
  "deviationUniform",
  "inversionAxe",
  "item",
  "labelValue",
  "n",
  "pct",
  "pctGlobal",
  "pctLabel",
  "proportion",
  "question",
  "rawValue",
  "rawValueTmp",
  "reponse",
  "total",
  "value",
  "targetVariable",
  "N",
  "sigLabel",
  "labelVar1",
  "labelVar2",
  "suspect",
  "similarite",
  "var1",
  "var2",
  "pValue",
  "rho",
  "suspect",
  "similarite"

))
