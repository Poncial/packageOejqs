test_that("recodeNumeric ignore les NA volontaires du dictionnaire", {
  recod <- c(a = 1, b = 2, naVolontaire = NA_real_)
  dt <- data.table::data.table(x = c("a", "b", "naVolontaire", NA))
  res <- recodeNumeric(dt, "x", recod, verbose = FALSE, stopOnIncoherence = TRUE)
  expect_equal(res$nIncoherences, 0L)
  expect_length(res$audit$x$nonRecoded, 0)
})

test_that("recodeNumeric signale une modalité absente du dictionnaire", {
  recod <- c(a = 1, naVolontaire = NA_real_)
  dt <- data.table::data.table(x = c("a", "naVolontaire", "inconnue"))
  res <- recodeNumeric(dt, "x", recod, verbose = FALSE)
  expect_equal(res$nIncoherences, 1L)
  expect_equal(res$audit$x$nonRecoded, "inconnue")

  dt2 <- data.table::data.table(x = c("a", "inconnue"))
  expect_error(
    recodeNumeric(dt2, "x", recod, verbose = FALSE, stopOnIncoherence = TRUE),
    "non recodées"
  )
})
