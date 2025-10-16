library(testthat)
# library(dplyr)
# library(tidyr)

test_that("compute_change calculates correct year-over-year growth", {
  df <- tibble(
    year = 2020:2023,
    gdp = c(100, 110, 121, 133.1)
  )

  res <- compute_change(df, gdp, year)
  expected_growth <- df$gdp / dplyr::lag(df$gdp) - 1

  expect_equal(res$gdp_growth, expected_growth)
})

test_that("compute_change fills missing years using complete()", {
  df <- tibble(
    year = c(2020, 2022),
    gdp = c(100, 121)
  )

  res <- compute_change(df, gdp, year)
  expect_true(all(2020:2022 %in% res$year))
})

test_that("compute_change handles NA gracefully", {
  df <- tibble(
    year = 2020:2022,
    gdp = c(100, NA, 150)
  )

  res <- compute_change(df, gdp, year)
  expect_true(all(is.na(res$gdp_growth[1:2]) | is.finite(res$gdp_growth[1:2])))
})

test_that("compute_change output has expected column names", {
  df <- tibble(year = 2020:2022, gdp = c(100, 120, 144))
  res <- compute_change(df, gdp, year)
  expect_true(all(c("year", "gdp_growth") %in% names(res)))
})
