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
#' \deqn{Z = \frac{W - n_1 n_2 / 2}{\sqrt{n_1 n_2 (n_1 + n_2 + 1) / 12}}}
#' La taille d'effet retournée est \eqn{r = Z / \sqrt{n_1 + n_2}}, positive
#' si \code{niveau1} présente des valeurs tendanciellement plus élevées que
#' \code{niveau2}, négative dans le cas inverse.
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
#'   \item{n1, n2}{Effectifs non manquants dans \code{niveau1} et
#'     \code{niveau2} respectivement.}
#'   \item{mediane1, mediane2}{Médianes observées dans chaque groupe,
#'     fournies pour vérifier la cohérence du signe de \code{effectSize}.}
#'   \item{pValue}{P-value bilatérale du test de Mann-Whitney.}
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
testerDifferenceBinaire <- function(
  dt,
  cols,
  labels,
  groupVar,
  niveau1,
  niveau2,
  minN = 5
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
    is.character(niveau1), 
    length(niveau1) == 1,
    is.character(niveau2), 
    length(niveau2) == 1,
    is.numeric(minN), 
    minN > 0
  )

  # Chaque colonne à tester doit avoir un libellé correspondant. Sans cette
  # vérification explicite, une colonne sans libellé provoquerait une erreur
  # d'indexation peu compréhensible plus loin dans la fonction (cas
  # notamment rencontré lorsque `labels` provient d'un unlist() sur une
  # liste de listes nommées, qui préfixe les noms silencieusement).
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
    # Découpage de la colonne testée selon les niveaux de groupVar. split()
    # produit une liste nommée par niveau, ce qui permet d'extraire
    # directement les deux sous-vecteurs d'intérêt par leur nom plutôt que
    # par leur position (plus sûr si l'ordre des niveaux varie).
    groupes <- split(dt[[colName]], dt[[groupVar]])

    # Garde défensive : les deux niveaux demandés doivent exister dans les
    # données, et chacun doit compter au moins `minN` observations non
    # manquantes. Si ce n'est pas le cas, on retourne une ligne "vide"
    # plutôt que de laisser wilcox.test() échouer ou produire un résultat
    # instable sur un trop petit échantillon.
    effectifsSuffisants <- all(c(niveau1, niveau2) %in% names(groupes)) &&
      all(sapply(groupes[c(niveau1, niveau2)], function(x) sum(!is.na(x))) >= minN)

    if (!effectifsSuffisants) {
      return(data.table::data.table(
        variable = colName,
        label = labels[[colName]],
        n1 = NA_integer_,
        n2 = NA_integer_,
        mediane1 = NA_real_,
        mediane2 = NA_real_,
        pValue = NA_real_,
        effectSize = NA_real_,
        interpretation = "Effectif insuffisant"
      ))
    }

    x1 <- groupes[[niveau1]]
    x2 <- groupes[[niveau2]]

    # exact = FALSE : nécessaire dès qu'il y a des ex aequo (systématique
    # avec des échelles ordinales de type Likert ou fréquence), sans quoi
    # wilcox.test() émettrait un avertissement à chaque appel.
    testResult <- stats::wilcox.test(x1, x2, exact = FALSE)

    n1 <- sum(!is.na(x1))
    n2 <- sum(!is.na(x2))
    nTotal <- n1 + n2

    # --- Calcul du score Z signé --------------------------------------------
    # La p-value bilatérale de wilcox.test() ne renseigne pas sur le sens
    # de la différence : reconstruire un Z à partir d'elle produirait
    # systématiquement une valeur positive, quel que soit le groupe qui a
    # tendance à présenter les valeurs les plus élevées. On calcule donc le
    # Z directement à partir de la statistique W (test de x1 contre x2),
    # standardisée par rapport à sa moyenne et son écart-type attendus sous
    # l'hypothèse nulle d'absence de différence entre les deux groupes.
    muW <- n1 * n2 / 2
    sigmaW <- sqrt(n1 * n2 * (n1 + n2 + 1) / 12)
    zValue <- (as.numeric(testResult$statistic) - muW) / sigmaW

    # Taille d'effet r, signée : positive si niveau1 tend à avoir des
    # valeurs plus elevees que niveau2, negative dans le cas inverse.
    effectSize <- round(zValue / sqrt(nTotal), 3)

    # Categorisation qualitative de l'ampleur de l'effet (seuils usuels
    # pour une taille d'effet de type r, independants du signe)
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
      mediane1 = stats::median(x1, na.rm = TRUE),
      mediane2 = stats::median(x2, na.rm = TRUE),
      pValue = round(testResult$p.value, 4),
      effectSize = effectSize,
      interpretation = interpretation
    )
  })
}
