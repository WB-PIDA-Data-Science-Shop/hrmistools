library(testthat)

test_that("cv computes correct coefficient of variation", {
  x <- c(10, 12, 8, 15)
  expected <- sd(x) / mean(x)
  expect_equal(cv(x), expected)
})

test_that("cv removes missing values when na.rm = TRUE", {
  x <- c(10, NA, 20, 30)
  expected <- sd(c(10, 20, 30)) / mean(c(10, 20, 30))
  expect_equal(cv(x, na.rm = TRUE), expected)
})

test_that("cv returns NA for empty input", {
  expect_true(is.na(cv(numeric(0))))
})

test_that("cv returns NA when mean is zero", {
  expect_true(is.na(cv(c(-1, 0, 1))))
})

test_that("cv handles all missing values gracefully", {
  expect_true(is.na(cv(c(NA, NA, NA))))
})
