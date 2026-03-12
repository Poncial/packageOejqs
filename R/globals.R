# globals.R
# Déclaration des variables globales pour R CMD CHECK
# Nécessaire pour data.table (`:=`, `.SD`, `.N`, etc.)
# et ggplot2 (`.data`, variables esthétiques)

# -- Suppression des faux positifs R CMD CHECK ---------------------
utils::globalVariables(c(
  # -- data.table : opérateurs et pronoms spéciaux --
  ".",
  ".N",
  ".SD",
  ":=",
  "data.table",

  # -- data.table : variables ..col (passage de vecteurs de noms) --
  "..keepCols",
  "..requiredCols",
  "..selectedVar",
  "..textCols",
  "..varItems",

  # -- data.table : fonctions --
  "as.data.table",
  "rbindlist",
  "setnames",
  "uniqueN",

  # -- ggplot2 : pronom tidy eval --
  ".data",

  # -- ggplot2 : fonctions de scales et geoms --
  "geom_tile",
  "scale_fill_gradient2",
  "scale_fill_gradientn",
  "scale_x_discrete",

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
  "value"
))
