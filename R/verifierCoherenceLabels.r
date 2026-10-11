#' Contrôler des libellés locaux contre le codebook
#'
#' Compare chaque libellé local à ceux du codebook (distance de Levenshtein
#' normalisée) et alerte si sa similarité est trop faible, ou si un autre
#' `labelCourt` du codebook lui ressemble nettement plus (décalage de colonne).
#'
#' @param labelsLocaux Vecteur caractère nommé par variable cible.
#' @param codebook `data.table` avec `targetVariable`, `label`, `labelCourt`.
#' @param seuilSimilarite Seuil de similarité (0 à 1). Défaut 0.5.
#' @return `data.table` de diagnostic, invisible.
#' @export
verifierCoherenceLabels <- function(labelsLocaux, codebook, seuilSimilarite = 0.5) {
  stopifnot(
    is.character(labelsLocaux), !is.null(names(labelsLocaux)),
    data.table::is.data.table(codebook),
    is.numeric(seuilSimilarite), seuilSimilarite >= 0, seuilSimilarite <= 1
  )
  dico <- unique(codebook[, c("targetVariable", "label", "labelCourt"), with = FALSE])
  inconnues <- setdiff(names(labelsLocaux), dico$targetVariable)
  if (length(inconnues) > 0) stop("Variables absentes du codebook : ", paste(inconnues, collapse = ", "))

  normaliser <- function(x) stringr::str_squish(stringr::str_to_lower(x))
  similarite <- function(a, b) {
    1 - drop(utils::adist(normaliser(a), normaliser(b))) / max(nchar(a), nchar(b), 1L)
  }
  courts <- unique(dico[, c("targetVariable", "labelCourt"), with = FALSE])

  resultat <- purrr::map(names(labelsLocaux), function(v) {
    local <- labelsLocaux[[v]]
    ref <- dico[targetVariable == v]
    simPropre <- max(vapply(c(ref$label, ref$labelCourt), \(r) similarite(local, r), numeric(1)))
    simCourts <- vapply(courts$labelCourt, \(r) similarite(local, r), numeric(1))
    data.table::data.table(
      variable = v, labelLocal = local, labelCourt = ref$labelCourt[1],
      similarite = round(simPropre, 3),
      meilleureVariable = courts$targetVariable[which.max(simCourts)],
      similariteMeilleure = round(max(simCourts), 3)
    )
  }) |> data.table::rbindlist()

  resultat[, suspect := similarite < seuilSimilarite |
             (meilleureVariable != variable & similariteMeilleure - similarite > 0.2)]
  if (any(resultat$suspect)) {
    warning(
      "Libellés locaux suspects (décalage possible) : ",
      paste(resultat[suspect == TRUE, variable], collapse = ", "), call. = FALSE
    )
  }
  invisible(resultat)
}
