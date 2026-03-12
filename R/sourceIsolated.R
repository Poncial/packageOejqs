#' sourceIsolated: Exécuter un script R dans un environnement temporaire isolé
#'
#' Cette fonction permet de sourcer un script R dans un environnement séparé,
#' afin que tous les objets intermédiaires créés par le script ne polluent pas
#' le workspace global. Seuls les objets explicitement retournés sont extraits.
#'
#' @param scriptPath Character. Chemin vers le fichier R à exécuter.
#' @param returnObjects Character vector. Noms des objets à extraire de l'environnement temporaire.
#'                      Si NULL (par défaut), retourne tous les objets créés.
#'
#' @return Une liste contenant les objets spécifiés par `returnObjects` (ou tous les objets du script si `returnObjects = NULL`).
#'
#' @details
#' - L'environnement temporaire hérite du `globalenv()`, ce qui permet d'accéder
#'   aux packages déjà chargés (par ex. via `pacman::p_load()`) et aux fonctions globales.
#' - Les objets créés dans le script mais non listés dans `returnObjects` sont automatiquement jetés.
#' - Cette approche évite la pollution du workspace avec des objets intermédiaires.
#'
#' @examples
#' # Créer un script temporaire pour l'exemple
#' tmpScript <- tempfile(fileext = ".R")
#' writeLines(
#'   c(
#'     "x_intermediaire <- 42",
#'     "y_intermediaire <- x_intermediaire * 2",
#'     "resultatFinal   <- y_intermediaire + 10"
#'   ),
#'   con = tmpScript
#' )
#'
#' # Cas 1 : extraire un seul objet — les intermédiaires sont ignorés
#' out <- sourceIsolated(tmpScript, returnObjects = "resultatFinal")
#' out$resultatFinal # 94
#'
#' # Cas 2 : extraire tous les objets créés par le script
#' out <- sourceIsolated(tmpScript)
#' names(out) # "x_intermediaire" "y_intermediaire" "resultatFinal"
#'
#' # Vérifier que les intermédiaires ne polluent pas le workspace
#' exists("x_intermediaire") # FALSE
#'
#' # Nettoyage
#' file.remove(tmpScript)
#' @export
sourceIsolated <- function(scriptPath, returnObjects = NULL) {
  # Crée un environnement temporaire qui hérite du globalenv
  tmpEnv <- new.env(parent = globalenv())

  # Sourcing du script dans l'environnement temporaire
  source(scriptPath, local = tmpEnv)

  # Déterminer quels objets extraire
  objectsInEnv <- ls(tmpEnv)
  if (!is.null(returnObjects)) {
    objectsToReturn <- intersect(objectsInEnv, returnObjects)
  } else {
    objectsToReturn <- objectsInEnv
  }

  # Extraire les objets sélectionnés sous forme de liste
  result <- mget(objectsToReturn, envir = tmpEnv)

  # Supprimer l'environnement temporaire
  rm(tmpEnv)
  gc()

  # Retourner la liste des objets
  return(result)
}
