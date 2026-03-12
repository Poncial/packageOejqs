#' Recode des colonnes Likert en numériques et vérifie les correspondances
#'
#' Cette fonction recode plusieurs colonnes d'un \code{data.table}
#' contenant des réponses Likert (ou textuelles) en variables numériques
#' selon un vecteur de recodage nommé.
#'
#' De nouvelles colonnes sont créées avec un préfixe donné.
#' La fonction effectue ensuite une vérification globale et détaillée
#' afin d'identifier les valeurs non recodées, et peut écrire un journal
#' d'exécution.
#'
#' @param dt Un \code{data.table} modifié par référence.
#'
#' @param colonnesSource Vecteur de caractères indiquant les colonnes
#'   à recoder.
#'
#' @param recod Vecteur nommé indiquant le mapping
#'   \code{label -> valeur numérique}.
#'
#' @param prefix Préfixe ajouté aux colonnes recodées.
#'
#' @param verbose Logique. Affiche les audits et résumés.
#'
#' @param stopOnIncoherence Logique. Si \code{TRUE}, stoppe l'exécution
#'   lorsqu'au moins une valeur non recodée est détectée.
#'
#' @param allowOverwrite Logique. Autorise l'écrasement de colonnes
#'   existantes.
#'
#' @param naValues Valeurs à forcer en \code{NA} avant recodage.
#'
#' @param logFile Chemin vers un fichier texte de journalisation.
#'
#' @details
#' Toute valeur non présente dans \code{recod} sera transformée en
#' \code{NA} dans la colonne recodée et signalée lors de la vérification.
#'
#' Le recodage repose sur une conversion préalable en caractères
#' pour supporter facteurs et chaînes.
#'
#' @return
#' Une liste invisible contenant :
#' \describe{
#'   \item{createdColumns}{Colonnes numériques créées.}
#'   \item{audit}{Liste d'audits par colonne.}
#'   \item{summary}{Table récapitulative NA source / cible.}
#'   \item{nIncoherences}{Nombre total de valeurs non recodées.}
#'   \item{logFile}{Chemin du log si utilisé.}
#' }
#'
#' @examples
#' library(data.table)
#'
#' dt <- data.table(
#'   Q1 = c("Pas du tout", "Plutôt non", "Plutôt oui"),
#'   Q2 = c("Oui", "Non", "Oui")
#' )
#'
#' recod <- c(
#'   "Pas du tout" = 1,
#'   "Plutôt non" = 2,
#'   "Plutôt oui" = 3,
#'   "Oui" = 1,
#'   "Non" = 0
#' )
#'
#' recodeNumeric(
#'   dt,
#'   colonnesSource = c("Q1", "Q2"),
#'   recod = recod,
#'   verbose = TRUE
#' )
#'
#' @export

recodeNumeric <- function(
  dt,
  colonnesSource,
  recod,
  prefix = "num_",
  verbose = TRUE,
  stopOnIncoherence = FALSE,
  allowOverwrite = FALSE,
  naValues = NULL,
  logFile = NULL
) {
  # ------------------------------------------------------------------
  # Vérifications de base
  # ------------------------------------------------------------------

  stopifnot(
    data.table::is.data.table(dt),
    is.character(colonnesSource),
    all(colonnesSource %in% names(dt)),
    is.vector(recod),
    !is.null(names(recod))
  )

  colonnesDest <- paste0(prefix, colonnesSource)

  # Empêche l'écrasement accidentel
  if (!allowOverwrite && any(colonnesDest %in% names(dt))) {
    stop(
      "Certaines colonnes cibles existent déjà : ",
      paste(colonnesDest[colonnesDest %in% names(dt)], collapse = ", ")
    )
  }

  # ------------------------------------------------------------------
  # Logging
  # ------------------------------------------------------------------

  logMsg <- function(...) {
    txt <- paste0(
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      " | ",
      paste(..., collapse = "")
    )
    if (!is.null(logFile)) {
      cat(txt, file = logFile, append = TRUE, sep = "\n")
    }
    if (verbose) message(txt)
  }

  logMsg("Début recodage numérique.")

  # ------------------------------------------------------------------
  # Forçage optionnel de certaines valeurs en NA
  # ------------------------------------------------------------------

  if (!is.null(naValues)) {
    logMsg(
      "Forçage en NA des valeurs suivantes : ",
      paste(naValues, collapse = ", ")
    )

    dt[, (colonnesSource) :=
      lapply(.SD, function(x) {
        x[x %in% naValues] <- NA
        x
      }),
    .SDcols = colonnesSource
    ]
  }

  # ------------------------------------------------------------------
  # Recodage principal via vecteur nommé
  # ------------------------------------------------------------------
  #
  # Chaque valeur est convertie en caractère pour être indexée
  # dans le vecteur `recod` (noms = labels, valeurs = numériques).

  dt[, (colonnesDest) :=
    lapply(.SD, function(x) recod[as.character(x)]),
  .SDcols = colonnesSource
  ]

  logMsg(
    "Colonnes numériques créées : ",
    paste(colonnesDest, collapse = ", ")
  )

  # ------------------------------------------------------------------
  # Vérification globale vectorisée
  # ------------------------------------------------------------------

  incoherenceGlobale <- dt[, Reduce(
    `|`,
    Map(
      function(src, dest) {
        !is.na(get(src)) & is.na(get(dest))
      },
      colonnesSource,
      colonnesDest
    )
  )]

  nIncoherences <- sum(incoherenceGlobale)

  logMsg("Nombre total de valeurs non recodées : ", nIncoherences)

  # ------------------------------------------------------------------
  # Audit détaillé colonne par colonne
  # ------------------------------------------------------------------

  audit <- vector("list", length(colonnesSource))
  names(audit) <- colonnesSource

  for (i in seq_along(colonnesSource)) {
    src <- colonnesSource[i]
    dest <- colonnesDest[i]

    correspondances <- unique(dt[, .(get(src), get(dest))])
    data.table::setnames(correspondances, c("Source", "Destination"))
    data.table::setorder(correspondances, Source)

    badVals <- correspondances[
      is.na(Destination) & !is.na(Source),
      Source
    ]

    audit[[src]] <- list(
      correspondances = correspondances,
      nonRecoded = badVals
    )

    if (verbose) {
      message("Correspondances pour ", src, " → ", dest)
      print(correspondances)

      if (length(badVals) > 0) {
        message("⚠ Valeurs non recodées : ", paste(badVals, collapse = ", "))
      }

      cat("\n")
    }
  }

  # ------------------------------------------------------------------
  # Résumé quantitatif final
  # ------------------------------------------------------------------

  summary <- data.table::data.table(
    colonneSource = colonnesSource,
    colonneNumerique = colonnesDest,
    nSourceNA = sapply(colonnesSource, function(x) sum(is.na(dt[[x]]))),
    nTargetNA = sapply(colonnesDest, function(x) sum(is.na(dt[[x]])))
  )

  if (verbose) {
    message("Résumé global :")
    print(summary)
  }

  if (stopOnIncoherence && nIncoherences > 0) {
    stop(
      nIncoherences,
      " valeurs non recodées détectées."
    )
  }

  logMsg("Fin du recodage numérique.")

  invisible(list(
    createdColumns = colonnesDest,
    audit = audit,
    summary = summary,
    nIncoherences = nIncoherences,
    logFile = logFile
  ))
}
