#' Calculer une matrice de corrélations de Spearman entre plusieurs variables
#'
#' @description
#' Calcule les coefficients de corrélation de Spearman (et leurs p-values
#' associées) pour toutes les paires possibles d'un ensemble de colonnes
#' numériques d'un \code{data.table}. Adaptée aux variables ordinales
#' (échelles de Likert recodées, fréquences, durées), pour lesquelles une
#' corrélation de Pearson serait inappropriée.
#'
#' Le résultat est retourné au format long, directement exploitable par
#' [plotCorrelationHeatmap()] ou par toute autre fonction de visualisation.
#'
#' @param dt Un \code{data.table} contenant les données sources.
#' @param cols Vecteur de caractères. Noms des colonnes numériques entre
#'   lesquelles calculer les corrélations. Toutes les colonnes doivent être
#'   convertibles en numérique via \code{as.numeric()} (facteurs ordonnés
#'   acceptés, mais convertis selon leur rang de niveau).
#' @param labels Vecteur de caractères de même longueur que \code{cols},
#'   utilisé comme libellés d'affichage. Si \code{NULL} (défaut), les noms
#'   de colonnes de \code{cols} sont utilisés tels quels.
#' @param minPairwiseN Entier. Nombre minimal d'observations complètes
#'   (paires non manquantes) requis pour calculer une corrélation entre deux
#'   variables. En dessous de ce seuil, le coefficient est retourné comme
#'   \code{NA} plutôt que de risquer une estimation instable. Par défaut
#'   \code{3}.
#'
#' @details
#' Toutes les paires de variables sont calculées, y compris la diagonale
#' (corrélation d'une variable avec elle-même, qui vaut toujours 1 avec
#' \code{n} égal à l'effectif non manquant de la variable). Ceci permet de
#' construire directement une matrice carrée complète pour une heatmap,
#' sans étape de complétion supplémentaire.
#'
#' Le test de significativité utilise \code{stats::cor.test(method =
#' "spearman", exact = FALSE)}, l'option \code{exact = FALSE} étant
#' nécessaire dès qu'il y a des ex aequo (valeurs répétées), ce qui est
#' quasi systématique avec des échelles de Likert ou de fréquence.
#'
#' @return
#' Un \code{data.table} au format long, avec une ligne par paire de
#' variables (y compris la diagonale), contenant :
#' \describe{
#'   \item{var1, var2}{Noms bruts des colonnes (tels que fournis dans
#'     \code{cols}).}
#'   \item{labelVar1, labelVar2}{Libellés d'affichage (issus de
#'     \code{labels}, ou identiques à \code{var1}/\code{var2} si
#'     \code{labels = NULL}).}
#'   \item{rho}{Coefficient de corrélation de Spearman. \code{NA} si moins
#'     de \code{minPairwiseN} observations complètes sont disponibles.}
#'   \item{pValue}{P-value du test de corrélation. \code{NA} dans les mêmes
#'     conditions que \code{rho}.}
#'   \item{n}{Nombre d'observations complètes utilisées pour le calcul.}
#' }
#'
#' @examples
#' library(data.table)
#'
#' set.seed(123)
#' dtEx <- data.table(
#'   reussite   = sample(1:5, 200, replace = TRUE),
#'   stress     = sample(1:5, 200, replace = TRUE),
#'   dependance = sample(1:5, 200, replace = TRUE)
#' )
#'
#' resultatCor <- computeSpearmanMatrix(
#'   dt     = dtEx,
#'   cols   = c("reussite", "stress", "dependance"),
#'   labels = c("Réussite perçue", "Stress scolaire", "Dépendance smartphone")
#' )
#'
#' resultatCor
#'
#' @seealso [plotCorrelationHeatmap()] pour visualiser le résultat sous
#'   forme de heatmap.
#'
#' @export
computeSpearmanMatrix <- function(
  dt,
  cols,
  labels = NULL,
  minPairwiseN = 3
) {
  # Vérifications défensives


  stopifnot(
    data.table::is.data.table(dt),
    is.character(cols),
    length(cols) >= 2,
    all(cols %in% names(dt)),
    is.numeric(minPairwiseN),
    minPairwiseN >= 2
  )

  if (is.null(labels)) {
    labels <- cols
  }

  stopifnot(
    is.character(labels),
    length(labels) == length(cols)
  )

  # chaque colonne doit être convertible en numérique (numeric, integer, ou facteur ordonné/non ordonné dont le rang de niveau est utilisé comme valeur)
  nonConvertible <- purrr::keep(cols, function(colName) {
    x <- dt[[colName]]
    !(is.numeric(x) || is.factor(x))
  })

  if (length(nonConvertible) > 0) {
    stop(
      "Colonnes non convertibles en numérique (ni numeric, ni factor) : ",
      paste(nonConvertible, collapse = ", ")
    )
  }


  # Construction de toutes les paires de variables (y compris diagonale)

  pairsGrid <- expand.grid(
    var1 = cols,
    var2 = cols,
    stringsAsFactors = FALSE
  )


  # Calcul de la corrélation et de la p-value pour chaque paire


  corResults <- purrr::pmap_dfr(pairsGrid, function(var1, var2) {
    x <- as.numeric(dt[[var1]])
    y <- as.numeric(dt[[var2]])

    completeN <- sum(stats::complete.cases(x, y))

    # Si trop peu d'observations complètes, on retourne NA plutôt que de risquer une estimation instable ou une erreur de cor.test()
    if (completeN < minPairwiseN) {
      return(data.table::data.table(
        var1 = var1,
        var2 = var2,
        rho = NA_real_,
        pValue = NA_real_,
        n = completeN
      ))
    }

    # exact = FALSE : nécessaire en présence d'ex aequo (quasi systématique
    # avec des échelles ordinales de type Likert ou fréquence)
    testResult <- suppressWarnings(
      stats::cor.test(x, y, method = "spearman", exact = FALSE)
    )

    data.table::data.table(
      var1   = var1,
      var2   = var2,
      rho    = unname(testResult$estimate),
      pValue = testResult$p.value,
      n      = completeN
    )
  })


  # Application des libellés d'affichage

  labelMap <- stats::setNames(labels, cols)

  corResults[, `:=`(
    labelVar1 = labelMap[var1],
    labelVar2 = labelMap[var2]
  )]

  data.table::setcolorder(
    corResults,
    c(
      "var1",
      "var2",
      "labelVar1",
      "labelVar2",
      "rho",
      "pValue",
      "n"
      )
  )

  corResults
}
