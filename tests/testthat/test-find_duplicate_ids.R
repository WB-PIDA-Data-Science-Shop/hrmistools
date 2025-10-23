test_that("find_duplicate_ids correctly identifies duplicates", {
  df <- tibble::tibble(id = c(1, 2, 2, 3, 3, 3, 4))
  result <- find_duplicate_ids(df, id)

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("id", "n"))
  expect_equal(nrow(result), 2) # two duplicated values: 2 and 3
  expect_equal(result$id, c(2, 3))
  expect_equal(result$n, c(2, 3))
})

test_that("find_duplicate_ids returns empty tibble when no duplicates exist", {
  df <- tibble::tibble(id = 1:5)
  result <- find_duplicate_ids(df, id)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_named(result, c("id", "n"))
})

test_that("find_duplicate_ids handles character identifiers", {
  df <- tibble::tibble(code = c("A", "B", "B", "C", "C", "C"))
  result <- find_duplicate_ids(df, code)

  expect_equal(result$code, c("B", "C"))
  expect_equal(result$n, c(2, 3))
})

test_that("find_duplicate_ids handles empty data frame gracefully", {
  df <- tibble::tibble(id = integer(0))
  result <- find_duplicate_ids(df, id)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_named(result, c("id", "n"))
})

test_that("find_duplicate_ids works with NA values", {
  df <- tibble::tibble(id = c(1, 2, 2, NA, NA, 3))
  result <- find_duplicate_ids(df, id)

  expect_true(NA %in% result$id)
  expect_equal(result$n[result$id %in% NA], 2) # NA appears twice
})
