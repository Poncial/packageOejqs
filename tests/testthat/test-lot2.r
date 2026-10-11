library(data.table)

test_that("calculerTauxReponse : notSelected (NA = affiché) et selected (NA = non affiché)", {
  dt <- data.table(a = c("x", NA, "y"), b = c(NA, NA, "z"), ref = c("Jamais", "Oui", NA))
  items <- list(
    list(id = "i1", cols = c("a", "b")),
    list(id = "i2", cols = "b",
         condition = list(refCols = "ref", mode = "notSelected", refValue = "Jamais"))
  )
  res <- calculerTauxReponse(dt, items)
  expect_equal(res$nItemsAffiches, c(1L, 2L, 2L))
  expect_equal(res$tauxReponse, c(1, 0, 1))

  itemsSel <- list(list(id = "i3", cols = "b", conditionCol = "ref", conditionValues = "Oui"))
  resSel <- calculerTauxReponse(dt, itemsSel)
  expect_equal(resSel$nItemsAffiches, c(0L, 1L, 0L))
  expect_true(is.na(resSel$tauxReponse[1]))
})

test_that("combineSummaryForSynthesis : ordre des items et libellés dupliqués", {
  set.seed(1)
  dt <- data.table(g = rep(c("A", "B"), 20), z = sample(1:5, 40, TRUE), a = sample(1:5, 40, TRUE))
  sl <- summariseItemsByGroup(dt, c("z", "a"), "g", includeTotal = FALSE)
  res <- combineSummaryForSynthesis(sl, c(z = "Zèbre", a = "Abeille"))
  expect_identical(levels(res$item), c("Zèbre", "Abeille"))   # ordre de varItems, pas alphabétique
  expect_error(combineSummaryForSynthesis(sl, c(z = "X", a = "X")), "dupliqués")
})

test_that("plotGroupedBarCharts : couleur par nom, indépendante de l'ordre des données", {
  dt <- data.table(g = c("B", "B", "A", "A"), x = c(1, 2, 3, 4))   # moyenne B = 1.5, A = 3.5
  sl <- summariseItemsByGroup(dt, "x", "g", includeTotal = FALSE)
  p <- plotGroupedBarCharts(sl, groupVar = "g", barColors = c(B = "#FF0000", A = "#0000FF"),
                            outputDir = tempfile())$x
  b <- ggplot2::layer_data(p, 1)
  expect_equal(b$fill[abs(b$y - 3.5) < 1e-8], "#0000FF")   # barre A
  expect_equal(b$fill[abs(b$y - 1.5) < 1e-8], "#FF0000")   # barre B
  expect_error(
    plotGroupedBarCharts(sl, groupVar = "g", barColors = c(A = "#0000FF"), outputDir = tempfile()),
    "couleur absente"
  )
})


test_that("plotGroupedBarCharts : reverseXOrder numérique sans xBreaks garde les repères", {
  dt <- data.table(niveau = rep(1:3, each = 4), x = rep(1:4, 3))
  sl <- summariseItemsByGroup(dt, "x", "niveau", includeTotal = FALSE)
  p <- plotGroupedBarCharts(sl, groupVar = "niveau", reverseXOrder = TRUE,
                            outputDir = tempfile())$x
  expect_true(inherits(p$scales$get_scales("x")$breaks, "waiver"))
})
