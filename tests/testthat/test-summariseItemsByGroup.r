test_that("summariseItemsByGroup calcule l'IC avec la loi de Student", {
  dt <- data.table::data.table(
    groupe = rep("A", 10),
    q1     = c(1, 2, 2, 3, 3, 3, 4, 4, 5, 5)
  )
  res <- summariseItemsByGroup(
    dt, varItems = "q1", groupVar = "groupe",
    includeTotal = FALSE, ciLevel = 0.95
  )$q1

  demiLargeurAttendue <- diff(stats::t.test(dt$q1, conf.level = 0.95)$conf.int) / 2
  expect_equal(res$ci, demiLargeurAttendue)

  # Garde-fou : doit être plus large que l'ancienne version (quantile normal)
  expect_gt(res$ci, stats::qnorm(0.975) * res$sd / sqrt(res$n))
})
