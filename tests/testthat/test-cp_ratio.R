library(testthat)

test_that("cp_ratio computes correct 90/10 percentile ratio", {
  x <- c(100, 200, 300, 400, 500)
  q <- quantile(x, probs = c(0.1, 0.9))
  expected <- q[2] / q[1]
  expect_equal(cp_ratio(x), expected)
})

test_that("cp_ratio handles custom quantiles", {
  x <- 1:10
  q <- quantile(x, probs = c(0.25, 0.75))
  expected <- q[2] / q[1]
  expect_equal(cp_ratio(x, upper = 0.75, lower = 0.25), expected)
})

test_that("cp_ratio removes missing values when na.rm = TRUE", {
  x <- c(NA, 10, 20, 30, 40)
  expect_silent(cp_ratio(x))
})

test_that("cp_ratio returns NA if denominator (lower quantile) is zero", {
  x <- c(0, 0, 100)
  expect_true(is.na(cp_ratio(x)))
})

test_that("cp_ratio returns NA if all values are missing", {
  expect_true(is.na(cp_ratio(c(NA, NA))))
})
