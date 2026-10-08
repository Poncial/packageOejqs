#' Récupérer les métadonnées d'affichage d'une variable de regroupement
#'
#' Garantit qu'une modalité a toujours la même couleur et le même ordre
#' d'affichage dans tous les scripts (couleurs associées PAR NOM).
#'
#' @param metaGroupVars Liste nommée (une entrée par variable de regroupement).
#' @param varName Nom de la variable de regroupement.
#' @return Liste contenant `levels`, `colors`, `axisTitle`, `legendTitle`.
#' @export
getGroupVarMeta <- function(metaGroupVars, varName) {
  if (!varName %in% names(metaGroupVars)) {
    stop("Variable de regroupement absente de metaGroupVars : ", varName)
  }
  metaGroupVars[[varName]]
}
