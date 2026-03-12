#' Convertit des valeurs RVB en code couleur hexadécimal
#'
#' Convertit trois composantes rouge, vert, bleu (entiers de 0 à 255)
#' en code couleur hexadécimal au format `"#RRGGBB"`, utilisable directement
#' dans les fonctions graphiques R.
#'
#' @param r Entier entre 0 et 255. Intensité de la composante rouge.
#' @param g Entier entre 0 et 255. Intensité de la composante verte.
#' @param b Entier entre 0 et 255. Intensité de la composante bleue.
#'
#' @return Un vecteur caractère de longueur 1 contenant le code hexadécimal
#'   au format `"#RRGGBB"`.
#'
#' @examples
#' # Rouge pur
#' rgbToHex(255, 0, 0) # "#FF0000"
#'
#' # Blanc
#' rgbToHex(255, 255, 255) # "#FFFFFF"
#'
#' # Noir
#' rgbToHex(0, 0, 0) # "#000000"
#'
#' # Orange (couleur issue de la palette maison)
#' rgbToHex(243, 146, 0) # "#F39200"
#'
#' @export
rgbToHex <- function(r, g, b) {
  # Validation défensive des arguments
  args <- list(r = r, g = g, b = b)
  purrr::iwalk(args, function(val, nom) {
    if (!is.numeric(val) || length(val) != 1L) {
      stop(sprintf("`%s` doit être un entier numérique de longueur 1.", nom))
    }
    if (is.na(val) || val < 0 | val > 255) {
      stop(sprintf("`%s` doit être compris entre 0 et 255 (valeur reçue : %s).", nom, val))
    }
  })

  grDevices::rgb(r / 255, g / 255, b / 255)
}
