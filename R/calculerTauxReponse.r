#' Taux de réponse par répondant, sur les items effectivement affichés
#'
#' Un item est une liste : `id`, `cols` (répondu si AU MOINS UNE colonne est
#' non NA, ce qui couvre les choix multiples), et optionnellement
#' `condition = list(refCols, mode, refValue)` :
#' * `"selected"` : affiché si l'unique `refCols` est dans `refValue` (NA = non affiché) ;
#' * `"notSelected"` : affiché si AU MOINS UNE `refCols` n'est pas dans
#'   `refValue` (NA = affiché, comme Qualtrics pour « n'est pas sélectionné »).
#' L'ancien format `conditionCol` + `conditionValues` (équivalent à `"selected"`)
#' est accepté. Un item non affiché n'entre ni au numérateur ni au dénominateur.
#'
#' @param dt `data.table` aux colonnes brutes (NA = non répondu).
#' @param itemsSpec Liste de listes décrivant les items.
#' @return `data.table` de `nrow(dt)` lignes : `nItemsAffiches`, `nItemsRepondus`,
#'   `tauxReponse` (NA si aucun item affiché).
#' @importFrom data.table %chin%
#' @importFrom data.table fifelse
#' @export
calculerTauxReponse <- function(dt, itemsSpec) {
  stopifnot(data.table::is.data.table(dt), is.list(itemsSpec), length(itemsSpec) > 0)
  ids <- vapply(itemsSpec, \(it) it$id, character(1))
  stopifnot("Identifiants d'items dupliqués" = !anyDuplicated(ids))

  normaliserCondition <- function(it) {
    if (!is.null(it$condition)) return(it$condition)
    if (!is.null(it$conditionCol)) {
      return(list(refCols = it$conditionCol, mode = "selected", refValue = it$conditionValues))
    }
    NULL
  }
  conditions <- lapply(itemsSpec, normaliserCondition)

  colsUtilisees <- unique(c(
    unlist(lapply(itemsSpec, \(it) it$cols)),
    unlist(lapply(conditions, \(cd) cd$refCols))
  ))
  manquantes <- setdiff(colsUtilisees, names(dt))
  if (length(manquantes) > 0) {
    stop("Colonnes absentes : ", paste(manquantes, collapse = ", "))
  }

  nLignes <- nrow(dt)
  estAffichee <- function(cd) {
    if (is.null(cd)) return(rep(TRUE, nLignes))
    stopifnot(cd$mode %in% c("selected", "notSelected"))
    if (cd$mode == "selected") {
      stopifnot("mode 'selected' : une seule colonne de référence" = length(cd$refCols) == 1L)
      as.character(dt[[cd$refCols]]) %chin% cd$refValue
    } else {
      Reduce(`|`, lapply(cd$refCols, \(r) !(as.character(dt[[r]]) %chin% cd$refValue)))
    }
  }

  nAffiches <- integer(nLignes)
  nRepondus <- integer(nLignes)
  for (i in seq_along(itemsSpec)) {
    affiche <- estAffichee(conditions[[i]])
    repondu <- Reduce(`|`, lapply(itemsSpec[[i]]$cols, \(col) !is.na(dt[[col]])))
    nAffiches <- nAffiches + as.integer(affiche)
    nRepondus <- nRepondus + as.integer(affiche & repondu)
  }
  data.table::data.table(
    nItemsAffiches = nAffiches,
    nItemsRepondus = nRepondus,
    tauxReponse    = fifelse(nAffiches > 0, nRepondus / nAffiches, NA_real_)
  )
}
