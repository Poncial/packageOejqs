#' Recode des colonnes Qualtrics en binaire et vérifie la cohérence
#'
#' Cette fonction recode, par référence, plusieurs colonnes d'un
#' \code{data.table} issues de Qualtrics en variables binaires indiquant
#' la présence (1) ou l'absence (0) de valeur.
#'
#' Le recodage suit la règle :
#' \itemize{
#'   \item valeur non manquante (\code{!is.na()}) → 1
#'   \item valeur manquante (\code{NA}) → 0
#' }
#'
#' Avant le recodage, certaines valeurs peuvent être forcées en \code{NA}
#' via l'argument \code{naValues}.
#' La fonction réalise ensuite une vérification globale et détaillée
#' colonne par colonne, et peut écrire un journal d'exécution dans un
#' fichier externe.
#'
#' @param dt Un \code{data.table}. Il est modifié par référence.
#'
#' @param colonnesSource Un vecteur de caractères contenant les noms des
#'   colonnes à recoder.
#'
#' @param prefix Chaîne de caractères ajoutée devant les noms des colonnes
#'   sources pour créer les colonnes binaires. Par défaut \code{"bin_"}.
#'
#' @param verbose Logique. Si \code{TRUE} (défaut), affiche les
#'   correspondances et le résumé final dans la console.
#'
#' @param stopOnIncoherence Logique. Si \code{TRUE}, la fonction interrompt
#'   l'exécution lorsqu'au moins une incohérence est détectée.
#'
#' @param allowOverwrite Logique. Si \code{FALSE} (défaut), la fonction
#'   s'arrête si une colonne cible existe déjà.
#'
#' @param naValues Vecteur de valeurs à considérer comme manquantes et à
#'   convertir en \code{NA} avant recodage (par exemple \code{""},
#'   \code{"-99"}, \code{999}).
#'
#' @param logFile Chemin vers un fichier texte dans lequel les messages
#'   d'exécution seront écrits. Si \code{NULL} (défaut), aucun fichier
#'   n'est créé.
#'
#' @details
#' Le recodage repose uniquement sur la détection des valeurs manquantes.
#' Toute valeur non \code{NA} (y compris 0, chaînes vides si non listées
#' dans \code{naValues}, ou codes textuels) sera transformée en 1.
#'
#' Les colonnes binaires sont ajoutées directement à \code{dt}.
#'
#' La vérification comprend :
#' \itemize{
#'   \item un test global vectorisé sur l'ensemble des lignes ;
#'   \item des tables de correspondance Source/Destination uniques ;
#'   \item un résumé quantitatif final.
#' }
#'
#' @return
#' Une liste invisible contenant :
#' \describe{
#'   \item{createdColumns}{Noms des colonnes binaires créées.}
#'   \item{audit}{Liste d'audits par colonne avec correspondances et incohérences.}
#'   \item{summary}{\code{data.table} récapitulatif des comptes NA / 0 / 1.}
#'   \item{nIncoherences}{Nombre total d'incohérences détectées.}
#'   \item{logFile}{Chemin du fichier de log utilisé, le cas échéant.}
#' }
#'
#' @examples
#' library(data.table)
#'
#' dt <- data.table(
#'   Q1 = c(NA, "A", "B", ""),
#'   Q2 = c(1, NA, 0, -99)
#' )
#'
#' recodeBinary(
#'   dt,
#'   colonnesSource = c("Q1", "Q2"),
#'   naValues = c("", -99),
#'   verbose = TRUE
#' )
#'
#' @export


recodeBinary <- function(
  dt,
  colonnesSource,
  prefix = "bin_",
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
    all(colonnesSource %in% names(dt))
  )

  colonnesDest <- paste0(prefix, colonnesSource)

  # Empêche l'écrasement accidentel de colonnes existantes
  if (!allowOverwrite && any(colonnesDest %in% names(dt))) {
    stop(
      "Certaines colonnes cibles existent déjà : ",
      paste(colonnesDest[colonnesDest %in% names(dt)], collapse = ", ")
    )
  }

  # ------------------------------------------------------------------
  # Préparation du logging
  # ------------------------------------------------------------------

  # Fonction interne pour écrire dans le log si demandé
  logMsg <- function(...) {
    txt <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse = ""))
    if (!is.null(logFile)) {
      cat(txt, file = logFile, append = TRUE, sep = "\n")
    }
    if (verbose) message(txt)
  }

  logMsg("Début du recodage binaire.")

  # ------------------------------------------------------------------
  # Recodage forcé de certaines valeurs en NA (optionnel)
  # ------------------------------------------------------------------

  if (!is.null(naValues)) {
    logMsg(
      "Forçage en NA des valeurs suivantes : ",
      paste(naValues, collapse = ", ")
    )

    # Pour chaque colonne source :
    # toute valeur appartenant à naValues est convertie en NA
    dt[, (colonnesSource) :=
      lapply(.SD, function(x) {
        x[x %in% naValues] <- NA
        x
      }),
    .SDcols = colonnesSource
    ]
  }

  # ------------------------------------------------------------------
  # Recodage principal NA / non-NA -> 0 / 1
  # ------------------------------------------------------------------

  dt[, (colonnesDest) :=
    lapply(.SD, function(x) as.integer(!is.na(x))),
  .SDcols = colonnesSource
  ]

  logMsg(
    "Colonnes binaires créées : ",
    paste(colonnesDest, collapse = ", ")
  )

  # ------------------------------------------------------------------
  # Vérification globale vectorisée
  # ------------------------------------------------------------------

  incoherenceGlobale <- dt[, Reduce(
    `|`,
    Map(
      function(src, dest) {
        (is.na(get(src)) & get(dest) != 0L) |
          (!is.na(get(src)) & get(dest) != 1L)
      },
      colonnesSource,
      colonnesDest
    )
  )]

  nIncoherences <- sum(incoherenceGlobale)

  logMsg("Nombre total d'incohérences détectées : ", nIncoherences)

  # ------------------------------------------------------------------
  # Audit détaillé colonne par colonne
  # ------------------------------------------------------------------

  audit <- vector("list", length(colonnesSource))
  names(audit) <- colonnesSource

  for (i in seq_along(colonnesSource)) {
    src <- colonnesSource[i]
    dest <- colonnesDest[i]

    # Table Source/Destination unique
    correspondances <- unique(dt[, .(get(src), get(dest))])
    data.table::setnames(correspondances, c("Source", "Destination"))
    data.table::setorder(correspondances, Destination, Source)

    # Détection des incohérences au niveau valeur
    incoherent <- correspondances[
      (is.na(Source) & Destination != 0L) |
        (!is.na(Source) & Destination != 1L)
    ]

    audit[[src]] <- list(
      correspondances = correspondances,
      incoherences = incoherent
    )

    if (verbose) {
      message("Correspondances pour ", src, " → ", dest)
      print(correspondances)

      if (nrow(incoherent) > 0) {
        message("⚠ Incohérences détectées :")
        print(incoherent)
      }

      cat("\n")
    }
  }

  # ------------------------------------------------------------------
  # Résumé quantitatif final
  # ------------------------------------------------------------------

  summary <- data.table::data.table(
    colonneSource = colonnesSource,
    colonneBinaire = colonnesDest,
    nNA = sapply(colonnesSource, function(x) sum(is.na(dt[[x]]))),
    nOne = sapply(colonnesDest, function(x) sum(dt[[x]] == 1L)),
    nZero = sapply(colonnesDest, function(x) sum(dt[[x]] == 0L))
  )

  if (verbose) {
    message("Résumé global :")
    print(summary)
  }

  if (stopOnIncoherence && nIncoherences > 0) {
    stop(nIncoherences, " incohérences détectées lors du recodage.")
  }

  logMsg("Fin du traitement.")

  # ------------------------------------------------------------------
  # Valeur de retour invisible structurée
  # ------------------------------------------------------------------

  invisible(list(
    createdColumns = colonnesDest,
    audit = audit,
    summary = summary,
    nIncoherences = nIncoherences,
    logFile = logFile
  ))
}
