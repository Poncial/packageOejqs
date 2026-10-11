#' Notes de lecture du codebook pour une liste de variables
#'
#' @param codebook `data.table` avec `targetVariable` et `noteLecture`.
#' @param cols Variables cibles (sans doublon).
#' @return Vecteur caractère nommé par variable, dans l'ordre de `cols`,
#'   limité aux variables qui ont une note (vecteur vide si aucune).
#' @export
getNotesLecture <- function(codebook, cols) {
  stopifnot(
    data.table::is.data.table(codebook), "noteLecture" %in% names(codebook),
    is.character(cols), length(cols) > 0, !anyDuplicated(cols)
  )
  manquants <- setdiff(cols, codebook$targetVariable)
  if (length(manquants) > 0) {
    stop("Variables absentes du codebook : ", paste(manquants, collapse = ", "))
  }
  notes <- unique(codebook[
    targetVariable %in% cols & !is.na(noteLecture) & nzchar(noteLecture),
    c("targetVariable", "noteLecture"), with = FALSE
  ])
  if (anyDuplicated(notes$targetVariable)) {
    stop("Plusieurs notes de lecture pour : ",
         paste(unique(notes$targetVariable[duplicated(notes$targetVariable)]), collapse = ", "))
  }
  vecteur <- stats::setNames(as.character(notes$noteLecture), notes$targetVariable)
  vecteur[intersect(cols, names(vecteur))]
}
