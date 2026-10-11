#' Légende commune des forest plots
#'
#' Assemble la méthode, la famille de tests, les seuils d'interprétation, l'explication
#' de la taille d'effet, un éventuel avertissement et les notes de lecture des items,
#' avec retour à la ligne.
#'
#' @param testNom Nom du test (p.ex. "Mann-Whitney").
#' @param nTests Nombre de tests de la famille corrigée.
#' @param methodeAjustement Méthode de `stats::p.adjust` (p.ex. "holm").
#' @param familleTexte Description de la famille de tests.
#' @param typeEffet `"r"` (Mann-Whitney, signé) ou `"etaSqH"` (Kruskal-Wallis).
#' @param notes Vecteur nommé : nom = libellé de l'item, valeur = note de lecture. `NULL` si aucune.
#' @param avertissement Texte libre ajouté (p.ex. une limite d'interprétation). `NULL` si aucun.
#' @param largeur Nombre de caractères par ligne.
#' @return Une chaîne, lignes séparées par `"\n"`.
#' @export
construireCaptionForest <- function(
    testNom,
    nTests,
    methodeAjustement = "holm",
    familleTexte = "ensemble des tests de l'analyse",
    typeEffet = c("r", "etaSqH", "rho"),
    notes = NULL,
    avertissement = NULL,
    largeur = 110
    )
  {
  typeEffet <- match.arg(typeEffet)
  if (length(notes) == 0) notes <- NULL
  stopifnot(
    is.character(testNom), length(testNom) == 1,
    is.numeric(nTests), length(nTests) == 1, nTests >= 1,
    is.character(methodeAjustement), length(methodeAjustement) == 1,
    is.character(familleTexte), length(familleTexte) == 1,
    is.numeric(largeur), largeur > 20
  )
  if (!is.null(notes)) stopifnot(is.character(notes), !is.null(names(notes)))

  seuils <- switch(typeEffet,
                   r      = "|r| : < .1 négligeable, < .3 faible, < .5 modéré, ≥ .5 fort.",
                   etaSqH = "η²_H : < .01 négligeable, < .06 faible, < .14 modéré, ≥ .14 fort."
  )
  explication <- switch(typeEffet,
                        r = paste0(
                          "r = Z / √N : Z est la statistique standardisée du test de Mann-Whitney et N l'effectif ",
                          "total comparé. r varie de -1 à 1 ; 0 = aucune différence de rangs entre les deux groupes."),
                        etaSqH = paste0(
                          "η²_H = (H - k + 1) / (n - k) : H est la statistique de Kruskal-Wallis, k le nombre de ",
                          "groupes et n l'effectif total. Non signé ; peut être légèrement négatif."),
                        rho = "ρ : corrélation de rangs de Spearman, de -1 à 1 ; 0 = aucune association monotone.",
  )
  nTexte <- if (nTests == 1) "1 test" else paste0(as.integer(nTests), " tests")
  lignes <- c(
    paste0(testNom, " ; p ajustée (", methodeAjustement, ") sur ", nTexte, " (", familleTexte, "). ", seuils),
    explication,
    avertissement,
    if (!is.null(notes)) {
      paste0("Items à lecture particulière : ",
             paste0(names(notes), " (", notes, ")", collapse = " ; "))
    }
  )
  vapply(lignes, \(x) paste(strwrap(x, width = largeur), collapse = "\n"), character(1), USE.NAMES = FALSE) |>
    paste(collapse = "\n")
}
