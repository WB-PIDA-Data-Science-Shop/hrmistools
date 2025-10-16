library(testthat)
# library(dplyr)
# library(purrr)

test_that("define_fns returns a named list of formulas", {
  fns <- define_fns()
  expect_type(fns, "list")
  expect_true(all(vapply(fns, rlang::is_formula, logical(1))))
  expect_true("mean" %in% names(fns))
  expect_true("cv" %in% names(fns))
  expect_true("cp_ratio" %in% names(fns))
})

test_that("define_fns summary functions produce expected outputs", {
  fns <- define_fns()
  x <- c(10, 20, 30, 40)

  expect_equal(rlang::as_function(fns$sum)(x), sum(x))
  expect_equal(rlang::as_function(fns$mean)(x), mean(x))
  expect_equal(rlang::as_function(fns$median)(x), median(x))
  expect_equal(rlang::as_function(fns$var)(x), var(x))
  expect_equal(rlang::as_function(fns$min)(x), min(x))
  expect_equal(rlang::as_function(fns$max)(x), max(x))
  expect_equal(rlang::as_function(fns$count)(x), length(x))
  expect_equal(rlang::as_function(fns$count_unique)(c(1, 1, 2, 2)), 2)
})

test_that("define_fns handles missing values in prop_na and prop_zero", {
  fns <- define_fns()
  x <- c(0, 0, 1, NA)
  expect_true(rlang::is_formula(fns$prop_zero))
  expect_true(rlang::is_formula(fns$prop_na))
})

