# ==============================================================================
# Helpers internes
# ==============================================================================

# Vérifie qu'un argument est NULL ou character(1) non vide
assertNullOrString <- function(x, argName) {
  if (!is.null(x) && (!is.character(x) || length(x) != 1L || nchar(x) == 0L)) {
    stop(sprintf("`%s` doit être NULL ou un character de longueur 1 non vide.", argName))
  }
}

# Vérifie qu'un vecteur de labels est bien un named character
assertValueLabels <- function(x, argName) {
  if (is.null(x)) {
    return(invisible(NULL))
  }
  if (!is.character(x) || is.null(names(x))) {
    stop(sprintf("`%s` doit être un vecteur character nommé, ex: c('1'='Pas du tout').", argName))
  }
  if (any(trimws(names(x)) == "")) {
    stop(sprintf("`%s` contient des noms vides.", argName))
  }
}

# Vérifie que toutes les couleurs sont reconnues
assertColors <- function(colors, argName = "fillColors") {
  isValid <- vapply(
    colors,
    function(oneColor) {
      !inherits(try(grDevices::col2rgb(oneColor), silent = TRUE), "try-error")
    },
    logical(1)
  )

  if (!all(isValid)) {
    stop(sprintf(
      "Couleurs invalides dans `%s`: %s",
      argName,
      paste(colors[!isValid], collapse = ", ")
    ))
  }
}

# Nettoyage d'un texte pour usage dans un nom de fichier
sanitizeForFile <- function(x) {
  x <- gsub("[^[:alnum:]_]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_|_$", "", x)
  tolower(x)
}

# Applique un mapping robuste code -> label à une variable
applyValueLabels <- function(localDt, varName, valueLabels, warnUnmapped = TRUE) {
  if (is.null(valueLabels)) {
    localDt[, (varName) := factor(trimws(as.character(get(varName))))]
    return(localDt)
  }

  mapDt <- data.table(
    rawValue = trimws(names(valueLabels)),
    labelValue = unname(valueLabels)
  )

  localDt[, rawValueTmp := trimws(as.character(get(varName)))]
  localDt <- mapDt[localDt, on = c("rawValue" = "rawValueTmp")]
  localDt[is.na(labelValue), labelValue := rawValue]

  if (isTRUE(warnUnmapped)) {
    unmapped <- unique(localDt[!(rawValue %in% mapDt$rawValue), rawValue])
    if (length(unmapped) > 0L) {
      warning(sprintf(
        "Variable `%s`: valeurs non présentes dans les labels: %s",
        varName,
        paste(sort(unmapped), collapse = ", ")
      ))
    }
  }

  levelOrder <- unique(c(unname(valueLabels), localDt$labelValue))
  localDt[, (varName) := factor(labelValue, levels = levelOrder)]
  localDt[, c("rawValue", "labelValue") := NULL]

  localDt
}

# Construit le nom de fichier
buildFileName <- function(xVar, yVar, mode, groupVars, groupLabelForFile, fileFormat) {
  valDate <- format(Sys.Date(), "%Y%m%d")

  groupLabel <- if (!is.null(groupLabelForFile)) {
    groupLabelForFile
  } else if (length(groupVars) > 0L) {
    paste(groupVars, collapse = "_")
  } else {
    "all"
  }

  sprintf(
    "%s_%s_%s_by_%s_%s_heatmap.%s",
    valDate,
    sanitizeForFile(groupLabel),
    sanitizeForFile(xVar),
    sanitizeForFile(yVar),
    sanitizeForFile(mode),
    tolower(fileFormat)
  )
}

#' Générer une heatmap des proportions d'une variable ordinale selon une variable Likert
#'
#' Cette fonction calcule et visualise la distribution conditionnelle de \code{yVar}
#' au sein de chaque modalité de \code{xVar}, avec possibilité de facettage (0 à 2 variables).
#' Deux modes sont disponibles :
#' \itemize{
#'   \item \code{"proportion"} : proportions brutes \eqn{P(y \mid x, groupes)}
#'   \item \code{"deviation_uniform"} : écart à une référence uniforme \eqn{1 / K}
#' }
#'
#' Le graphique est exporté automatiquement dans \code{outputDir}.
#' Le dossier est créé s'il n'existe pas.
#'
#' @param data \code{data.frame} ou \code{data.table} contenant les variables.
#' @param xVar \code{character(1)}. Nom de la variable Likert affichée en abscisse.
#' @param yVar \code{character(1)}. Nom de la variable ordinale affichée en ordonnée.
#' @param groupVars \code{character}. Vecteur de 0 à 2 variables de regroupement pour les facettes.
#' @param groupLabelForFile \code{character(1)} optionnel. Label personnalisé à insérer dans le nom de fichier
#'   (ex. \code{"genre"}). Si \code{NULL}, utilise \code{groupVars} ou \code{"all"}.
#' @param mode \code{character(1)}. \code{"proportion"} (défaut) ou \code{"deviation_uniform"}.
#' @param xAxisTitle \code{character(1)} optionnel. Titre de l'axe x.
#' @param yAxisTitle \code{character(1)} optionnel. Titre de l'axe y.
#' @param showTitle \code{logical(1)}. Afficher un titre de graphique (\code{FALSE} par défaut).
#' @param plotTitle \code{character(1)} optionnel. Titre personnalisé (utilisé si \code{showTitle = TRUE}).
#' @param xValueLabels \code{character} nommé optionnel. Mapping des valeurs de \code{xVar}
#'   (ex. \code{c("1"="Pas du tout d'accord", ...)}).
#' @param yValueLabels \code{character} nommé optionnel. Mapping des valeurs de \code{yVar}.
#' @param outputDir \code{character(1)}. Dossier de sortie pour l'export.
#' @param fileFormat \code{character(1)}. Format de sortie : \code{"png"}, \code{"pdf"}, \code{"jpeg"},
#'   \code{"jpg"}, \code{"tiff"} ou \code{"bmp"}.
#' @param width \code{numeric(1)}. Largeur du graphique exporté.
#' @param height \code{numeric(1)}. Hauteur du graphique exporté.
#' @param dpi \code{numeric(1)}. Résolution pour les formats raster.
#' @param naRm \code{logical(1)}. Supprimer les lignes avec NA sur les variables utilisées.
#' @param dropUnusedLevels \code{logical(1)}. Argument passé aux facettes ggplot.
#' @param fillColors \code{character}. Couleurs de remplissage :
#'   au moins 2 en mode \code{"proportion"}, au moins 3 en mode \code{"deviation_uniform"}.
#' @param midpoint \code{numeric(1)} optionnel. Point milieu pour \code{"deviation_uniform"}.
#'   Si \code{NULL}, utilise 0.
#' @param warnUnmapped \code{logical(1)}. Afficher un warning si certaines valeurs observées
#'   ne sont pas présentes dans \code{xValueLabels}/\code{yValueLabels}.
#'
#' @return Une liste avec :
#' \describe{
#'   \item{plot}{Objet \code{ggplot}.}
#'   \item{aggregatedData}{\code{data.table} agrégée (comptages, total, proportion, déviation).}
#'   \item{outputPath}{Chemin complet du fichier exporté.}
#'   \item{fileName}{Nom du fichier exporté.}
#'   \item{mode}{Mode utilisé.}
#'   \item{uniformReference}{Référence uniforme \eqn{1/K} utilisée pour la déviation.}
#' }
#'
#' @details
#' Structure du nom de fichier :
#' \code{valDate_groupLabel_xVar_by_yVar_mode_heatmap.fileFormat}
#' avec \code{valDate <- format(Sys.Date(), "\%Y\%m\%d")}.
#'
#' @examples
#' \dontrun{
#' labLikert <- c(
#'   "1" = "Pas du tout d'accord",
#'   "2" = "Plutôt pas d'accord",
#'   "3" = "Ni d'accord ni pas d'accord",
#'   "4" = "Plutôt d'accord",
#'   "5" = "Tout à fait d'accord"
#' )
#'
#' res <- plotProportionHeatmap(
#'   data = dtEleves,
#'   xVar = "qid59",
#'   yVar = "qid67",
#'   groupVars = "sexe",
#'   groupLabelForFile = "genre",
#'   mode = "proportion",
#'   showTitle = FALSE,
#'   xAxisTitle = "Niveau d'accord",
#'   yAxisTitle = "Réponse ordinale",
#'   xValueLabels = labLikert,
#'   yValueLabels = labLikert,
#'   outputDir = "outputs/heatmaps"
#' )
#'
#' print(res$plot)
#' res$outputPath
#' }
#'
#' @export
plotProportionHeatmap <- function(data,
                                  xVar,
                                  yVar,
                                  groupVars = NULL,
                                  groupLabelForFile = NULL,
                                  mode = c("proportion", "deviation_uniform"),
                                  xAxisTitle = NULL,
                                  yAxisTitle = NULL,
                                  showTitle = FALSE,
                                  plotTitle = NULL,
                                  xValueLabels = NULL,
                                  yValueLabels = NULL,
                                  outputDir = "outputs/heatmaps",
                                  fileFormat = "png",
                                  width = 10,
                                  height = 7,
                                  dpi = 300,
                                  naRm = TRUE,
                                  dropUnusedLevels = FALSE,
                                  fillColors = c(
                                    "#575783", "#662483", "#951B81",
                                    "#E71E73", "#F39200"
                                  ),
                                  midpoint = NULL,
                                  warnUnmapped = TRUE) {
  mode <- match.arg(mode)

  # Validations de base
  if (!inherits(data, c("data.frame", "data.table"))) {
    stop("`data` doit être un data.frame ou data.table.")
  }
  if (!is.character(xVar) || length(xVar) != 1L) {
    stop("`xVar` doit être un character de longueur 1.")
  }
  if (!is.character(yVar) || length(yVar) != 1L) {
    stop("`yVar` doit être un character de longueur 1.")
  }

  if (is.null(groupVars)) groupVars <- character(0)
  if (!is.character(groupVars) || length(groupVars) > 2L) {
    stop("`groupVars` doit être un vecteur character de 0 à 2 variables.")
  }

  requiredCols <- unique(c(xVar, yVar, groupVars))
  missingCols <- setdiff(requiredCols, names(data))
  if (length(missingCols) > 0L) {
    stop(sprintf("Colonnes manquantes dans `data`: %s", paste(missingCols, collapse = ", ")))
  }

  assertNullOrString(groupLabelForFile, "groupLabelForFile")
  assertNullOrString(xAxisTitle, "xAxisTitle")
  assertNullOrString(yAxisTitle, "yAxisTitle")
  assertNullOrString(plotTitle, "plotTitle")
  assertNullOrString(outputDir, "outputDir")

  if (!is.logical(showTitle) || length(showTitle) != 1L) {
    stop("`showTitle` doit être un logical de longueur 1.")
  }

  validFormats <- c("png", "pdf", "jpeg", "jpg", "tiff", "bmp")
  if (!tolower(fileFormat) %in% validFormats) {
    stop(sprintf("`fileFormat` doit être parmi: %s", paste(validFormats, collapse = ", ")))
  }

  assertValueLabels(xValueLabels, "xValueLabels")
  assertValueLabels(yValueLabels, "yValueLabels")

  minColors <- if (identical(mode, "deviation_uniform")) 3L else 2L
  if (!is.character(fillColors) || length(fillColors) < minColors) {
    stop(sprintf(
      "`fillColors` doit contenir au moins %s couleurs pour mode `%s`.",
      minColors, mode
    ))
  }
  assertColors(fillColors, "fillColors")

  # Préparation des données
  dt <- as.data.table(copy(data))[, ..requiredCols]

  if (isTRUE(naRm)) {
    dt <- dt[complete.cases(dt)]
  }
  if (nrow(dt) == 0L) {
    stop("Aucune donnée disponible après suppression des NA.")
  }

  dt <- applyValueLabels(dt, xVar, xValueLabels, warnUnmapped = warnUnmapped)
  dt <- applyValueLabels(dt, yVar, yValueLabels, warnUnmapped = warnUnmapped)

  if (is.null(xAxisTitle)) xAxisTitle <- xVar
  if (is.null(yAxisTitle)) yAxisTitle <- yVar

  # Agrégation
  byCount <- c(groupVars, xVar, yVar)
  byTotal <- c(groupVars, xVar)

  aggDt <- dt[, .(n = .N), by = byCount]
  aggDt[, total := sum(n), by = byTotal]
  aggDt[, proportion := n / total]

  # Déviation à l'uniforme
  kY <- nlevels(dt[[yVar]])
  uniformReference <- 1 / kY
  aggDt[, deviationUniform := proportion - uniformReference]

  # Paramètres visuels selon mode
  if (identical(mode, "proportion")) {
    fillVar <- "proportion"
    textVector <- sprintf("%.1f%%", 100 * aggDt$proportion)
    fillScale <- scale_fill_gradientn(
      colours = fillColors,
      limits = c(0, 1),
      name = "Proportion"
    )
  } else {
    maxAbs <- max(abs(aggDt$deviationUniform), na.rm = TRUE)
    useMidpoint <- if (is.null(midpoint)) 0 else midpoint

    fillVar <- "deviationUniform"
    textVector <- sprintf("%+.1f pt", 100 * aggDt$deviationUniform)
    fillScale <- scale_fill_gradient2(
      low = fillColors[1],
      mid = fillColors[ceiling(length(fillColors) / 2)],
      high = fillColors[length(fillColors)],
      midpoint = useMidpoint,
      limits = c(-maxAbs, maxAbs),
      name = sprintf("Déviation uniforme (1/%s)", kY)
    )
  }

  # Titre optionnel
  finalTitle <- NULL
  if (isTRUE(showTitle)) {
    if (!is.null(plotTitle)) {
      finalTitle <- plotTitle
    } else if (identical(mode, "proportion")) {
      finalTitle <- sprintf("Proportions de %s selon %s", yAxisTitle, xAxisTitle)
    } else {
      finalTitle <- sprintf("Déviation à l'uniforme de %s selon %s", yAxisTitle, xAxisTitle)
    }
  }

  # Plot
  heatmapPlot <- ggplot(
    aggDt,
    aes(
      x = .data[[xVar]],
      y = .data[[yVar]],
      fill = .data[[fillVar]]
    )
  ) +
    geom_tile(color = "white", linewidth = 0.3) +
    geom_text(aes(label = textVector), size = 3) +
    fillScale +
    labs(
      title = finalTitle,
      x = xAxisTitle,
      y = yAxisTitle
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = if (isTRUE(showTitle)) element_text() else element_blank(),
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 30, hjust = 1),
      strip.text = element_text(face = "bold")
    )

  if (length(groupVars) == 1L) {
    heatmapPlot <- heatmapPlot +
      facet_wrap(as.formula(paste("~", groupVars[1])), drop = dropUnusedLevels)
  } else if (length(groupVars) == 2L) {
    heatmapPlot <- heatmapPlot +
      facet_grid(as.formula(paste(groupVars[1], "~", groupVars[2])), drop = dropUnusedLevels)
  }

  # Export
  fileName <- buildFileName(
    xVar = xVar,
    yVar = yVar,
    mode = mode,
    groupVars = groupVars,
    groupLabelForFile = groupLabelForFile,
    fileFormat = fileFormat
  )

  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE, showWarnings = FALSE)
  }

  outputPath <- file.path(outputDir, fileName)

  ggsave(
    filename = outputPath,
    plot = heatmapPlot,
    width = width,
    height = height,
    dpi = dpi
  )

  list(
    plot = heatmapPlot,
    aggregatedData = aggDt[],
    outputPath = outputPath,
    fileName = fileName,
    mode = mode,
    uniformReference = uniformReference
  )
}
