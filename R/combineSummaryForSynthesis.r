#' Combiner un summaryList en une seule table pour un graphique de synthèse
#'
#' @description
#' [summariseItemsByGroup()] retourne une liste de \code{data.table} splittée
#' par item, adaptée à la production d'un graphique distinct par item via
#' [plotGroupedBarCharts()]. Cette fonction réassemble cette liste en une
#' seule table, en substituant aux noms bruts des colonnes sources des
#' libellés lisibles, afin de produire un unique graphique comparant
#' plusieurs items entre eux (l'item devenant lui-même une variable de
#' regroupement).
#'
#' @param summaryList Liste nommée de \code{data.table}, telle que retournée
#'   par [summariseItemsByGroup()]. Chaque élément doit contenir une colonne
#'   \code{item}.
#' @param itemLabels Vecteur de caractères nommé, associant à chaque nom de
#'   \code{summaryList} un libellé court destiné à l'affichage. Les noms du
#'   vecteur doivent couvrir exactement (ou inclure au minimum) tous les
#'   noms de \code{summaryList}.
#'
#' @details
#' Cette fonction ne calcule aucune nouvelle statistique : elle se contente
#' d'empiler (\code{rbindlist}) les tables déjà calculées et de renommer la
#' colonne \code{item} selon \code{itemLabels}. Le résultat est destiné à
#' être passé à [plotGroupedBarCharts()] avec \code{groupVar = "item"} (ou
#' \code{groupVar2 = "item"}), afin de comparer plusieurs items sur un même
#' graphique plutôt que d'en produire un par item.
#'
#' @return
#' Un \code{data.table} unique, structurellement identique à un élément de
#' \code{summaryList}, mais empilant toutes les lignes de tous les items,
#' avec la colonne \code{item} recodée selon \code{itemLabels}.
#'
#' @examples
#' library(data.table)
#'
#' set.seed(42)
#' dt <- data.table(
#'   genre = sample(c("Femme", "Homme"), 100, replace = TRUE),
#'   item1 = sample(1:5, 100, replace = TRUE),
#'   item2 = sample(1:5, 100, replace = TRUE)
#' )
#'
#' summaryList <- summariseItemsByGroup(
#'   dt = dt, varItems = c("item1", "item2"), groupVar = "genre",
#'   includeTotal = FALSE
#' )
#'
#' summarySynthese <- combineSummaryForSynthesis(
#'   summaryList = summaryList,
#'   itemLabels  = c(item1 = "Premier item", item2 = "Second item")
#' )
#'
#' # Utilisation typique en aval :
#' \dontrun{
#' plotGroupedBarCharts(
#'   summaryList = list(synthese = summarySynthese),
#'   groupVar    = "item",
#'   groupVar2   = "genre",
#'   titre       = "Comparaison des deux items",
#'   yLimits     = c(0, 5)
#' )
#' }
#'
#' @seealso [summariseItemsByGroup()] pour générer \code{summaryList},
#'   [plotGroupedBarCharts()] pour visualiser le résultat.
#'
#' @export
combineSummaryForSynthesis <- function(summaryList, itemLabels) {
  stopifnot(
    is.list(summaryList), !is.null(names(summaryList)), length(summaryList) > 0,
    is.character(itemLabels), !is.null(names(itemLabels))
  )
  manquants <- setdiff(names(summaryList), names(itemLabels))
  if (length(manquants) > 0) {
    stop("itemLabels ne couvre pas : ", paste(manquants, collapse = ", "))
  }
  libellesUtilises <- itemLabels[names(summaryList)]
  if (anyDuplicated(unname(libellesUtilises))) {
    stop("Libellés dupliqués dans itemLabels : ",
         paste(unname(libellesUtilises)[duplicated(libellesUtilises)], collapse = ", "))
  }
  sansItem <- names(summaryList)[!vapply(summaryList, \(d) "item" %in% names(d), logical(1))]
  if (length(sansItem) > 0) {
    stop("Pas de colonne 'item' dans : ", paste(sansItem, collapse = ", "),
         ". Sortie de summariseItemsByGroup() attendue.")
  }

  combined <- data.table::rbindlist(summaryList, use.names = TRUE)
  # item devient un facteur ordonné comme summaryList (et non par ordre alphabétique)
  combined[["item"]] <- factor(
    unname(itemLabels[as.character(combined[["item"]])]),
    levels = unname(libellesUtilises)
  )
  combined
}

