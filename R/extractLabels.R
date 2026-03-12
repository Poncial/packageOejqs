#' Extract variable labels from a data.table
#'
#' This function retrieves the `"label"` attribute from a set of columns
#' in a `data.table` and returns them in a two-column `data.table`.
#'
#' @param dt A `data.table` containing labelled variables.
#' @param cols A character vector of column names from which to extract labels.
#'
#' @return A `data.table` with two columns:
#' \describe{
#'   \item{variable}{Column name.}
#'   \item{label}{Value of the `"label"` attribute for the column (may be `NULL`).}
#' }
#'
#' @details
#' The function assumes that labels are stored as attributes named `"label"`
#' If a column does not have a `"label"` attribute, `NA` is returned.
#'
#' @examples
#' library(data.table)
#'
#' dt <- data.table(
#'   age = c(20, 30),
#'   sex = c(1, 2)
#' )
#' attr(dt$age, "label") <- "Age of respondent"
#' attr(dt$sex, "label") <- "Biological sex"
#'
#' extractLabels(dt, c("age", "sex"))
#'
#' @export
extractLabels <- function(dt, cols) {
  # --- Input checks -----------------------------------------------------------
  stopifnot(
    is.data.table(dt),
    all(cols %in% names(dt))
  )

  # --- Build output -----------------------------------------------------------
  # For each requested column, extract the 'label' attribute
  data.table(
    variable = cols,
    label = sapply(cols, function(x) attr(dt[[x]], "label"))
  )
}
