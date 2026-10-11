#' Extraire un dictionnaire de libellés depuis le codebook
#'
#' Source unique des libellés des analyses. Le codebook est « long » (une ligne
#' par modalité) : les lignes sont dédoublonnées par variable cible.
#'
#' @param codebook `data.table` avec `targetVariable`, `label` et `labelCourt`.
#' @param cols Variables cibles à extraire (sans doublon).
#' @param court `TRUE` : `labelCourt`. `FALSE` : `label` complet.
#' @return Vecteur caractère nommé par `cols`, dans l'ordre de `cols`.
#' @export
getLabelsFromCodebook <- function(codebook, cols, court = TRUE) {
  stopifnot(
    data.table::is.data.table(codebook),
    is.character(cols), length(cols) > 0, !anyDuplicated(cols),
    is.logical(court), length(court) == 1
  )
  colonneLabel <- if (court) "labelCourt" else "label"
  if (!colonneLabel %in% names(codebook)) stop("Colonne absente du codebook : ", colonneLabel)

  manquants <- setdiff(cols, codebook$targetVariable)
  if (length(manquants) > 0) {
    stop("Variables absentes du codebook : ", paste(manquants, collapse = ", "))
  }

  dico <- unique(codebook[targetVariable %in% cols, c("targetVariable", colonneLabel), with = FALSE])
  ambigus <- dico[, .N, by = targetVariable][N > 1L, targetVariable]
  if (length(ambigus) > 0) {
    stop("Plusieurs libellés distincts pour : ", paste(ambigus, collapse = ", "))
  }
  vecteur <- stats::setNames(dico[[colonneLabel]], dico$targetVariable)
  invalides <- names(vecteur)[is.na(vecteur) | !nzchar(vecteur)]
  if (length(invalides) > 0) stop("Libellé vide ou NA pour : ", paste(invalides, collapse = ", "))
  vecteur[cols]
}
