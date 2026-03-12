#' Créer et sauvegarder des graphiques en barres groupés
#'
#' @description
#' Génère un graphique en barres pour chaque item d'une liste de résumés
#' statistiques, puis sauvegarde automatiquement chaque graphique au format PNG.
#'
#' Cette fonction est conçue pour fonctionner avec les sorties de
#' [summariseItemsByGroup()], mais accepte toute liste de \code{data.table}
#' contenant au minimum une colonne de groupe, une colonne de statistique
#' centrale (\code{mean} ou \code{median}) et une colonne d'erreur
#' (\code{se}, \code{sd}, \code{ci} ou \code{iqr}).
#'
#' @param summaryList Liste nommée de \code{data.table}, un élément par item.
#'   Typiquement produite par [summariseItemsByGroup()].
#' @param typeQuestion \[optionnel\] Chaîne de caractères indiquant le type de
#'   question (p.ex. \code{"Likert"}, \code{"frequence"}). Utilisée uniquement
#'   dans le nom du fichier PNG sauvegardé. Si \code{NULL}, cet élément est
#'   omis du nom de fichier.
#' @param groupVar Nom de la variable de regroupement principale, représentée
#'   sur l'axe X (ou Y si \code{flipAxes = TRUE}).
#' @param groupVar2 \[optionnel\] Nom de la seconde variable de regroupement,
#'   représentée via le remplissage des barres et la légende. Si \code{NULL},
#'   un seul groupe est affiché.
#' @param legendTitle \[optionnel\] Titre personnalisé pour la légende de
#'   \code{groupVar2}. Si \code{NULL}, le nom de \code{groupVar2} est utilisé.
#'   Ignoré si \code{groupVar2 = NULL}.
#' @param barColors \[optionnel\] Vecteur de couleurs hexadécimales, une par
#'   niveau de groupe. Si \code{NULL}, utilise \code{"#9D9D9D"} pour un seul
#'   groupe ou la palette \code{scales::hue_pal()} pour deux groupes.
#' @param barWidth Largeur des barres, entre 0 et 1. Défaut : \code{0.8}.
#' @param errorBarWidth Largeur des barres d'erreur. Défaut : \code{0.2}.
#' @param statType Statistique centrale affichée sur les barres. Valeurs
#'   acceptées : \code{"mean"} (défaut) ou \code{"median"}.
#' @param errorType Type de barre d'erreur. Valeurs acceptées :
#'   \itemize{
#'     \item \code{"se"} : erreur standard (défaut)
#'     \item \code{"sd"} : écart-type
#'     \item \code{"ci"} : intervalle de confiance
#'     \item \code{"iqr"} : étendue interquartile
#'   }
#' @param flipAxes Booléen. Si \code{TRUE}, inverse les axes X et Y via
#'   \code{coord_flip()} et affiche les étiquettes de valeur et d'effectif
#'   directement sur les barres. Défaut : \code{FALSE}.
#' @param titre \[optionnel\] Titre principal affiché sur chaque graphique.
#' @param sousTitre \[optionnel\] Sous-titre affiché sous le titre principal.
#' @param titreAxeX Titre de l'axe des X. Défaut : \code{"Groupes"}.
#' @param titreAxeY Titre de l'axe des Y. Défaut : \code{"Valeur"}.
#' @param yLimits \[optionnel\] Vecteur numérique de longueur 2 définissant les
#'   limites de l'axe des valeurs, p.ex. \code{c(0, 6)}. Utilise
#'   \code{coord_cartesian()} pour zoomer sans supprimer de données. Si
#'   \code{NULL}, les limites sont calculées automatiquement.
#' @param outputSubfolder Sous-dossier de destination dans
#'   \code{03_outputFiles/01_graphiques/}. Défaut : \code{"01_Eleves"}.
#' @param width Largeur du fichier PNG en pouces. Défaut : \code{7}.
#' @param height Hauteur du fichier PNG en pouces. Défaut : \code{5}.
#' @param dpi Résolution du fichier PNG en points par pouce. Défaut : \code{300}.
#'
#' @return
#' Retourne invisiblement une liste nommée d'objets \code{ggplot}, un par item.
#' Les graphiques sont également sauvegardés automatiquement sur disque
#' (voir section *Fichiers générés*).
#'
#' @section Fichiers générés:
#' Les graphiques sont sauvegardés dans :
#' \preformatted{
#' 03_outputFiles/01_graphiques/<outputSubfolder>/
#' }
#' Les noms de fichiers suivent le format :
#' \preformatted{
#' YYYYMMDD_<typeQuestion>_<groupVar>[_<groupVar2>]_<statType>_<item>.png
#' }
#' Par exemple :
#' \preformatted{
#' 20250101_Likert_genre_moyenne_item1.png
#' 20250101_Likert_genre_modele_moyenne_item1.png
#' }
#'
#' @section Gestion des axes:
#' Les limites de l'axe des valeurs sont toujours gérées via
#' \code{coord_cartesian()} (ou \code{coord_flip(ylim = ...)}), ce qui
#' garantit qu'aucune donnée n'est supprimée lors du zoom, contrairement à
#' \code{scale_y_continuous(limits = ...)}.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' # --- Données fictives ---
#' set.seed(42)
#' dt <- data.table(
#'   genre  = sample(c("Femme", "Homme"), 120, replace = TRUE),
#'   modele = sample(c("A", "B", "C"), 120, replace = TRUE),
#'   item1  = sample(1:5, 120, replace = TRUE),
#'   item2  = sample(1:5, 120, replace = TRUE)
#' )
#'
#' # --- Calcul des statistiques descriptives ---
#' summaryList <- summariseItemsByGroup(
#'   dt           = dt,
#'   varItems     = c("item1", "item2"),
#'   groupVar     = "genre",
#'   includeTotal = TRUE
#' )
#'
#' # --- Exemple 1 : graphique simple, un seul groupe ---
#' plotGroupedBarCharts(
#'   summaryList = summaryList,
#'   groupVar    = "genre",
#'   titre       = "Résultats par genre",
#'   titreAxeY   = "Moyenne (échelle 1-5)",
#'   yLimits     = c(0, 5)
#' )
#'
#' # --- Exemple 2 : deux variables de groupe ---
#' summaryList2 <- summariseItemsByGroup(
#'   dt           = dt,
#'   varItems     = c("item1", "item2"),
#'   groupVar     = "genre",
#'   groupVar2    = "modele",
#'   includeTotal = FALSE
#' )
#'
#' plotGroupedBarCharts(
#'   summaryList  = summaryList2,
#'   groupVar     = "genre",
#'   groupVar2    = "modele",
#'   legendTitle  = "Modèle pédagogique",
#'   barColors    = c("#F39200", "#951B81", "#662483"),
#'   titre        = "Résultats par genre et modèle",
#'   yLimits      = c(0, 5)
#' )
#'
#' # --- Exemple 3 : barres horizontales avec étiquettes ---
#' plotGroupedBarCharts(
#'   summaryList = summaryList,
#'   groupVar = "genre",
#'   typeQuestion = "Likert",
#'   flipAxes = TRUE,
#'   statType = "median",
#'   errorType = "iqr",
#'   titre = "Médiane par genre",
#'   titreAxeX = "Genre",
#'   titreAxeY = "Médiane",
#'   yLimits = c(0, 5),
#'   outputSubfolder = "02_Enseignants",
#'   width = 9,
#'   height = 6
#' )
#' }
#'
#' @seealso [summariseItemsByGroup()] pour générer \code{summaryList}.
#'
#' @export
plotGroupedBarCharts <- function(
  summaryList,
  typeQuestion = NULL,
  groupVar,
  groupVar2 = NULL,
  legendTitle = NULL,
  barColors = NULL,
  barWidth = 0.8,
  errorBarWidth = 0.2,
  statType = "mean",
  errorType = "se",
  flipAxes = FALSE,
  titre = NULL,
  sousTitre = NULL,
  titreAxeX = "Groupes",
  titreAxeY = "Valeur",
  yLimits = NULL,
  outputSubfolder = "01_Eleves",
  width = 7,
  height = 5,
  dpi = 300
) {
  # ---------------------------------------------------------------------------
  # Validation des arguments
  # ---------------------------------------------------------------------------
  stopifnot(is.list(summaryList))
  stopifnot(is.character(groupVar), length(groupVar) == 1)
  stopifnot(statType %in% c("mean", "median"))
  stopifnot(errorType %in% c("se", "sd", "iqr", "ci"))
  stopifnot(is.logical(inversionAxe), length(inversionAxe) == 1)

  if (!is.null(groupVar2)) {
    stopifnot(is.character(groupVar2), length(groupVar2) == 1)
  }

  if (!is.null(yLimits)) {
    stopifnot(is.numeric(yLimits), length(yLimits) == 2)
  }

  # ---------------------------------------------------------------------------
  # Création du répertoire de sortie si nécessaire
  # ---------------------------------------------------------------------------
  outputDir <- file.path("03_outputFiles/01_graphiques", outputSubfolder)

  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
  }

  # ---------------------------------------------------------------------------
  # Boucle sur chaque item de la liste via purrr::imap
  # ---------------------------------------------------------------------------
  plotList <- purrr::imap(summaryList, function(dataPlot, itemName) {
    # -------------------------------------------------------------------------
    # CAS 1 : Une seule variable de groupement
    # -------------------------------------------------------------------------
    if (is.null(groupVar2)) {
      # Palette de couleurs : gris uniforme par défaut
      uniqueGroups <- unique(dataPlot[[groupVar]])
      barColorsLocal <- if (is.null(barColors)) {
        stats::setNames(rep("#9D9D9D", length(uniqueGroups)), uniqueGroups)
      } else {
        stats::setNames(
          rep(barColors, length.out = length(uniqueGroups)),
          uniqueGroups
        )
      }

      p <- ggplot2::ggplot(
        dataPlot,
        ggplot2::aes(
          x = .data[[groupVar]],
          y = .data[[statType]],
          fill = .data[[groupVar]]
        )
      ) +
        ggplot2::geom_col(
          width    = barWidth,
          position = "dodge"
        ) +
        ggplot2::geom_errorbar(
          ggplot2::aes(
            ymin = .data[[statType]] - .data[[errorType]],
            ymax = .data[[statType]] + .data[[errorType]]
          ),
          width = errorBarWidth,
          position = ggplot2::position_dodge(width = barWidth)
        ) +
        ggplot2::scale_fill_manual(values = barColorsLocal) +
        ggplot2::labs(
          title = titre,
          subtitle = sousTitre,
          x = titreAxeX,
          y = titreAxeY
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(legend.position = "none")

      # -------------------------------------------------------------------------
      # CAS 2 : Deux variables de groupement (groupVar2 dans la légende)
      # -------------------------------------------------------------------------
    } else {
      # Palette de couleurs : hue_pal par défaut pour distinguer les groupes
      uniqueGroups2 <- unique(dataPlot[[groupVar2]])
      barColorsLocal <- if (is.null(barColors)) {
        stats::setNames(
          scales::hue_pal()(length(uniqueGroups2)),
          uniqueGroups2
        )
      } else {
        stats::setNames(
          rep(barColors, length.out = length(uniqueGroups2)),
          uniqueGroups2
        )
      }

      # Titre de légende : argument legendTitle ou nom de groupVar2 par défaut
      legendTitleLocal <- if (!is.null(legendTitle)) legendTitle else groupVar2

      p <- ggplot2::ggplot(
        dataPlot,
        ggplot2::aes(
          x = .data[[groupVar]],
          y = .data[[statType]],
          fill = .data[[groupVar2]]
        )
      ) +
        ggplot2::geom_col(
          width = barWidth,
          position = ggplot2::position_dodge(width = barWidth)
        ) +
        ggplot2::geom_errorbar(
          ggplot2::aes(
            ymin = .data[[statType]] - .data[[errorType]],
            ymax = .data[[statType]] + .data[[errorType]]
          ),
          width = errorBarWidth,
          position = ggplot2::position_dodge(width = barWidth)
        ) +
        ggplot2::scale_fill_manual(
          values = barColorsLocal,
          name = legendTitleLocal
        ) +
        ggplot2::labs(
          title = titre,
          subtitle = sousTitre,
          x = titreAxeX,
          y = titreAxeY
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(legend.position = "right")
    }

    # -------------------------------------------------------------------------
    # Gestion de l'axe Y et de l'inversion des axes
    # -------------------------------------------------------------------------
    if (isTRUE(inversionAxe)) {
      # Inversion des axes avec zoom optionnel
      p <- p + if (!is.null(yLimits)) {
        ggplot2::coord_flip(ylim = yLimits)
      } else {
        ggplot2::coord_flip()
      }

      # Étiquettes pour barres HORIZONTALES (après flip) : hjust contrôle
      # le positionnement gauche/droite à l'intérieur et à l'extérieur
      if (is.null(groupVar2)) {
        p <- p +
          ggplot2::geom_text(
            ggplot2::aes(label = round(.data[[statType]], 2)),
            hjust = 2, # À l'intérieur de la barre
            size = 3,
            color = "white"
          ) +
          ggplot2::geom_text(
            ggplot2::aes(label = paste0("N = ", n)),
            hjust = -0.4, # À l'extérieur de la barre
            size = 3
          )
      } else {
        p <- p +
          ggplot2::geom_text(
            ggplot2::aes(
              label = round(.data[[statType]], 2),
              group = .data[[groupVar2]]
            ),
            hjust = 2,
            size = 3,
            color = "white",
            position = ggplot2::position_dodge(width = barWidth)
          ) +
          ggplot2::geom_text(
            ggplot2::aes(
              label = paste0("N = ", n),
              group = .data[[groupVar2]]
            ),
            hjust = -0.4,
            size = 3,
            position = ggplot2::position_dodge(width = barWidth)
          )
      }
    } else {
      # Sans inversion : coord_cartesian pour fixer l'échelle Y si demandé
      if (!is.null(yLimits)) {
        p <- p + ggplot2::coord_cartesian(ylim = yLimits)
      }

      # Étiquettes pour barres VERTICALES : vjust contrôle le positionnement
      # haut/bas à l'intérieur et au-dessus de la barre
      if (is.null(groupVar2)) {
        p <- p +
          ggplot2::geom_text(
            ggplot2::aes(label = round(.data[[statType]], 2)),
            vjust = 3, # À l'intérieur de la barre (vers le bas)
            size = 3,
            color = "white"
          ) +
          ggplot2::geom_text(
            ggplot2::aes(label = paste0("N = ", n)),
            vjust = -4, # Au-dessus de la barre
            size = 2
          )
      } else {
        p <- p +
          ggplot2::geom_text(
            ggplot2::aes(
              label = round(.data[[statType]], 2),
              group = .data[[groupVar2]]
            ),
            vjust = 3,
            size = 3,
            color = "white",
            position = ggplot2::position_dodge(width = barWidth)
          ) +
          ggplot2::geom_text(
            ggplot2::aes(
              label = paste0("N = ", n),
              group = .data[[groupVar2]]
            ),
            vjust = -4,
            size = 2,
            position = ggplot2::position_dodge(width = barWidth)
          )
      }
    }


    # -------------------------------------------------------------------------
    # Construction du nom de fichier
    # -------------------------------------------------------------------------
    fileNameParts <- c(
      format(Sys.Date(), "%Y%m%d"), # Date du jour
      typeQuestion, # Type de question (peut être NULL)
      groupVar, # Variable principale
      groupVar2, # Seconde variable (peut être NULL)
      statType, # Statistique utilisée
      itemName # Nom de l'item
    )

    # Suppression des éléments NULL/NA avant de coller
    fileName <- file.path(
      outputDir,
      paste(fileNameParts[!is.null(fileNameParts) & !is.na(fileNameParts)],
        collapse = "_"
      ) |>
        paste0(".png")
    )

    # -------------------------------------------------------------------------
    # Sauvegarde du graphique
    # -------------------------------------------------------------------------
    ggplot2::ggsave(
      filename = fileName,
      plot = p,
      width = width,
      height = height,
      dpi = dpi
    )

    return(p)
  })

  # Retour invisible de la liste de graphiques
  invisible(plotList)
}
