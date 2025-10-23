# tests/testthat/test-complete_columns.R
library(testthat)

test_that("complete_columns adds missing columns with NA", {
  df <- tibble(a = 1:3, b = letters[1:3])
  result <- complete_columns(df, c("a", "b", "c"))

  expect_true(all(c("a", "b", "c") %in% names(result)))
  expect_true(all(is.na(result$c)))
})

test_that("complete_columns does not change existing columns", {
  df <- tibble(a = 1:3, b = letters[1:3])
  result <- complete_columns(df, c("a", "b"))

  expect_equal(result, df)
})

test_that("complete_columns reorders columns to match 'cols' order", {
  df <- tibble(b = letters[1:3], a = 1:3)
  result <- complete_columns(df, c("a", "b"))

  expect_equal(names(result), c("a", "b"))
})
