library(data.table)

test_that("preparerBlocs : bornes lues dans l'échelle, erreurs", {
  fams <- list(
    list(family = "Accord", cols = c("a", "b"), prefix = "num_",
         dict = c(x = 1, y = 5, z = NA_real_), ancrage = "1 = x … 5 = y"),
    list(family = "Freq", cols = "c", prefix = "numF_",
         dict = c(p = 0, q = 6), ancrage = "0 = p … 6 = q"))
  b <- preparerBlocs(list(
    bl1 = list(titre = "T", cols = c("num_a", "num_b")),
    bl2 = list(titre = "U", cols = "numF_c")), fams)
  expect_equal(b$bl1$yLimits, c(1, 5))
  expect_equal(b$bl2$yBreaks, 0:6)
  expect_error(preparerBlocs(list(m = list(titre = "T", cols = c("num_a", "numF_c"))), fams), "hétérogènes")
  expect_error(preparerBlocs(list(a = list(titre = "T", cols = "num_a"),
                                  b = list(titre = "U", cols = "num_a")), fams), "plusieurs blocs")
  expect_error(preparerBlocs(list(a = list(titre = "T", cols = "num_zzz")), fams), "famille")
})

test_that("getNotesLecture : seulement les notes présentes, dans l'ordre de cols", {
  cb <- data.table(targetVariable = c("a", "a", "b", "c"), noteLecture = c("n1", "n1", NA, ""))
  res <- getNotesLecture(cb, c("c", "b", "a"))
  expect_identical(names(res), "a")
  expect_identical(unname(res), "n1")
  expect_length(getNotesLecture(cb, "b"), 0)
  expect_error(getNotesLecture(cb, "zzz"), "absentes")
  cb2 <- rbind(cb, data.table(targetVariable = "a", noteLecture = "autre"))
  expect_error(getNotesLecture(cb2, "a"), "Plusieurs")
})

test_that("plotCorrelationHeatmap : captionTexte optionnel, erreurs", {
  corDt <- data.table(
    labelVar1 = rep(c("A", "B"), 2), labelVar2 = rep(c("A", "B"), each = 2),
    rho = c(1, .3, .3, 1), pValue = c(NA, .01, .01, NA))
  f1 <- tempfile(fileext = ".png"); f2 <- tempfile(fileext = ".png")
  expect_no_error(suppressMessages(plotCorrelationHeatmap(corDt, outputPath = f1)))
  expect_no_error(suppressMessages(plotCorrelationHeatmap(corDt, outputPath = f2, captionTexte = "Holm")))
  expect_true(file.exists(f1) && file.exists(f2))
  expect_error(suppressMessages(plotCorrelationHeatmap(corDt, outputPath = f1, captionTexte = 1)))
})
