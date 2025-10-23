library(testthat)
# library(dplyr)
# library(tidyr)

test_that("compute_share computes ratios correctly (long format)", {
  df <- tibble(
    country_code = rep(c("A", "B"), each = 2),
    ref_date = rep(2020:2021, times = 2),
    income = c(100, 200, 300, 400)
  )

  macro_data <- tibble(
    country_code = c("A", "B"),
    ref_date = c(2020, 2021),
    gdp = c(1000, 2000)
  )

  res <- compute_share(
    data = df,
    macro_data = macro_data,
    macro_cols = "gdp",
    cols = "income",
    groups = c("country_code", "ref_date"),
    fns = "mean",
    output = "long"
  )

  expect_true(all(c("indicator", "value") %in% names(res)))
  expect_true(any(grepl("income_mean_per_gdp", res$indicator)))
})

test_that("compute_share computes ratios correctly (wide format)", {
  df <- tibble(
    country_code = c("A", "B"),
    ref_date = c(2020, 2021),
    income = c(100, 200)
  )

  macro_data <- tibble(
    country_code = c("A", "B"),
    ref_date = c(2020, 2021),
    gdp = c(1000, 2000)
  )

  res <- compute_share(
    data = df,
    macro_data = macro_data,
    macro_cols = "gdp",
    cols = "income",
    groups = c("country_code", "ref_date"),
    fns = "mean",
    output = "wide"
  )

  expect_true(any(grepl("income_mean_per_gdp", names(res))))
  expect_true(all(c("gdp", "income_mean") %in% names(res)))
})

test_that("compute_share throws error if no common join variables", {
  df <- tibble(a = 1:3, b = 2:4)
  macro_data <- tibble(x = 1:3, y = 2:4)

  expect_error(
    compute_share(
      data = df,
      macro_data = macro_data,
      macro_cols = "y",
      cols = "b",
      groups = "a",
      fns = "mean"
    ),
    "No common grouping variables"
  )
})
