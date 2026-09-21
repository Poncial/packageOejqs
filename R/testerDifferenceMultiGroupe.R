#' Tester la différence entre plusieurs groupes pour plusieurs variables ordinales
#'
#' @description
#' Applique un test de Kruskal-Wallis à chacune des variables fournies, afin
#' de comparer trois groupes ou plus d'une variable de regroupement.
#' Retourne, pour chaque variable, la significativité du test ainsi qu'une
#' taille d'effet epsilon-carré, plus informative que le seul p-value.
#'
#' @param dt Un \code{data.table} contenant les données.
#' @param cols Vecteur de caractères. Noms des colonnes numériques (ou
#'   ordinales recodées en numérique) à tester, une comparaison par colonne.
#' @param labels Vecteur de caractères nommé, associant à chaque nom de
#'   \code{cols} un libellé lisible destiné à l'affichage. Les noms du
#'   vecteur doivent couvrir exactement les valeurs de \code{cols}.
#' @param groupVar Nom de la variable de regroupement. Peut comporter deux
#'   niveaux ou plus ; contrairement à [testerDifferenceBinaire()], aucune
#'   restriction à deux groupes n'est appliquée ici.
#' @param minN Entier. Effectif total minimal (tous groupes confondus,
#'   valeurs non manquantes) requis pour qu'un test soit calculé. Par défaut
#'   \code{10}.
#' @param minGroupes Entier. Nombre minimal de groupes distincts requis dans
#'   \code{groupVar} (après exclusion des valeurs manquantes) pour qu'un
#'   test soit calculé. Par défaut \code{2}.
#'
#' @details
#' **Nature du test**
#'
#' Le test de Kruskal-Wallis est l'équivalent non paramétrique d'une ANOVA à
#' un facteur, adapté aux variables ordinales. Il indique seulement
#' \emph{qu'au moins un groupe diffère significativement des autres}, sans
#' préciser lequel : contrairement à [testerDifferenceBinaire()], aucun
#' signe ni sens de différence n'est calculé ici. Pour identifier quels
#' groupes précisément diffèrent entre eux, des comparaisons post-hoc par
#' paires (p.ex. via [testerDifferenceBinaire()] appliquée à chaque paire
#' de groupes) restent nécessaires en complément.
#'
#' **Calcul de la taille d'effet epsilon-carré**
#'
#' La taille d'effet retournée, epsilon-carré (\eqn{\epsilon^2}), est
#' calculée à partir de la statistique H du test :
#' \deqn{\epsilon^2 = \frac{H - k + 1}{n - k}}
#' où \eqn{H} est la statistique de Kruskal-Wallis, \eqn{k} le nombre de
#' groupes et \eqn{n} l'effectif total non manquant. Cette mesure varie
#' entre 0 et 1 et s'interprète comme la proportion de variance des rangs
#' expliquée par l'appartenance au groupe.
#'
#' **Seuils d'interprétation usuels** : \code{< 0.01} négligeable,
#' \code{< 0.06} faible, \code{< 0.14} modérée, \code{>= 0.14} forte.
#'
#' @return
#' Un \code{data.table} avec une ligne par variable testée, contenant :
#' \describe{
#'   \item{variable}{Nom brut de la colonne testée.}
#'   \item{label}{Libellé lisible, issu de \code{labels}.}
#'   \item{n}{Effectif total non manquant (toutes catégories confondues)
#'     utilisé pour le test.}
#'   \item{kGroupes}{Nombre de groupes distincts comparés.}
#'   \item{pValue}{P-value du test de Kruskal-Wallis.}
#'   \item{epsilonSq}{Taille d'effet epsilon-carré (voir Details). \code{NA}
#'     si l'effectif ou le nombre de groupes est insuffisant.}
#'   \item{interpretation}{Catégorie qualitative de la taille d'effet, ou
#'     \code{"Effectif insuffisant"} si le test n'a pas pu être calculé.}
#' }
#'
#' @examples
#' library(data.table)
#'
#' set.seed(123)
#' dt <- data.table(
#'   groupe = sample(c("Oui", "Non", "Je ne sais pas"), 200, replace = TRUE),
#'   score1 = sample(0:5, 200, replace = TRUE),
#'   score2 = sample(0:5, 200, replace = TRUE)
#' )
#'
#' resultats <- testerDifferenceMultiGroupe(
#'   dt = dt,
#'   cols = c("score1", "score2"),
#'   labels = c(score1 = "Premier score", score2 = "Second score"),
#'   groupVar = "groupe"
#' )
#'
#' resultats
#'
#' @seealso [testerDifferenceBinaire()] pour une comparaison signée entre
#'   deux groupes précis, [stats::kruskal.test()] pour le test sous-jacent.
#'
#' @export
testerDifferenceMultiGroupe <- function(
  dt,
  cols,
  labels,
  groupVar,
  minN = 10,
  minGroupes = 2
) {
  # ---------------------------------------------------------------------------
  # Vérifications défensives
  # ---------------------------------------------------------------------------

  stopifnot(
    data.table::is.data.table(dt),
    is.character(cols), 
    length(cols) > 0,
    all(cols %in% names(dt)),
    is.character(labels), 
    !is.null(names(labels)),
    is.character(groupVar), 
    length(groupVar) == 1,
    groupVar %in% names(dt),
    is.numeric(minN), 
    minN > 0,
    is.numeric(minGroupes), 
    minGroupes >= 2
  )

  # Chaque colonne à tester doit avoir un libellé correspondant (même
  # vérification que dans testerDifferenceBinaire(), pour la même raison :
  # éviter une erreur d'indexation peu explicite si `labels` est mal
  # construit, par exemple issu d'un unlist() ayant préfixé les noms).
  colsManquantes <- setdiff(cols, names(labels))
  if (length(colsManquantes) > 0) {
    stop(
      "Aucun libellé trouvé dans `labels` pour : ",
      paste(colsManquantes, collapse = ", "),
      ". Verifiez la construction du vecteur `labels`."
    )
  }

  # ---------------------------------------------------------------------------
  # Boucle sur chaque variable à tester
  # ---------------------------------------------------------------------------

  purrr::map_dfr(cols, function(colName) {
    # Restriction aux lignes completes sur la variable testee ET la
    # variable de regroupement : kruskal.test() echouerait sinon sur les
    # NA, et on veut un effectif coherent avec ce qui est reellement teste.
    dtComplet <- dt[!is.na(get(colName)) & !is.na(get(groupVar))]

    nTotal <- nrow(dtComplet)
    k <- data.table::uniqueN(dtComplet[[groupVar]])

    # Garde defensive : effectif total et nombre de groupes suffisants.
    # Sans cette verification, kruskal.test() pourrait echouer sur un
    # groupe vide ou produire une statistique instable sur un trop petit
    # echantillon.
    if (nTotal < minN || k < minGroupes) {
      return(data.table::data.table(
        variable = colName,
        label = labels[[colName]],
        n = nTotal,
        kGroupes = k,
        pValue = NA_real_,
        epsilonSq = NA_real_,
        interpretation = "Effectif insuffisant"
      ))
    }

    testResult <- stats::kruskal.test(dtComplet[[colName]], dtComplet[[groupVar]])

    # --- Calcul de la taille d'effet epsilon-carre --------------------------
    # epsilon^2 = (H - k + 1) / (n - k), ou H est la statistique du test,
    # k le nombre de groupes et n l'effectif total. Cette mesure s'interprete
    # comme la proportion de variance des rangs expliquee par le groupe,
    # et reste comparable entre variables independamment du nombre de
    # groupes compares (contrairement a H seul, qui depend de k).
    epsilonSq <- round(
      as.numeric((testResult$statistic - k + 1) / (nTotal - k)), 3
    )

    # Categorisation qualitative de l'ampleur de l'effet (seuils usuels
    # pour epsilon-carre)
    interpretation <- if (epsilonSq < 0.01) {
      "Négligeable"
    } else if (epsilonSq < 0.06) {
      "Faible"
    } else if (epsilonSq < 0.14) {
      "Modérée"
    } else {
      "Forte"
    }

    data.table::data.table(
      variable = colName,
      label = labels[[colName]],
      n = nTotal,
      kGroupes = k,
      pValue = round(testResult$p.value, 4),
      epsilonSq = epsilonSq,
      interpretation = interpretation
    )
  })
}
