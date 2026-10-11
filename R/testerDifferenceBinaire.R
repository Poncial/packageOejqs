#' Tester la différence entre deux groupes pour plusieurs variables ordinales
#'
#' @description
#' Applique un test de Mann-Whitney (Wilcoxon rank-sum) à chacune des
#' variables fournies, afin de comparer deux niveaux d'une variable de
#' regroupement binaire. Retourne, pour chaque variable, la
#' significativité du test ainsi qu'une taille d'effet signée, plus
#' informative que le seul p-value.
#'
#' @param dt Un \code{data.table} contenant les données.
#' @param cols Vecteur de caractères. Noms des colonnes numériques (ou
#'   ordinales recodées en numérique) à tester, une comparaison par colonne.
#' @param labels Vecteur de caractères nommé, associant à chaque nom de
#'   \code{cols} un libellé lisible destiné à l'affichage. Les noms du
#'   vecteur doivent couvrir exactement les valeurs de \code{cols}.
#' @param groupVar Nom de la variable de regroupement (doit comporter
#'   exactement les deux niveaux indiqués par \code{niveau1} et
#'   \code{niveau2}, d'autres niveaux pouvant coexister dans \code{dt} mais
#'   étant alors ignorés).
#' @param niveau1 Chaîne de caractères. Premier niveau de \code{groupVar} à
#'   comparer. Une taille d'effet positive indique que ce niveau présente
#'   des valeurs plus élevées que \code{niveau2}.
#' @param niveau2 Chaîne de caractères. Second niveau de \code{groupVar} à
#'   comparer, servant de référence pour l'interprétation du signe de la
#'   taille d'effet.
#' @param minN Entier. Effectif minimal requis dans chacun des deux groupes
#'   pour qu'un test soit calculé. En dessous de ce seuil, la ligne
#'   correspondante est retournée avec des valeurs manquantes plutôt que
#'   d'exécuter un test statistiquement peu fiable. Par défaut \code{5}.
#' @param minN : Effectif minimal par groupe. En dessous, la ligne est renvoyée avec effectSize = NA et interpretation = "Effectif insuffisant".
#'
#' @details
#' **Calcul de la taille d'effet signée**
#'
#' Le test [stats::wilcox.test()] retourne une p-value bilatérale, qui ne
#' renseigne pas sur le \emph{sens} de la différence entre les deux groupes.
#' Reconstruire un score Z à partir de cette p-value (p.ex. via
#' \code{qnorm(p / 2, lower.tail = FALSE)}) produit systématiquement une
#' valeur positive, quel que soit le sens réel de l'écart ce qui rend
#' toute taille d'effet ainsi calculée trompeuse.
#'
#' Cette fonction évite ce piège en calculant le score Z directement à
#' partir de la statistique W retournée par le test, standardisée par
#' rapport à sa moyenne et son écart-type attendus sous l'hypothèse nulle :
#' \deqn{Z = \frac{W - n_1 n_2 / 2}{\sigma_W}, \quad
#'   \sigma_W = \sqrt{\frac{n_1 n_2}{12}\left[(N + 1) -
#'   \frac{\sum_j (t_j^3 - t_j)}{N (N - 1)}\right]}}
#' où \eqn{N = n_1 + n_2} et \eqn{t_j} est le nombre d'observations ex aequo
#' pour chaque valeur distincte de l'échantillon combiné. Cette correction est
#' celle de [stats::wilcox.test()] : le Z et la p-value reposent sur la même
#' variance. Si \eqn{\sigma_W = 0} (toutes les valeurs identiques), r vaut 0.
#'
#' **Seuils d'interprétation de la taille d'effet** (règle usuelle) :
#' \code{< 0.1} négligeable, \code{< 0.3} faible, \code{< 0.5} modérée,
#' \code{>= 0.5} forte (en valeur absolue).
#'
#' @return
#' Un \code{data.table} avec une ligne par variable testée, contenant :
#' \describe{
#'   \item{variable}{Nom brut de la colonne testée.}
#'   \item{label}{Libellé lisible, issu de \code{labels}.}
#'   \item{n1, n2}{Effectifs non manquants de chaque niveau (renseignés même
#'     si l'effectif est insuffisant pour tester).}
#'   \item{mediane1, mediane2}{Médianes observées dans chaque groupe,
#'     fournies pour vérifier la cohérence du signe de \code{effectSize}.}
#'   \item{pValue}{P-value bilatérale brute (non arrondie), à ajuster
#'     (Holm) par l'appelant si plusieurs tests forment une famille.}
#'   \item{effectSize}{Taille d'effet signée (voir Details). \code{NA} si
#'     l'effectif est insuffisant dans l'un des deux groupes.}
#'   \item{interpretation}{Catégorie qualitative de la taille d'effet, ou
#'     \code{"Effectif insuffisant"} si le test n'a pas pu être calculé.}
#' }
#'
#' @examples
#' library(data.table)
#'
#' set.seed(123)
#' dt <- data.table(
#'   groupe = sample(c("Oui", "Non"), 200, replace = TRUE),
#'   score1 = sample(0:5, 200, replace = TRUE),
#'   score2 = sample(0:5, 200, replace = TRUE)
#' )
#'
#' resultats <- testerDifferenceBinaire(
#'   dt = dt,
#'   cols = c("score1", "score2"),
#'   labels = c(score1 = "Premier score", score2 = "Second score"),
#'   groupVar = "groupe",
#'   niveau1 = "Oui",
#'   niveau2 = "Non"
#' )
#'
#' resultats
#'
#' @seealso [stats::wilcox.test()] pour le test sous-jacent.
#'
#' @export
testerDifferenceBinaire <- function(dt, cols, labels, groupVar, niveau1, niveau2, minN = 5) {
  stopifnot(
    data.table::is.data.table(dt),
    is.character(cols), length(cols) > 0, all(cols %in% names(dt)),
    is.character(labels), !is.null(names(labels)),
    is.character(groupVar), length(groupVar) == 1, groupVar %in% names(dt),
    is.character(niveau1), length(niveau1) == 1,
    is.character(niveau2), length(niveau2) == 1, niveau1 != niveau2,
    is.numeric(minN), minN > 0
  )
  colsManquantes <- setdiff(cols, names(labels))
  if (length(colsManquantes) > 0) {
    stop("Aucun libellé trouvé dans `labels` pour : ", paste(colsManquantes, collapse = ", "))
  }

  groupe <- as.character(dt[[groupVar]])
  # Un niveau jamais observé est presque toujours une faute de frappe
  absents <- setdiff(c(niveau1, niveau2), unique(groupe))
  if (length(absents) > 0) {
    stop("Niveau(x) absent(s) de `", groupVar, "` : ", paste(absents, collapse = ", "),
         ". Niveaux observés : ", paste(sort(unique(groupe)), collapse = ", "))
  }

  lignes <- purrr::map(cols, function(colName) {
    x  <- dt[[colName]]
    x1 <- x[!is.na(x) & !is.na(groupe) & groupe == niveau1]
    x2 <- x[!is.na(x) & !is.na(groupe) & groupe == niveau2]
    n1 <- length(x1)
    n2 <- length(x2)

    if (n1 < minN || n2 < minN) {
      return(data.table::data.table(
        variable = colName, label = labels[[colName]], n1 = n1, n2 = n2,
        mediane1 = NA_real_, mediane2 = NA_real_, pValue = NA_real_,
        effectSize = NA_real_, interpretation = "Effectif insuffisant"
      ))
    }
    nTotal <- n1 + n2
    testResult <- stats::wilcox.test(x1, x2, exact = FALSE)

    # Z signé tiré de W (jamais reconstruit depuis la p-value),
    # variance corrigée des ex aequo comme dans wilcox.test()
    muW <- n1 * n2 / 2
    effectifsEx <- as.numeric(table(c(x1, x2)))
    correctionEx <- sum(effectifsEx^3 - effectifsEx) / (nTotal * (nTotal - 1))
    sigmaW <- sqrt(n1 * n2 / 12 * ((nTotal + 1) - correctionEx))
    zValue <- if (sigmaW > 0) (as.numeric(testResult$statistic) - muW) / sigmaW else 0
    # p bilatérale recalculée depuis W : wilcox.test peut renvoyer 0 pour un grand z positif
    dW <- as.numeric(testResult$statistic) - muW
    pValue <- if (sigmaW > 0 && dW != 0) {
      min(1, 2 * stats::pnorm(-abs((abs(dW) - 0.5) / sigmaW)))
    } else {
      1
    }

    effectSize <- round(zValue / sqrt(nTotal), 3)

    absEffect <- abs(effectSize)
    interpretation <- if (absEffect < 0.1) {
      "Négligeable"
    } else if (absEffect < 0.3) {
      "Faible"
    } else if (absEffect < 0.5) {
      "Modérée"
    } else {
      "Forte"
    }

    data.table::data.table(
      variable = colName,
      label = labels[[colName]],
      n1 = n1,
      n2 = n2,
      mediane1 = stats::median(x1),
      mediane2 = stats::median(x2),
      pValue = pValue,
      effectSize = effectSize,
      interpretation = interpretation
    )
  })
  data.table::rbindlist(lignes)
}

