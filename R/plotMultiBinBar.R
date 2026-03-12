#' Graphique en barres horizontales pour variables binaires (choix multiples)
#'
#' @description
#' Génère un graphique en barres horizontales triées par ordre décroissant de
#' pourcentage, adapté aux questions à choix multiples (variables 0/1).
#' Le graphique mentionne explicitement que plusieurs réponses sont possibles
#' et affiche le N total de répondants.
#'
#' Sans variable de regroupement, un seul graphique est produit.
#' Avec une variable de regroupement, un `facet_wrap` est utilisé.
#' Avec deux variables de regroupement, un `facet_grid` est utilisé
#' (première variable en lignes, seconde en colonnes).
#'
#' Les items sont triés selon leur pourcentage global (sans groupement),
#' ce qui permet de conserver une référence de lecture cohérente entre
#' les facettes.
#'
#' @param dt [data.table] Table de données source.
#' @param cols [character] Noms des colonnes binaires (0/1) à analyser.
#' @param labels [character] Labels affichés à la place des noms de colonnes. Doit être de même longueur que `cols`. Si NULL, les noms de colonnes sont utilisés.
#' @param groupVars [character] Vecteur de 0, 1 ou 2 noms de variables catégorielles pour le regroupement. Default : NULL.
#' @param question Chaîne de caractères. Titre de la question affiché en titre du graphique.
#' @param outputDir [character] Répertoire de sauvegarde du graphique.
#' @param fileFormat [character] Format de sortie : "png", "pdf" ou "svg". Default : "png".
#' @param barColor [character] Couleur des barres. Default : "#662483".
#' @param width [numeric]  Largeur en pouces. Default : 8.
#' @param height [numeric]  Hauteur en pouces. Default : 5.
#' @param dpi [numeric]  Résolution (ignorée pour pdf). Default : 300.
#' @param xAxisTitle [character] Titre de l'axe X. Default : NULL.
#' @param graphTitle [character] Titre principal du graphique. Default : NULL.
#' @param subTitle [character] Sous-titre du graphique. Default : NULL.
#' @param fontSize [numeric]  Taille de base des textes. Default : 11.
#' @param labelSize [numeric]  Taille des étiquettes de valeurs sur les barres. Default : 3.
#'
#' @return Invisiblement, le chemin complet du fichier sauvegardé.
#'
#' @examples
#' \dontrun{
#' dtEx <- data.table::data.table(
#'   smartphone = sample(0:1, 200, replace = TRUE),
#'   ordinateur = sample(0:1, 200, replace = TRUE),
#'   tablette   = sample(0:1, 200, replace = TRUE),
#'   console    = sample(0:1, 200, replace = TRUE),
#'   television = sample(0:1, 200, replace = TRUE),
#'   region     = sample(c("Nord", "Sud"), 200, replace = TRUE),
#'   genre      = sample(c("Homme", "Femme"), 200, replace = TRUE)
#' )
#'
#' # Sans regroupement
#' plotMultiBinBar(
#'   dt        = dtEx,
#'   cols      = c("smartphone", "ordinateur", "tablette"),
#'   outputDir = "output/graphs"
#' )
#'
#' # Avec une variable de regroupement
#' plotMultiBinBar(
#'   dt        = dtEx,
#'   cols      = c("smartphone", "ordinateur", "tablette"),
#'   groupVars = "genre",
#'   outputDir = "output/graphs"
#' )
#'
#' # Avec deux variables de regroupement
#' plotMultiBinBar(
#'   dt        = dtEx,
#'   cols      = c("smartphone", "ordinateur", "tablette"),
#'   groupVars = c("genre", "region"),
#'   outputDir = "output/graphs"
#' )
#' }
#'
#' @importFrom data.table is.data.table copy melt
#' @importFrom ggplot2 ggplot aes geom_col geom_text facet_wrap facet_grid
#'   scale_x_continuous expansion labs theme_minimal theme element_text
#'   element_blank margin
#' @importFrom purrr walk
#' @export
plotMultiBinBar <- function(
    dt,
    cols,
    labels = NULL,
    groupVars = NULL,
    question = NULL,
    outputDir,
    fileFormat = "png",
    barColor = "#662483",
    width = 8,
    height = 5,
    dpi = 300,
    xAxisTitle = NULL,
    graphTitle = NULL,
    subTitle = NULL,
    fontSize = 11,
    labelSize = 3
) {
  # ── 1. Validation des arguments ──────────────────────────────────────────────

  if (!data.table::is.data.table(dt)) {
    stop("`dt` doit être un data.table.")
  }

  if (!is.character(cols) || length(cols) == 0) {
    stop("`cols` doit être un vecteur character non vide.")
  }

  missingCols <- setdiff(cols, names(dt))
  if (length(missingCols) > 0) {
    stop(
      "Colonnes introuvables dans `dt` : ",
      paste(missingCols, collapse = ", ")
    )
  }

  # Vérification que les colonnes sont bien binaires (0/1 ou NA)
  purrr::walk(cols, function(col) {
    vals <- unique(dt[[col]])
    vals <- vals[!is.na(vals)]
    if (!all(vals %in% c(0, 1))) {
      stop(
        "La colonne '", col,
        "' contient des valeurs autres que 0 et 1."
      )
    }
  })

  if (!is.null(labels)) {
    if (length(labels) != length(cols)) {
      stop("`labels` doit avoir la même longueur que `cols`.")
    }
  } else {
    labels <- cols
  }

  if (!is.null(groupVars)) {
    if (length(groupVars) > 2) {
      stop("`groupVars` ne peut pas contenir plus de 2 variables.")
    }
    missingGrp <- setdiff(groupVars, names(dt))
    if (length(missingGrp) > 0) {
      stop(
        "Variables de groupVars introuvables dans `dt` : ",
        paste(missingGrp, collapse = ", ")
      )
    }
  }

  fileFormat <- match.arg(fileFormat, c("png", "pdf", "svg"))

  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
    message("Répertoire créé : ", outputDir)
  }

  # ── 2. Préparation des données ───────────────────────────────────────────────

  # N total (avant tout filtrage)
  nTotal <- nrow(dt)

  # Correspondance colonnes <-> labels
  labelMap <- stats::setNames(labels, cols)

  # Copie de travail avec uniquement les colonnes nécessaires
  keepCols <- c(cols, groupVars)
  dtWork <- data.table::copy(dt[, ..keepCols])

  # Passage en format long
  dtLong <- data.table::melt(
    dtWork,
    measure.vars = cols,
    variable.name = "item",
    value.name = "reponse",
    variable.factor = FALSE
  )

  # Remplacement des noms de colonnes par les labels
  dtLong[, item := labelMap[item]]

  # ── 3. Calcul de l'ordre global (référence de tri) ──────────────────────────

  # Le tri est basé sur le pourcentage global, sans regroupement,
  # pour garantir une lecture cohérente entre les facettes
  dtGlobal <- dtLong[
    !is.na(reponse),
    .(pctGlobal = mean(reponse) * 100),
    by = item
  ]
  itemOrder <- dtGlobal[order(pctGlobal), item]

  # ── 4. Calcul des pourcentages (avec ou sans groupement) ────────────────────

  if (is.null(groupVars)) {
    dtPlot <- dtLong[
      !is.na(reponse),
      .(pct = mean(reponse) * 100),
      by = item
    ]
  } else {
    dtPlot <- dtLong[
      !is.na(reponse),
      .(pct = mean(reponse) * 100),
      by = c("item", groupVars)
    ]
  }

  # Application de l'ordre des items (facteur ordonné)
  dtPlot[, item := factor(item, levels = itemOrder)]

  # Label de pourcentage formaté pour l'affichage
  dtPlot[, pctLabel := paste0(round(pct, 1), "%")]

  # ── 5. Construction du graphique ─────────────────────────────────────────────

  # Note de bas de graphique : choix multiples + N total
  captionTxt <- paste0(
    "Question à choix multiples",
    " \u2014 les pourcentages ne s'additionnent pas à 100 %\n",
    "N = ", format(nTotal, big.mark = "\u202f")
  )

  p <- ggplot2::ggplot(
    dtPlot,
    ggplot2::aes(x = pct, y = item)
  ) +
    ggplot2::geom_col(fill = barColor, width = 0.6) +
    ggplot2::geom_text(
      ggplot2::aes(label = pctLabel),
      hjust = -0.15,
      size = labelSize,
      color = "grey30"
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, 110),
      labels = function(x) paste0(x, "%"),
      expand = ggplot2::expansion(mult = c(0, 0))
    ) +
    ggplot2::labs(
      title = graphTitle,
      subtitle = subTitle,
      x = if (is.null(xAxisTitle)) "% de répondants" else xAxisTitle,
      y = NULL,
      caption = captionTxt
    ) +
    ggplot2::theme_minimal(base_size = fontSize) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold",
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        color = "grey40",
        margin = ggplot2::margin(b = 8)
      ),
      plot.caption = ggplot2::element_text(
        color = "grey50",
        hjust = 0,
        size = fontSize * 0.75
      ),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(size = fontSize * 0.9),
      strip.text = ggplot2::element_text(
        face = "bold",
        size = fontSize * 0.95
      )
    )

  # ── 6. Ajout des facettes selon le nombre de groupVars ───────────────────────

  if (length(groupVars) == 1) {
    p <- p + ggplot2::facet_wrap(
      stats::as.formula(paste("~", groupVars[1]))
    )
  } else if (length(groupVars) == 2) {
    p <- p + ggplot2::facet_grid(
      stats::as.formula(paste(groupVars[1], "~", groupVars[2]))
    )
  }

  # ── 7. Sauvegarde ────────────────────────────────────────────────────────────

  # Construction du nom de fichier
  valDate <- format(Sys.Date(), "%Y%m%d")

  groupSuffix <- if (!is.null(groupVars)) {
    paste0("_by_", paste(groupVars, collapse = "_"))
  } else {
    ""
  }


  filePath <- file.path(
    outputDir,
    paste0(valDate, "_", question, groupSuffix, "_percent.", fileFormat)
  )

  ggplot2::ggsave(
    filename = filePath,
    plot = p,
    width = width,
    height = height,
    dpi = if (fileFormat == "pdf") NULL else dpi
  )

  message("Graphique sauvegardé : ", filePath)
  invisible(filePath)
}
