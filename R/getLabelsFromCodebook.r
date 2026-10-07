#' Extraire un dictionnaire de labels depuis le codebook
#'
#' Source unique de vérité pour les libellés utilisés dans les graphiques et
#' tableaux d'analyse. Évite de retaper des dictionnaires locaux de labels
#' dans chaque script d'analyse.
#'
#' @param codebook data.table avec au moins les colonnes `targetVariable`,
#'   `label`, `labelCourt`.
#' @param cols Vecteur de variables cibles (`targetVariable`) à extraire.
#' @param court Si `TRUE` (défaut), retourne `labelCourt` ; si `FALSE`,
#'   retourne `label` (libellé complet).
#' @return Vecteur caractère nommé par `cols`, dans le même ordre que `cols`.
#' @export
getLabelsFromCodebook <- function(codebook, cols, court = TRUE) {
  colonneLabel <- if (court) "labelCourt" else "label"
  manquants <- setdiff(cols, codebook$targetVariable)
  if (length(manquants) > 0) {
    stop("Variables absentes du codebook : ", paste(manquants, collapse = ", "))
  }
  labelsExtraits <- codebook[
    targetVariable %in% cols,
    setNames(get(colonneLabel), targetVariable)
  ]
  labelsExtraits[cols]
}
