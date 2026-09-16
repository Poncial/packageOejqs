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
#'   \code{"se"} (défaut), \code{"sd"}, \code{"ci"} ou \code{"iqr"}.
#' @param flipAxes Booléen. Si \code{TRUE}, inverse les axes X et Y via
#'   \code{coord_flip()} et affiche les étiquettes de valeur et d'effectif
#'   directement sur les barres. Défaut : \code{FALSE}.
#' @param titre \[optionnel\] Titre principal affiché sur chaque graphique.
#'   Accepte soit une chaîne unique (appliquée à tous les items), soit un
#'   vecteur nommé (un titre par item, les noms devant correspondre à ceux
#'   de \code{summaryList}). Si un item n'a pas de titre correspondant dans
#'   le vecteur nommé, un avertissement est émis et aucun titre n'est affiché
#'   pour cet item.
#' @param sousTitre \[optionnel\] Sous-titre affiché sous le titre principal.
#' @param titreAxeX Titre de l'axe des X. Défaut : \code{"Groupes"}.
#' @param titreAxeY Titre de l'axe des Y. Défaut : \code{"Valeur"}.
#' @param yLimits \[optionnel\] Vecteur numérique de longueur 2 définissant les
#'   limites de l'axe des valeurs, p.ex. \code{c(0, 6)}. Utilise
#'   \code{coord_cartesian()} (ou \code{coord_flip(ylim = ...)}) pour zoomer
#'   sans supprimer de données. Si \code{NULL}, les limites sont calculées
#'   automatiquement.
#' @param yBreaks \[optionnel\] Vecteur numérique indiquant les graduations
#'   exactes de l'axe des valeurs (p.ex. \code{0:6}). Si \code{NULL}
#'   (défaut), \code{ggplot2} choisit l'espacement automatiquement.
#' @param xBreaks \[optionnel\] Vecteur indiquant les graduations ou
#'   modalités à afficher sur l'axe des groupes (\code{groupVar}). Utile
#'   lorsque \code{groupVar} est numérique et que l'espacement automatique ne
#'   convient pas. Sans effet notable si \code{groupVar} est déjà discret et
#'   que toutes les modalités doivent être affichées.
#' @param xLabels \[optionnel\] Vecteur de caractères de même longueur que
#'   \code{xBreaks}, pour personnaliser les étiquettes correspondantes.
#'   Ignoré si \code{xBreaks = NULL}.
#' @param reverseXOrder Booléen. Si \code{TRUE}, inverse l'ordre d'affichage
#'   des modalités de \code{groupVar}. Pour une variable numérique, l'échelle
#'   est inversée (\code{trans = "reverse"}). Pour une variable discrète,
#'   l'ordre d'affichage est inversé sans modifier les données sources.
#'   Particulièrement utile avec \code{flipAxes = TRUE}. Défaut : \code{FALSE}.
#' @param outputSubfolder Sous-dossier de destination dans
#'   \code{03_outputFiles/01_graphiques/}. Défaut : \code{"01_Eleves"}.
#' @param width Largeur du fichier PNG en pouces. Défaut : \code{7}.
#' @param height Hauteur du fichier PNG en pouces. Défaut : \code{5}.
#' @param dpi Résolution du fichier PNG en points par pouce. Défaut : \code{300}.
#'
#' @return
#' Retourne invisiblement une liste nommée d'objets \code{ggplot}, un par
#' item. Les graphiques sont également sauvegardés sur disque dans
#' \code{03_outputFiles/01_graphiques/<outputSubfolder>/}, sous le nom
#' \code{YYYYMMDD_<typeQuestion>_<groupVar>[_<groupVar2>]_<statType>_<item>.png}.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' set.seed(42)
#' dt <- data.table(
#'   genre  = sample(c("Femme", "Homme"), 120, replace = TRUE),
#'   modele = sample(c("A", "B", "C"), 120, replace = TRUE),
#'   item1  = sample(1:5, 120, replace = TRUE),
#'   item2  = sample(1:5, 120, replace = TRUE)
#' )
#'
#' summaryList <- summariseItemsByGroup(
#'   dt = dt, varItems = c("item1", "item2"), groupVar = "genre",
#'   includeTotal = TRUE
#' )
#'
#' # Graphique simple
#' plotGroupedBarCharts(
#'   summaryList = summaryList, groupVar = "genre",
#'   titre = "Résultats par genre", yLimits = c(0, 5), yBreaks = 0:5
#' )
#'
#' # Titres distincts par item, via vecteur nommé
#' plotGroupedBarCharts(
#'   summaryList = summaryList, groupVar = "genre",
#'   titre = c(item1 = "Résultat item 1", item2 = "Résultat item 2")
#' )
#'
#' # Barres horizontales, ordre inversé, graduations exactes
#' plotGroupedBarCharts(
#'   summaryList = summaryList, groupVar = "genre",
#'   flipAxes = TRUE, reverseXOrder = TRUE,
#'   yLimits = c(0, 5), yBreaks = 0:5
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
    yBreaks = NULL,
    xBreaks = NULL,
    xLabels = NULL,
    reverseXOrder = FALSE,
    outputSubfolder = "01_Eleves",
    width = 7,
    height = 5,
    dpi = 300
) {

  # ===========================================================================
  # 1. VALIDATION DES ARGUMENTS
  # ===========================================================================
  # Toutes les vérifications sont regroupées ici, en tout début de fonction,
  # pour échouer rapidement et clairement plutôt qu'au milieu du traçage.

  stopifnot(
    is.list(summaryList),
    is.character(groupVar), length(groupVar) == 1,
    statType %in% c("mean", "median"),
    errorType %in% c("se", "sd", "iqr", "ci"),
    is.logical(flipAxes), length(flipAxes) == 1,
    is.logical(reverseXOrder), length(reverseXOrder) == 1
  )

  if (!is.null(groupVar2)) {
    stopifnot(is.character(groupVar2), length(groupVar2) == 1)
  }
  if (!is.null(yLimits)) {
    stopifnot(is.numeric(yLimits), length(yLimits) == 2)
  }
  if (!is.null(yBreaks)) {
    stopifnot(is.numeric(yBreaks))
  }
  if (!is.null(xBreaks) && !is.null(xLabels)) {
    stopifnot(length(xBreaks) == length(xLabels))
  }

  # ===========================================================================
  # 2. FONCTIONS INTERNES
  # ===========================================================================
  # Ces fonctions ne sont utilisées qu'à l'intérieur de plotGroupedBarCharts().
  # Les isoler ici évite de dupliquer la même logique à plusieurs endroits
  # du corps principal, ce qui était la source de complexité de l'ancienne
  # version (blocs CAS 1 / CAS 2 quasi identiques, quatre blocs de geom_text).

  # --- 2.1 Résolution du titre pour un item donné ----------------------------
  # `titre` peut être une chaîne unique (appliquée à tous les items) ou un
  # vecteur nommé (un titre différent par item).
  resoudreTitre <- function(titre, itemName) {
    if (is.null(titre)) {
      return(NULL)
    }
    if (!is.null(names(titre))) {
      if (itemName %in% names(titre)) {
        return(titre[[itemName]])
      }
      warning(
        "Aucun titre défini pour l'item '", itemName, "' dans le vecteur ",
        "nommé fourni à `titre`. Graphique produit sans titre pour cet item."
      )
      return(NULL)
    }
    titre
  }

  # --- 2.2 Construction d'une palette de couleurs nommée ---------------------
  # Utilisée aussi bien pour un seul groupe (gris uniforme par défaut) que
  # pour deux groupes (palette hue_pal par défaut), selon `useHueParDefaut`.
  construirePalette <- function(valeurs, barColors, useHueParDefaut) {
    valeursUniques <- unique(valeurs)
    if (!is.null(barColors)) {
      stats::setNames(
        rep(barColors, length.out = length(valeursUniques)), valeursUniques
      )
    } else if (useHueParDefaut) {
      stats::setNames(scales::hue_pal()(length(valeursUniques)), valeursUniques)
    } else {
      stats::setNames(rep("#9D9D9D", length(valeursUniques)), valeursUniques)
    }
  }

  # --- 2.3 Ajout des étiquettes de valeur et d'effectif sur les barres -------
  # Regroupe en un seul endroit les quatre variantes (flip x groupVar2) qui
  # étaient auparavant dupliquées dans le corps de la fonction.
  ajouterEtiquettes <- function(p, statType, groupVar2, barWidth, flipAxes) {

    positionEtiquette <- if (!is.null(groupVar2)) {
      ggplot2::position_dodge(width = barWidth)
    } else {
      "identity"
    }

    # Selon l'orientation du graphique, l'alignement du texte (hjust/vjust)
    # et la position par rapport à la barre diffèrent.
    if (isTRUE(flipAxes)) {
      alignementValeur <- list(hjust = 2)      # à l'intérieur de la barre
      alignementN       <- list(hjust = -0.4)   # à l'extérieur de la barre
    } else {
      alignementValeur <- list(vjust = 3)       # à l'intérieur de la barre
      alignementN       <- list(vjust = -4)      # au-dessus de la barre
    }

    aesValeur <- if (is.null(groupVar2)) {
      ggplot2::aes(label = round(.data[[statType]], 2))
    } else {
      ggplot2::aes(label = round(.data[[statType]], 2), group = .data[[groupVar2]])
    }
    aesN <- if (is.null(groupVar2)) {
      ggplot2::aes(label = paste0("N = ", n))
    } else {
      ggplot2::aes(label = paste0("N = ", n), group = .data[[groupVar2]])
    }

    p +
      do.call(ggplot2::geom_text, c(
        list(mapping = aesValeur, size = 3, color = "white", position = positionEtiquette),
        alignementValeur
      )) +
      do.call(ggplot2::geom_text, c(
        list(mapping = aesN, size = if (isTRUE(flipAxes)) 3 else 2, position = positionEtiquette),
        alignementN
      ))
  }

  # ===========================================================================
  # 3. PRÉPARATION DU RÉPERTOIRE DE SORTIE
  # ===========================================================================

  outputDir <- file.path("03_outputFiles/01_graphiques", outputSubfolder)
  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
  }

  # ===========================================================================
  # 4. BOUCLE PRINCIPALE : UN GRAPHIQUE PAR ITEM
  # ===========================================================================
  # Une boucle for classique est utilisée ici plutôt que purrr::imap() : la
  # fonction produit des effets de bord (sauvegarde de fichiers) pour chaque
  # item, ce qu'une boucle explicite rend plus simple à suivre qu'un map().

  nomsItems <- names(summaryList)
  plotList <- vector("list", length(nomsItems))
  names(plotList) <- nomsItems

  for (itemName in nomsItems) {

    dataPlot <- summaryList[[itemName]]

    # --- 4.1 Détermination de la variable de remplissage des barres ---------
    # Avec un seul groupe, les barres sont remplies selon groupVar lui-même
    # (une couleur par modalité). Avec deux groupes, elles sont remplies
    # selon groupVar2, et groupVar reste sur l'axe des x.
    fillVar <- if (is.null(groupVar2)) groupVar else groupVar2

    barColorsLocal <- construirePalette(
      dataPlot[[fillVar]], barColors, useHueParDefaut = !is.null(groupVar2)
    )

    legendTitleLocal <- if (is.null(groupVar2)) {
      NULL
    } else if (!is.null(legendTitle)) {
      legendTitle
    } else {
      groupVar2
    }

    positionBarres <- if (is.null(groupVar2)) {
      "identity"
    } else {
      ggplot2::position_dodge(width = barWidth)
    }

    # --- 4.2 Construction du graphique de base -------------------------------
    p <- ggplot2::ggplot(
      dataPlot,
      ggplot2::aes(
        x = .data[[groupVar]],
        y = .data[[statType]],
        fill = factor(.data[[fillVar]])
      )
    ) +
      ggplot2::geom_col(width = barWidth, position = positionBarres) +
      ggplot2::geom_errorbar(
        ggplot2::aes(
          ymin = .data[[statType]] - .data[[errorType]],
          ymax = .data[[statType]] + .data[[errorType]]
        ),
        width = errorBarWidth,
        position = positionBarres
      ) +
      ggplot2::scale_fill_manual(values = barColorsLocal, name = legendTitleLocal) +
      ggplot2::labs(
        title = resoudreTitre(titre, itemName),
        subtitle = sousTitre,
        x = titreAxeX,
        y = titreAxeY
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = if (is.null(groupVar2)) "none" else "right")

    # --- 4.3 Étiquettes de valeur et d'effectif sur les barres --------------
    p <- ajouterEtiquettes(p, statType, groupVar2, barWidth, flipAxes)

    # --- 4.4 Graduations exactes de l'axe des valeurs (yBreaks) -------------
    if (!is.null(yBreaks)) {
      p <- p + ggplot2::scale_y_continuous(breaks = yBreaks)
    }

    # --- 4.5 Graduations, étiquettes et ordre de l'axe des groupes ----------
    # Le traitement diffère selon que groupVar est numérique (p.ex. un
    # niveau scolaire codé 1 à 7) ou discret (facteur/caractère).
    axeGroupeEstNumerique <- is.numeric(dataPlot[[groupVar]])

    if (axeGroupeEstNumerique) {
      if (!is.null(xBreaks) || isTRUE(reverseXOrder)) {
        p <- p + ggplot2::scale_x_continuous(
          breaks = xBreaks,
          labels = xLabels %||% ggplot2::waiver(),   # <-- correction
          trans  = if (isTRUE(reverseXOrder)) "reverse" else "identity"
        )
      }
    } else {
      if (!is.null(xBreaks) || isTRUE(reverseXOrder)) {
        ordreParDefaut <- if (is.factor(dataPlot[[groupVar]])) {
          levels(dataPlot[[groupVar]])
        } else {
          sort(unique(as.character(dataPlot[[groupVar]])))
        }
        p <- p + ggplot2::scale_x_discrete(
          breaks = xBreaks,
          labels = xLabels %||% ggplot2::waiver(),   # <-- correction
          limits = if (isTRUE(reverseXOrder)) rev(ordreParDefaut) else NULL
        )
      }
    }

    # --- 4.6 Limites de l'axe des valeurs et inversion des axes -------------
    # coord_flip()/coord_cartesian() sont utilisés plutôt que
    # scale_y_continuous(limits = ...), afin de ne jamais supprimer de
    # données lors du zoom (voir section Details de la documentation).
    if (isTRUE(flipAxes)) {
      p <- p + if (!is.null(yLimits)) {
        ggplot2::coord_flip(ylim = yLimits)
      } else {
        ggplot2::coord_flip()
      }
    } else if (!is.null(yLimits)) {
      p <- p + ggplot2::coord_cartesian(ylim = yLimits)
    }

    # --- 4.7 Construction du nom de fichier et sauvegarde -------------------
    fileNameParts <- c(
      format(Sys.Date(), "%Y%m%d"),
      typeQuestion,
      groupVar,
      groupVar2,
      statType,
      itemName
    )
    fileName <- file.path(
      outputDir,
      paste0(paste(fileNameParts[!is.null(fileNameParts) & !is.na(fileNameParts)], collapse = "_"), ".png")
    )

    ggplot2::ggsave(filename = fileName, plot = p, width = width, height = height, dpi = dpi)

    plotList[[itemName]] <- p
  }

  invisible(plotList)
}
