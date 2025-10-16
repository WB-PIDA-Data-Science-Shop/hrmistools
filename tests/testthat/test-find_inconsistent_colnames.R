test_that("find_inconsistent_colnames detects inconsistent columns correctly", {
  df1 <- tibble(a = 1, b = 2)
  df2 <- tibble(a = 3, c = 4)
  df_list <- list(df1, df2)

  result <- find_inconsistent_colnames(df_list) |> unlist() |> unname()
  expect_true(all(c("b", "c") %in% result))
  expect_equal(length(result), 2)
})

test_that("find_inconsistent_colnames returns empty when all columns match", {
  df1 <- tibble(a = 1, b = 2)
  df2 <- tibble(a = 3, b = 4)
  df_list <- list(df1, df2)

  result <- find_inconsistent_colnames(df_list)
  expect_equal(result, tibble::tibble(colnames = character(0)))
})

test_that("find_inconsistent_colnames works with more than two data frames", {
  df1 <- data.frame(a = 1, b = 2)
  df2 <- data.frame(a = 3, c = 4)
  df3 <- data.frame(a = 5, d = 6)
  df_list <- list(df1, df2, df3)

  result <- find_inconsistent_colnames(df_list)
  expect_true(all(c("b", "c", "d") %in% result$colnames))
  expect_equal(length(result$colnames), 3)
})

test_that("find_inconsistent_colnames handles list of empty data frames", {
  df1 <- data.frame()
  df2 <- data.frame()
  df_list <- list(df1, df2)

  result <- find_inconsistent_colnames(df_list)
  expect_true(tibble::is_tibble(result))
  expect_equal(nrow(result), 0)
})
