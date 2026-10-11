library(data.table)

cb <- data.table(
  targetVariable = c("numFreqQual_qid87_6", "numFreqQual_qid87_6", "numFreqQual_qid87_8"),
  label = c("Quand ... je consacre plus de temps à... lire", "Quand ... lire",
            "Quand ... discuter avec d'autres élèves"),
  labelCourt = c("Lire", "Lire", "Discuter avec d'autres élèves")
)

test_that("getLabelsFromCodebook : qid87_6 = Lire, ordre et erreurs", {
  res <- getLabelsFromCodebook(cb, c("numFreqQual_qid87_8", "numFreqQual_qid87_6"))
  expect_identical(names(res), c("numFreqQual_qid87_8", "numFreqQual_qid87_6"))
  expect_identical(unname(res["numFreqQual_qid87_6"]), "Lire")
  expect_error(getLabelsFromCodebook(cb, "inconnue"), "absentes du codebook")
  expect_true(grepl("lire", getLabelsFromCodebook(cb[1], "numFreqQual_qid87_6", court = FALSE)))
})

test_that("getGroupVarMeta refuse des couleurs non nommées", {
  ok <- list(v = list(levels = c("a", "b"), colors = c(a = "red", b = "blue"),
                      axisTitle = "x", legendTitle = "x"))
  expect_silent(getGroupVarMeta(ok, "v"))
  ko <- ok; ko$v$colors <- unname(ko$v$colors)
  expect_error(getGroupVarMeta(ko, "v"), "nommé")
})

test_that("verifierCoherenceLabels détecte un décalage", {
  expect_warning(
    verifierCoherenceLabels(c(numFreqQual_qid87_6 = "Discuter avec d'autres élèves"), cb),
    "suspects"
  )
  expect_silent(verifierCoherenceLabels(c(numFreqQual_qid87_6 = "Lire"), cb))
})

test_that("testerDifferenceBinaire : signe, ex aequo, constante", {
  set.seed(1)
  dt <- data.table(g = rep(c("A", "B"), each = 40),
                   x = c(sample(3:5, 40, TRUE), sample(1:3, 40, TRUE)),
                   c0 = 2)
  lab <- c(x = "x", c0 = "c0")
  res <- testerDifferenceBinaire(dt, c("x", "c0"), lab, "g", "A", "B")
  expect_gt(res[variable == "x", effectSize], 0)            # A plus élevé
  expect_equal(res[variable == "c0", effectSize], 0)        # constante : r = 0, pas d'erreur
  res2 <- testerDifferenceBinaire(dt, "x", lab, "g", "B", "A")
  expect_equal(res2$effectSize, -res[variable == "x", effectSize])
  # |Z| = qnorm(p/2) pour le test sans correction de continuité
  p <- wilcox.test(dt[g == "A", x], dt[g == "B", x], exact = FALSE, correct = FALSE)$p.value
  n <- nrow(dt)
  expect_equal(abs(res[variable == "x", effectSize]),
               round(qnorm(p / 2, lower.tail = FALSE) / sqrt(n), 3), tolerance = 0.002)
})

test_that("testerDifferenceBinaire : p non nulle pour un grand z positif", {
  set.seed(2)
  dt <- data.table(g = rep(c("A", "B"), each = 3000),
                   x = c(sample(3:5, 3000, TRUE, prob = c(.2, .3, .5)), sample(1:5, 3000, TRUE)))
  ab <- testerDifferenceBinaire(dt, "x", c(x = "x"), "g", "A", "B")
  ba <- testerDifferenceBinaire(dt, "x", c(x = "x"), "g", "B", "A")
  expect_gt(ab$pValue, 0)
  expect_equal(ab$pValue, ba$pValue, tolerance = 1e-6)
  expect_equal(ab$pValue, wilcox.test(dt[g == "B", x], dt[g == "A", x], exact = FALSE)$p.value,
               tolerance = 1e-6)
})
