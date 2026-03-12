#' Nettoie des colonnes textuelles dans une data.table avec suivi
#'
#' Applique des opérations de nettoyage sur des colonnes :
#' - remplacement des guillemets typographiques (curly quotes),
#' - suppression des caractères non ASCII,
#' - normalisation des espaces,
#' - suppression des espaces en début/fin.
#'
#' Optionnellement, retourne un log du nombre de valeurs modifiées par colonne.
#' Par défaut, toutes les colonnes character/factor sont nettoyées.
#'
#' @param dt data.table à modifier par référence.
#' @param vecCols vecteur optionnel de colonnes à nettoyer.
#'   Si NULL, toutes les colonnes textuelles sont sélectionnées.
#' @param replaceQuotes logique : activer le remplacement des curly quotes.
#' @param removeNonAscii logique : activer suppression des caractères non ASCII.
#' @param normalizeSpaces logique : activer la normalisation des espaces.
#' @param showLog logique : afficher le nombre de valeurs modifiées par colonne.
#'
#' @return invisible(data.table) modifiée par référence. Si showLog=TRUE, affiche un log.
#' @importFrom textclean replace_curly_quote replace_non_ascii replace_white
#' @importFrom purrr keep map_lgl map
#'
#' @examples
#' library(data.table)
#'
#' # --- Données d'exemple avec cas typiques à nettoyer ---
#' dt <- data.table::data.table(
#'   nom = c("René\u2019s café", "Alice ", "  Bob"),
#'   adresse = c("3\u00e8me   rue", "12\u2018avenue\u2019", NA)
#' )
#'
#' # --- Nettoyage de toutes les colonnes textuelles (comportement par défaut) ---
#' cleanTextCols(dt)
#'
#' # --- Nettoyage d'une sélection de colonnes uniquement ---
#' cleanTextCols(dt, vecCols = "nom")
#'
#' # --- Sans affichage du log ---
#' cleanTextCols(dt, showLog = FALSE)
#'
#' # --- Nettoyage partiel : uniquement normalisation des espaces et trim ---
#' cleanTextCols(
#'   dt,
#'   replaceQuotes = FALSE,
#'   removeNonAscii = FALSE,
#'   normalizeSpaces = TRUE,
#'   showLog = TRUE
#' )
#'
#' # --- Récupération du résultat (modifié par référence) ---
#' dtClean <- cleanTextCols(dt, showLog = FALSE)
#' @export
cleanTextCols <- function(
  dt,
  vecCols = NULL,
  replaceQuotes = TRUE,
  removeNonAscii = TRUE,
  normalizeSpaces = TRUE,
  showLog = TRUE
) {
  stopifnot(data.table::is.data.table(dt))

  # Détection automatique des colonnes textuelles
  textCols <- vecCols %||%
    purrr::keep(
      names(dt),
      purrr::map_lgl(dt, ~ is.character(.x) || is.factor(.x))
    )

  stopifnot(is.character(textCols), all(textCols %in% names(dt)))

  # Sauvegarde de l'état initial pour compter les changements
  oldValues <- dt[, ..textCols]

  # Nettoyage par colonne
  dt[, (textCols) := purrr::map(.SD, function(x) {
    x <- as.character(x)
    if (replaceQuotes) x <- textclean::replace_curly_quote(x)
    if (removeNonAscii) x <- textclean::replace_non_ascii(x)
    if (normalizeSpaces) x <- textclean::replace_white(x)
    trimws(x)
  }), .SDcols = textCols]

  # Comptage des changements
  if (showLog) {
    changes <- purrr::map2_int(
      oldValues,
      dt[, ..textCols],
      ~ sum(.x != .y, na.rm = TRUE)
    )
    logDf <- data.table::data.table(
      column = textCols,
      nChanged = changes
    )
    print(logDf)
  }

  invisible(dt)
}
