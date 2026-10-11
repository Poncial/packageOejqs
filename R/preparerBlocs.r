#' Valider des blocs d'items et leur associer échelle et bornes d'axe
#'
#' Chaque bloc doit correspondre à une seule famille d'échelle (`scaleFamilies`
#' de `metaRecodage`), et aucune variable ne doit figurer dans deux blocs.
#' Les bornes d'axe sont lues dans le dictionnaire de l'échelle, pas retapées.
#'
#' @param blocs Liste nommée ; chaque élément a `titre` et `cols`.
#' @param scaleFamilies Liste de familles (`family`, `cols`, `prefix`, `dict`, `ancrage`).
#' @param dt `data.table` optionnel : vérifie que les colonnes existent.
#' @return Les blocs, enrichis de `famille`, `yLimits` et `yBreaks`.
#' @export
preparerBlocs <- function(blocs, scaleFamilies, dt = NULL) {
  stopifnot(
    is.list(blocs), length(blocs) > 0, !is.null(names(blocs)),
    is.list(scaleFamilies), length(scaleFamilies) > 0
  )
  toutes <- unlist(lapply(blocs, `[[`, "cols"), use.names = FALSE)
  if (anyDuplicated(toutes)) {
    stop("Variables présentes dans plusieurs blocs : ",
         paste(unique(toutes[duplicated(toutes)]), collapse = ", "))
  }
  if (!is.null(dt)) {
    manquantes <- setdiff(toutes, names(dt))
    if (length(manquantes) > 0) {
      stop("Variables absentes des données : ", paste(manquantes, collapse = ", "))
    }
  }
  trouverFamille <- function(col) {
    hits <- Filter(function(f) col %in% paste0(f$prefix, f$cols), scaleFamilies)
    if (length(hits) != 1L) {
      stop("'", col, "' : ", length(hits), " famille(s) d'échelle trouvée(s) (1 attendue).")
    }
    hits[[1]]
  }
  purrr::imap(blocs, function(bloc, nom) {
    stopifnot(is.character(bloc$cols), length(bloc$cols) > 0, is.character(bloc$titre))
    familles <- vapply(bloc$cols, function(col) trouverFamille(col)$family, character(1))
    if (length(unique(familles)) > 1L) {
      stop("Bloc '", nom, "' : échelles hétérogènes (", paste(unique(familles), collapse = " / "), ")")
    }
    famille <- trouverFamille(bloc$cols[1])
    valides <- famille$dict[!is.na(famille$dict)]
    bloc$famille <- famille
    bloc$yLimits <- range(valides)
    bloc$yBreaks <- seq(min(valides), max(valides))
    bloc
  })
}
