library(testthat)
# library(dplyr)
# library(tidyr)
# library(purrr)

test_that("compute_summary computes grouped mean correctly", {
  df <- tibble(
    country = rep(c("A", "B"), each = 3),
    income = c(10, 20, 30, 5, 15, 25)
  )

  res <- compute_summary(
    data = df,
    cols = "income",
    groups = "country",
    fns = "mean",
    output = "wide"
  )

  expected <- df %>%
    group_by(country) %>%
    summarise(income_mean = mean(income), .groups = "drop")

  expect_equal(res$income_mean, expected$income_mean)
})

test_that("compute_summary supports multiple summary functions", {
  df <- tibble(
    region = rep(c("X", "Y"), each = 4),
    wage = 1:8
  )

  res <- compute_summary(
    data = df,
    cols = "wage",
    groups = "region",
    fns = c("mean", "sd"),
    output = "wide"
  )

  expect_true(all(c("wage_mean", "wage_sd") %in% names(res)))
})

test_that("compute_summary supports custom formula functions", {
  df <- tibble(group = rep(1:2, each = 3), value = 1:6)

  res <- compute_summary(
    data = df,
    cols = "value",
    groups = "group",
    fns = list(q90 = ~quantile(.x, 0.9)),
    output = "wide"
  )

  expect_true("value_q90" %in% names(res))
})

test_that("compute_summary returns long format correctly", {
  df <- tibble(
    country = rep(c("A", "B"), each = 3),
    income = c(10, 20, 30, 5, 15, 25)
  )

  res <- compute_summary(
    data = df,
    cols = "income",
    groups = "country",
    fns = "mean",
    output = "long"
  )

  expect_true(all(c("indicator", "value") %in% names(res)))
  expect_true(any(grepl("income_mean", res$indicator)))
})

test_that("compute_summary throws error for invalid cols input", {
  df <- tibble(a = 1:3)
  expect_error(compute_summary(df, cols = 123, fns = "mean", groups = "a"))
})

test_that("compute_summary throws error for unknown function name", {
  df <- tibble(a = 1:3)
  expect_error(compute_summary(df, cols = "a", fns = "unknown_fn", groups = "a"))
})
