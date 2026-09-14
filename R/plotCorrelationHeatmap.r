#' Générer une heatmap de corrélations de Spearman
#'
#' @description
#' Génère et sauvegarde une heatmap représentant une matrice de corrélations,
#' typiquement produite par [computeSpearmanMatrix()]. Les coefficients
#' significatifs (\code{p < .05}) sont marqués d'un astérisque. Le dégradé de
#' couleurs utilise par défaut la charte graphique OEJQS.
#'
#' @param corDt Un \code{data.table} au format long, tel que retourné par
#'   [computeSpearmanMatrix()]. Doit contenir au minimum les colonnes
#'   \code{labelVar1}, \code{labelVar2}, \code{rho} et \code{pValue}.
#' @param titre Chaîne de caractères. Titre principal du graphique. Défaut
#'   \code{NULL} (aucun titre).
#' @param sousTitre Chaîne de caractères. Sous-titre du graphique. Défaut
#'   \code{NULL}.
#' @param sigThreshold Seuil de significativité utilisé pour marquer les
#'   coefficients d'un astérisque. Défaut \code{0.05}.
#' @param lowColor Couleur hexadécimale utilisée pour les corrélations
#'   négatives extrêmes (\code{rho = -1}). Défaut \code{"#951B81"}.
#' @param midColor Couleur hexadécimale utilisée pour une corrélation nulle
#'   (\code{rho = 0}). Défaut \code{"white"}.
#' @param highColor Couleur hexadécimale utilisée pour les corrélations
#'   positives extrêmes (\code{rho = 1}). Défaut \code{"#F39200"}.
#' @param outputPath Chemin complet du fichier de sortie (incluant le nom de
#'   fichier et l'extension, p.ex. \code{".png"}). Le répertoire est créé
#'   automatiquement s'il n'existe pas.
#' @param width Largeur du fichier exporté en pouces. Défaut \code{9}.
#' @param height Hauteur du fichier exporté en pouces. Défaut \code{8}.
#' @param dpi Résolution du fichier exporté en points par pouce. Défaut
#'   \code{300}.
#' @param labelSize Taille du texte affichant les coefficients sur les
#'   tuiles. Défaut \code{2.8}.
#'
#' @details
#' L'ordre d'affichage des variables sur les axes suit l'ordre d'apparition
#' dans \code{corDt} (déterminé par l'ordre de \code{cols} lors de l'appel à
#' [computeSpearmanMatrix()]), et non un tri automatique — ceci permet de
#' contrôler explicitement le regroupement thématique des variables à
#' l'affichage.
#'
#' @return
#' Retourne invisiblement l'objet \code{ggplot} généré. Le graphique est
#' également sauvegardé sur disque à l'emplacement \code{outputPath}.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' set.seed(123)
#' dtEx <- data.table(
#'   reussite   = sample(1:5, 200, replace = TRUE),
#'   stress     = sample(1:5, 200, replace = TRUE),
#'   dependance = sample(1:5, 200, replace = TRUE)
#' )
#'
#' corResult <- computeSpearmanMatrix(
#'   dt     = dtEx,
#'   cols   = c("reussite", "stress", "dependance"),
#'   labels = c("Réussite perçue", "Stress scolaire", "Dépendance smartphone")
#' )
#'
#' plotCorrelationHeatmap(
#'   corDt      = corResult,
#'   titre      = "Corrélations entre réussite, stress et dépendance",
#'   outputPath = tempfile(fileext = ".png")
#' )
#' }
#'
#' @seealso [computeSpearmanMatrix()] pour générer \code{corDt}.
#'
#' @export
plotCorrelationHeatmap <- function(
  corDt,
  titre = NULL,
  sousTitre = NULL,
  sigThreshold = 0.05,
  lowColor = "#951B81",
  midColor = "white",
  highColor = "#F39200",
  outputPath,
  width = 9,
  height = 8,
  dpi = 300,
  labelSize = 2.8
) {

  # Vérifications défensives

  stopifnot(data.table::is.data.table(corDt))

  requiredCols <- c("labelVar1", "labelVar2", "rho", "pValue")
  missingCols <- setdiff(requiredCols, names(corDt))

  if (length(missingCols) > 0) {
    stop(
      "Colonnes manquantes dans corDt : ", paste(missingCols, collapse = ", "),
      ". Utilisez computeSpearmanMatrix() pour générer un objet compatible."
    )
  }

  stopifnot(
    is.character(outputPath),
    length(outputPath) == 1,
    is.numeric(sigThreshold),
    sigThreshold > 0,
    sigThreshold < 1,
    is.numeric(width),
    width > 0,
    is.numeric(height),
    height > 0,
    is.numeric(dpi),
    dpi > 0
  )


  # Création du répertoire de sortie si nécessaire

  outputDir <- dirname(outputPath)
  if (!dir.exists(outputDir)) {
    dir.create(outputDir, recursive = TRUE)
  }


  # Préparation des libellés affichés sur les tuiles : coefficient arrondi, avec astérisque si significatif au seuil sigThreshold

  corDt <- data.table::copy(corDt)

  corDt[, sigLabel := ifelse(
    !is.na(pValue) & pValue < sigThreshold,
    sprintf("%.2f*", rho),
    sprintf("%.2f", rho)
  )]

  # Préservation de l'ordre d'apparition des variables (pas de tri alphabétique automatique par ggplot2)
  levelsOrder <- unique(corDt$labelVar1)

  corDt[, `:=`(
    labelVar1 = factor(labelVar1, levels = levelsOrder),
    labelVar2 = factor(labelVar2, levels = rev(levelsOrder))
  )]

  # Construction du graphique

  p <- ggplot2::ggplot(
    corDt,
    ggplot2::aes(x = labelVar1, y = labelVar2, fill = rho)
  ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(
      ggplot2::aes(label = sigLabel),
      size = labelSize,
      color = "grey20"
    ) +
    ggplot2::scale_fill_gradient2(
      low = lowColor,
      mid = midColor,
      high = highColor,
      midpoint = 0,
      limits = c(-1, 1),
      name = "Rho de\nSpearman"
    ) +
    ggplot2::labs(
      title = titre,
      subtitle = sousTitre,
      x = NULL,
      y = NULL,
      caption = paste0("* p < ", sigThreshold)
    ) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid = ggplot2::element_blank()
    )

  # Sauvegarde

  ggplot2::ggsave(
    filename = outputPath,
    plot = p,
    width = width,
    height = height,
    dpi = dpi
  )

  message("Heatmap de corrélations sauvegardée : ", outputPath)

  invisible(p)
}
