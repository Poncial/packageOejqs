#' Générer des graphiques en barres de pourcentages
#'
#' @description
#' Cette fonction génère des graphiques en barres représentant la distribution
#' en pourcentage des modalités de réponse pour une ou plusieurs variables
#' d'intérêt. Les graphiques peuvent être groupés par une ou deux variables
#' de regroupement.
#'
#' @param dt `data.table`. La table de données source. Doit être un objet
#'   `data.table`.
#' @param cols `character`. Vecteur de noms de colonnes pour lesquelles générer
#'   les graphiques. Elles correspondent à une question. Chaque colonne donnera
#'   lieu à un graphique distinct.
#' @param outputDir `character`. Chemin du répertoire de sortie où les fichiers
#'   seront sauvegardés. Le répertoire est créé automatiquement s'il n'existe
#'   pas.
#' @param groupVars `character` ou `NULL`. Vecteur de regroupement (maximum 2).
#'   Si `NULL` (défaut), aucun regroupement n'est
#'   appliqué. Avec une variable, un `facet_wrap` est utilisé. Avec deux
#'   variables, un `facet_grid` est utilisé (mode non empilé) ou la première
#'   variable est placée en axe x et la seconde en `facet_wrap` (mode empilé).
#' @param valueLabels `character` ou `NULL`. Vecteur nommé de labels à
#'   appliquer aux modalités. Les noms doivent correspondre aux valeurs
#'   présentes dans `cols`. Si `NULL` (défaut), les valeurs brutes sont
#'   utilisées.
#' @param legendTitle `character` Titre de la légende
#' @param barColors `character`. Vecteur de couleurs hexadécimales utilisées
#'   pour les barres. Par défaut :
#'   `c("#F39200", "#E71E73", "#951B81", "#E84E0F", "#C3004D")`.
#'   Si le nombre de couleurs est inférieur au nombre de modalités, un
#'   avertissement est émis et les couleurs sont recyclées.
#' @param fileFormat `character`. Format d'export des graphiques. Valeurs
#'   acceptées : `"png"` (défaut), `"pdf"`, `"svg"`, `"jpeg"`, `"tiff"`.
#' @param width `numeric`. Largeur du graphique en pouces. Doit être strictement
#'   positif. Par défaut : `8`.
#' @param height `numeric`. Hauteur du graphique en pouces. Doit être
#'   strictement positif. Par défaut : `5`.
#' @param dpi `numeric`. Résolution du graphique en points par pouce. Doit être
#'   strictement positif. Par défaut : `300`.
#' @param xAxisTitle `character` ou `NULL`. Titre de l'axe x. Si `NULL`
#'   (défaut), le nom de la variable est utilisé.
#' @param yAxisTitle `character`. Titre de l'axe y. Par défaut :
#'   `"Pourcentage (%)"`.
#' @param stacked `logical`. Si `TRUE`, les barres sont empilées et normalisées
#'   à 100%. Si `FALSE` (défaut), les barres sont groupées côte à côte.
#' @param labelThreshold `numeric`. Seuil minimal en pourcentage (entre 0 et
#'   100) en dessous duquel les labels ne sont pas affichés sur les segments
#'   en mode empilé (`stacked = TRUE`). Par défaut : `1`. Sans effet en mode
#'   non empilé.
#' @param barWidth largeur des barres. Par défaut = `.8`
#' @param wrapWidth Entier. Nombre de caractères maximum avant retour à la ligne automatique des étiquettes de l'axe des x. Par défaut \code{15}.
#' @param angleThreshold Entier. Nombre d'étiquettes sur l'axe x à partir duquel l'angle est appliqué pour éviter les chevauchements. Par défaut \code{5}.

#'
#' @return Retourne invisiblement une liste de graphiques `ggplot2`, un par
#'   élément de `cols`. Les graphiques sont également sauvegardés dans
#'   `outputDir` avec un nom de fichier structuré comme suit :
#'   `YYYYMMDD_<col>[_by_<groupVars>][_stacked].<fileFormat>`.
#'
#' @details
#' Les valeurs manquantes (`NA`) sont exclues du calcul des pourcentages.
#' Les pourcentages sont calculés au sein de chaque combinaison de
#' `question x groupVars`.
#'
#' En mode empilé (`stacked = TRUE`), l'axe y est normalisé à 100% via
#' `position = "fill"`. Les labels des segments inférieurs à `labelThreshold`
#' ne sont pas affichés afin de préserver la lisibilité.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' library(ggplot2)
#'
#' # Création d'un jeu de données exemple
#' set.seed(42)
#' dtEx <- data.table(
#'   q1 = sample(c("Oui", "Non", "NSP"), 200, replace = TRUE),
#'   q2 = sample(c("Satisfait", "Neutre", "Insatisfait"), 200, replace = TRUE),
#'   region = sample(c("Nord", "Sud"), 200, replace = TRUE),
#'   genre = sample(c("Homme", "Femme"), 200, replace = TRUE)
#' )
#'
#' # Exemple 1 : graphiques simples sans regroupement
#' plotPercentBar(
#'   dt = dtEx,
#'   cols = c("q1", "q2"),
#'   outputDir = "output/graphs"
#' )
#'
#' # Exemple 2 : graphiques avec une variable de regroupement
#' plotPercentBar(
#'   dt = dtEx,
#'   cols = c("q1", "q2"),
#'   outputDir = "output/graphs",
#'   groupVars = "region"
#' )
#'
#' # Exemple 3 : graphiques empilés avec deux variables de regroupement
#' plotPercentBar(
#'   dt = dtEx,
#'   cols = c("q1", "q2"),
#'   outputDir = "output/graphs",
#'   groupVars = c("region", "genre"),
#'   stacked = TRUE,
#'   labelThreshold = 8
#' )
#'
#' # Exemple 4 : avec labels personnalisés et couleurs modifiées
#' plotPercentBar(
#'   dt = dtEx,
#'   cols = "q1",
#'   outputDir = "output/graphs",
#'   valueLabels = c("Oui" = "Oui", "Non" = "Non", "NSP" = "Ne sait pas"),
#'   barColors = c("#F39200", "#E71E73", "#951B81"),
#'   fileFormat = "pdf"
#' )
#' }
#'
#' @importFrom data.table is.data.table melt
#' @importFrom ggplot2 ggplot aes geom_bar geom_text scale_fill_manual
#'   scale_y_continuous facet_wrap facet_grid labs ggsave vars position_fill
#'   waiver
#' @importFrom scales percent
#' @importFrom purrr map
#' @importFrom stringr str_wrap
#'
#' @export
plotPercentBar <- function(
  dt,
  cols,
  outputDir,
  groupVars = NULL,
  valueLabels = NULL,
  legendTitle = NULL,
  barColors = c("#F39200", "#E71E73", "#951B81", "#E84E0F", "#C3004D"),
  fileFormat = "png",
  width = 8,
  height = 5,
  dpi = 300,
  xAxisTitle = NULL,
  yAxisTitle = "Pourcentage (%)",
  wrapWidth = 15, # nb de caractères avant retour à la ligne
  angleThreshold = 5, # nb de modalités avant rotation des labels
  stacked = FALSE,
  labelThreshold = 1,
  barWidth = 0.8
) {
  # --- Vérifications des arguments ---
  stopifnot(
    is.data.table(dt),
    is.character(cols),
    all(cols %in% names(dt)),
    is.character(outputDir),
    is.numeric(width), width > 0,
    is.numeric(height), height > 0,
    is.numeric(dpi), dpi > 0,
    is.logical(stacked), length(stacked) == 1,
    is.numeric(labelThreshold),
    labelThreshold >= 0,
    labelThreshold <= 100
  )

  # Vérification du format de fichier
  validFormats <- c("png", "pdf", "svg", "jpeg", "tiff")
  if (!fileFormat %in% validFormats) {
    stop(sprintf(
      "fileFormat '%s' non supporté. Formats valides : %s",
      fileFormat,
      paste(validFormats, collapse = ", ")
    ))
  }

  # Vérification des variables de regroupement
  if (!is.null(groupVars)) {
    stopifnot(is.character(groupVars))
    if (length(groupVars) > 2) {
      stop("groupVars ne peut pas contenir plus de deux variables de regroupement.")
    }
    if (!all(groupVars %in% names(dt))) {
      stop(sprintf(
        "Les variables de regroupement suivantes sont absentes de dt : %s",
        paste(setdiff(groupVars, names(dt)), collapse = ", ")
      ))
    }
  }

  # Vérification des valueLabels
  if (!is.null(valueLabels)) {
    stopifnot(is.character(valueLabels), !is.null(names(valueLabels)))
  }

  # Création du répertoire de sortie si nécessaire
  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
  }

  valDate <- format(Sys.Date(), "%Y%m%d")

  # --- Préparation des données ---
  keepCols <- unique(c(cols, groupVars))
  dtLong <- melt(
    dt[, ..keepCols],
    id.vars = groupVars,
    measure.vars = cols,
    variable.name = "question",
    value.name = "value"
  )

  # Calcul des pourcentages au sein de chaque combinaison question x groupVars
  byVars <- c("question", groupVars)

  dtPct <- dtLong[
    !is.na(value),
    .(n = .N),
    by = c(byVars, "value")
  ][
    , pct := n / sum(n) * 100,
    by = byVars
  ]

  # Vérification que barColors couvre toutes les modalités
  nModalities <- dtPct[, uniqueN(value)]
  if (length(barColors) < nModalities) {
    warning(sprintf(
      paste0(
        "%d couleurs fournies pour %d modalités. ",
        "Les couleurs seront recyclées, ce qui peut nuire à la lisibilité."
      ),
      length(barColors),
      nModalities
    ))
  }

  # Application des valueLabels si fournis
  if (!is.null(valueLabels)) {
    dtPct[, value := factor(value, levels = names(valueLabels))]
  } else {
    dtPct[, value := factor(value)]
  }
  # Titre de légende : argument legendTitle ou nom de groupVar2 par défaut
  legendTitleLocal <- if (!is.null(legendTitle)) legendTitle else NULL

  # --- Génération des graphiques ---
  graphs <- purrr::map(cols, function(q) {
    dtQ <- dtPct[question == q]

    # Construction du graphique selon le mode empilé ou non
    if (stacked) {
      # En mode empilé : x = groupe primaire (ou axe fixe), fill = modalité
      xVar <- if (!is.null(groupVars)) groupVars[1] else "question"

      p <- ggplot(
        dtQ,
        aes(
          x = if (!is.null(groupVars)) .data[[groupVars[1]]] else q,
          y = pct,
          fill = value
        )
      ) +
        geom_bar(stat = "identity", position = "fill", width = barWidth) +
        # Affichage des labels uniquement si le segment dépasse le seuil
        geom_text(
          data = dtQ[pct >= labelThreshold],
          aes(label = sprintf("%.1f%%", pct)),
          position = position_fill(vjust = 0.5),
          size = 3,
          color = "white"
        ) +
        scale_y_continuous(labels = scales::percent) +
        labs(
          x = if (!is.null(xAxisTitle)) xAxisTitle else xVar,
          y = yAxisTitle,
          fill = NULL
        )
    } else {
      # Mode barres groupées : x = modalité, fill = modalité
      p <- ggplot(
        dtQ,
        aes(x = value, y = pct, fill = value)
      ) +
        geom_bar(stat = "identity", width = barWidth) +
        geom_text(
          aes(label = sprintf("%.1f%%", pct)),
          vjust = -0.5,
          size = 3
        ) +
        labs(
          x = if (!is.null(xAxisTitle)) xAxisTitle else q,
          y = yAxisTitle,
          fill = NULL
        )
    }

    p <- p + theme_minimal()

    # Application des couleurs
    p <- p + scale_fill_manual(
      values = barColors,
      labels = if (!is.null(valueLabels)) valueLabels else waiver(),
      name = legendTitleLocal
    )

    # Application du faceting selon le nombre de variables de groupe
    if (!is.null(groupVars)) {
      if (stacked && length(groupVars) == 2) {
        # En mode empilé, le premier groupe est en x, le second en facet
        p <- p + facet_wrap(vars(.data[[groupVars[2]]]))
      } else if (!stacked) {
        if (length(groupVars) == 1) {
          p <- p + facet_wrap(vars(.data[[groupVars[1]]]))
        } else if (length(groupVars) == 2) {
          p <- p + facet_grid(
            rows = vars(.data[[groupVars[1]]]),
            cols = vars(.data[[groupVars[2]]])
          )
        }
      }
    }

    # ── Gestion du chevauchement des labels sur l'axe x ──────────────────────
    # Détermine la variable affichée en x selon le mode
    xVar <- if (stacked) {
      if (!is.null(groupVars)) groupVars[1] else "question"
    } else {
      "value"
    }

    # Récupère les labels effectifs affichés sur l'axe x
    xLabels <- if (xVar == "value") {
      if (!is.null(valueLabels)) valueLabels else as.character(levels(dtQ$value))
    } else {
      as.character(unique(dtQ[[xVar]]))
    }

    needsWrap <- max(nchar(xLabels)) > wrapWidth
    needsAngle <- length(xLabels) > angleThreshold

    xAngle <- if (needsAngle) 45 else 0
    xHjust <- if (needsAngle) 1 else 0.5

    # Wrap des labels si nécessaire
    if (needsWrap) {
      p <- p + scale_x_discrete(
        labels = \(x) stringr::str_wrap(x, width = wrapWidth)
      )
    }

    # Rotation des labels si nécessaire
    p <- p + theme(
      axis.text.x = element_text(angle = xAngle, hjust = xHjust)
    )


    # Construction du nom de fichier
    groupSuffix <- if (!is.null(groupVars)) {
      paste0("_by_", paste(groupVars, collapse = "_"))
    } else {
      ""
    }

    stackedSuffix <- if (stacked) "_stacked" else ""

    filePath <- file.path(
      outputDir,
      paste0(valDate, "_", q, groupSuffix, stackedSuffix, "_percent.", fileFormat)
    )

    ggsave(
      filename = filePath,
      plot = p,
      width = width,
      height = height,
      dpi = dpi
    )

    p
  })
  invisible(graphs)
}
