#' Calculer des statistiques descriptives par groupe pour des items numériques
#'
#' Cette fonction calcule des mesures de tendance centrale et de dispersion
#' pour plusieurs items de questionnaire (Likert, échelles de fréquence ou
#' réponses codées numériquement), regroupés par une variable de groupe
#' spécifiée (par exemple : genre, tranche d'âge, condition expérimentale).
#'
#' Il est possible de calculer également les statistiques pour l'ensemble
#' de l'échantillon ("total") et d'obtenir les résultats sous forme de liste
#' de tables par item, pratique pour la visualisation.
#'
#' @param dt Un \code{data.table} contenant les données.
#'
#' @param varItems Vecteur de caractères indiquant les noms des colonnes
#'   correspondant aux items à résumer (Likert, ordinal, fréquence, ou MCQ codé numériquement).
#'
#' @param groupVar Nom de la variable de regroupement (ex : \code{"genre"}, \code{"ageGroup"}, \code{"modele"}).
#'
#' @param groupVar2 Nom de la variable de regroupement secondaire
#'
#' @param includeTotal Booléen. Indique si un résumé global sur tous les groupes
#'   doit être calculé. Par défaut \code{TRUE}.
#'
#' @param totalLabel Nom utilisé pour le groupe global si \code{includeTotal = TRUE}.
#'   Par défaut \code{"all"}.
#'
#' @param ciLevel Niveau de confiance pour l'intervalle de confiance (par défaut 0.95).
#'
#' @param sdMultiplier Multiplicateur appliqué à l'écart-type (utile pour les graphiques, par défaut 1).
#'
#' @param reorderLevels Vecteur de caractères indiquant l'ordre des niveaux du facteur
#'   du groupe. Si \code{NULL}, l'ordre est conservé tel quel.
#'
#' @param reorderLevels2 Vecteur de caractères indiquant l'ordre des niveaux du facteur
#'   du groupe 2. Si \code{NULL}, l'ordre est conservé tel quel.
#'
#' @return
#' Une liste nommée de \code{data.table}, une table par item. Chaque table contient :
#' \itemize{
#'   \item \code{item} : nom de l'item
#'   \item la variable de groupe (ex : \code{modele}, \code{genre})
#'   \item \code{mean} : moyenne
#'   \item \code{sd} : écart-type (multiplié par \code{sdMultiplier})
#'   \item \code{se} : erreur standard
#'   \item \code{ci} : demi-largeur de l'intervalle de confiance
#'   \item \code{median} : médiane
#'   \item \code{iqr} : étendue interquartile
#'   \item \code{n} : nombre d'observations non manquantes
#' }
#'
#' @details
#' Toutes les statistiques sont calculées en supprimant les valeurs manquantes
#' de manière pairwise. L'intervalle de confiance repose sur l'approximation
#' normale :
#' \deqn{z_{1-\alpha/2} \times \frac{sd}{\sqrt{n}}}
#' où \eqn{z} dépend du niveau de confiance \code{ciLevel}.
#'
#' Cette fonction est adaptée pour les items **ordinaux ou numériques**.
#' Pour des variables purement nominales (MCQ), il est préférable de calculer
#' des proportions avec une fonction dédiée.
#'
#' @examples
#' library(data.table)
#' library(forcats)
#'
#' # Exemple simulé
#' set.seed(123)
#' dtExemple <- data.table(
#'   genre = rep(c("Homme", "Femme"), each = 5),
#'   ageGroup = rep(c("10-12", "13-15"), times = 5),
#'   Q1 = sample(1:5, 10, replace = TRUE),
#'   Q2 = sample(1:5, 10, replace = TRUE)
#' )
#'
#' # Calcul par genre
#' resGenre <- summariseItemsByGroup(
#'   dt = dtExemple,
#'   varItems = c("Q1", "Q2"),
#'   groupVar = "genre",
#'   includeTotal = TRUE,
#'   totalLabel = "Tous",
#'   ciLevel = 0.95
#' )
#'
#' # Accéder au résumé pour Q1
#' resGenre$Q1
#'
#' @export

summariseItemsByGroup <- function(
  dt,
  varItems,
  groupVar,
  groupVar2 = NULL,
  includeTotal = TRUE,
  totalLabel = "all",
  ciLevel = 0.95,
  sdMultiplier = 1,
  reorderLevels = NULL,
  reorderLevels2 = NULL
) {
  stopifnot(is.data.table(dt))
  stopifnot(all(varItems %in% names(dt)))
  stopifnot(groupVar %in% names(dt))

  ## Valider groupVar2 si fourni
  if (!is.null(groupVar2)) {
    stopifnot(is.character(groupVar2))
    stopifnot(groupVar2 %in% names(dt))

    ## S'assurer que groupVar et groupVar2 sont différents
    if (groupVar == groupVar2) {
      stop("groupVar et groupVar2 doivent être différents")
    }
  }

  ## Vérifier que les items sont numériques
  nonNumeric <- varItems[!vapply(dt[, ..varItems], is.numeric, logical(1))]
  if (length(nonNumeric)) {
    stop(
      "Les variables suivantes ne sont pas numériques: ",
      paste(nonNumeric, collapse = ", ")
    )
  }

  # Construire le vecteur de variables à sélectionner
  groupVars <- if (!is.null(groupVar2)) {
    c(groupVar, groupVar2)
  } else {
    groupVar
  }

  selectedVar <- c(groupVars, varItems)
  dtSelected <- dt[, ..selectedVar]


  ## Long format
  dtLong <- melt(
    dtSelected,
    id.vars = groupVars,
    variable.name = "item",
    value.name = "value"
  )

  z <- qnorm(1 - (1 - ciLevel) / 2)

  summaryFun <- function(x) {
    n <- sum(!is.na(x))
    sdVal <- sd(x, na.rm = TRUE)

    list(
      mean = mean(x, na.rm = TRUE),
      sd = sdVal * sdMultiplier,
      se = sdVal / sqrt(n),
      ci = z * sdVal / sqrt(n),
      median = as.numeric(median(x, na.rm = TRUE)),
      iqr = IQR(x, na.rm = TRUE),
      n = n
    )
  }

  ## Par groupe
  dtByGroup <- dtLong[
    ,
    summaryFun(value),
    by = c(groupVars, "item")
  ]

  ## Total
  if (includeTotal) {
    if (!is.null(groupVar2)) {
      # Cas avec deux variables de groupe : total = toutes combinaisons confondues
      dtAll <- dtLong[
        ,
        c(
          summaryFun(value),
          list(tmp1 = totalLabel, tmp2 = totalLabel)
        ),
        by = "item"
      ]

      setnames(dtAll, c("tmp1", "tmp2"), groupVars)
    } else {
      # Cas avec une seule variable de groupe (comportement original)
      dtAll <- dtLong[
        ,
        c(summaryFun(value), list(tmp = totalLabel)),
        by = "item"
      ]

      setnames(dtAll, "tmp", groupVar)
    }

    dtOut <- rbindlist(list(dtByGroup, dtAll), use.names = TRUE)
  } else {
    dtOut <- dtByGroup
  }

  ## Transformer en lowerCamelCase
  names(dtOut) <- snakecase::to_lower_camel_case(names(dtOut))

  ## Relevel si demandé
  if (!is.null(reorderLevels)) {
    dtOut[[groupVar]] <- forcats::fct_relevel(
      factor(dtOut[[groupVar]]),
      reorderLevels
    )
  }
  ## Relevel si demandé pour groupVar2
  if (!is.null(groupVar2) && !is.null(reorderLevels2)) {
    dtOut[[groupVar2]] <- forcats::fct_relevel(
      factor(dtOut[[groupVar2]]),
      reorderLevels2
    )
  }

  ## Split pour visualisation
  split(dtOut, dtOut$item)
}
