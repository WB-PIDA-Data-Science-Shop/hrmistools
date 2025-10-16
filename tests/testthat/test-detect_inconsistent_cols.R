test_that("detect_inconsistent_cols returns FALSE when no inconsistent columns are present", {
  df <- data.frame(a = 1:3, b = 4:6)
  result <- detect_inconsistent_cols(df, c("c", "d"))
  expect_false(result)
})

test_that("detect_inconsistent_cols returns TRUE when inconsistent columns are present", {
  df <- data.frame(a = 1:3, b = 4:6)
  result <- detect_inconsistent_cols(df, c("a", "c"))
  expect_true(result)
})

test_that("detect_inconsistent_cols handles empty inconsistent_cols vector", {
  df <- data.frame(a = 1:3, b = 4:6)
  result <- detect_inconsistent_cols(df, character(0))
  expect_false(result)
})

test_that("detect_inconsistent_cols returns FALSE when data frame has no columns", {
  df <- data.frame()
  result <- detect_inconsistent_cols(df, c("a", "b"))
  expect_false(result)
})

test_that("detect_inconsistent_cols handles all inconsistent columns correctly", {
  df <- data.frame(x = 1:2, y = 3:4)
  result <- detect_inconsistent_cols(df, c("x", "y"))
  expect_true(result)
})

test_that("detect_inconsistent_cols handles duplicate inconsistent column names", {
  df <- data.frame(a = 1:3)
  result <- detect_inconsistent_cols(df, c("a", "a", "b"))
  expect_true(result)
})
