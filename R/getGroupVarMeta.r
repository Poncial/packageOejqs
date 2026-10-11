#' Récupérer les métadonnées d'affichage d'une variable de regroupement
#'
#' Les couleurs sont associées par NOM de modalité, jamais par position.
#'
#' @param metaGroupVars Liste nommée (une entrée par variable de regroupement).
#' @param varName Nom de la variable de regroupement.
#' @return Liste `levels`, `colors` (nommé), `axisTitle`, `legendTitle`.
#' @export
getGroupVarMeta <- function(metaGroupVars, varName) {
  stopifnot(is.list(metaGroupVars), is.character(varName), length(varName) == 1)
  if (!varName %in% names(metaGroupVars)) {
    stop("Variable de regroupement absente de metaGroupVars : ", varName)
  }
  meta <- metaGroupVars[[varName]]
  champs <- c("levels", "colors", "axisTitle", "legendTitle")
  manquants <- setdiff(champs, names(meta))
  if (length(manquants) > 0) {
    stop("metaGroupVars$", varName, " : champs manquants : ", paste(manquants, collapse = ", "))
  }
  if (is.null(names(meta$colors)) || !setequal(names(meta$colors), meta$levels)) {
    stop("metaGroupVars$", varName, " : `colors` doit être nommé et couvrir exactement `levels`.")
  }
  meta
}
