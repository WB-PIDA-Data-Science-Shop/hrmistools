test_that("harmonize_columns works with a named character vector dictionary", {
  df <- data.frame(Q1_age = 25, Q2_sex = "M", Q3_income = 50000)
  dict <- c("age" = "Q1_age", "gender" = "Q2_sex", "income" = "Q3_income")

  result <- harmonize_columns(df, dict)

  expect_named(result, c("age", "gender", "income"))
  expect_equal(result$age, 25)
  expect_equal(result$gender, "M")
  expect_equal(result$income, 50000)
})

test_that("harmonize_columns works with a data frame dictionary", {
  df <- data.frame(Q1_age = 30, Q2_sex = "F", Q3_income = 70000)
  dict_df <- data.frame(
    from = c("Q1_age", "Q2_sex", "Q3_income"),
    to   = c("age", "gender", "income")
  )

  result <- harmonize_columns(df, dict_df)

  expect_named(result, c("age", "gender", "income"))
  expect_equal(result$income, 70000)
})

test_that("harmonize_columns ignores dictionary entries not in the data", {
  df <- data.frame(Q1_age = 25, Q2_sex = "M")
  dict <- c("age" = "Q1_age", "gender" = "Q2_sex", "income" = "Q3_income")

  result <- harmonize_columns(df, dict)

  # Should only keep age and gender (since Q3_income not in df)
  expect_named(result, c("age", "gender"))
  expect_false("income" %in% names(result))
})

test_that("harmonize_columns returns an empty data frame if no matches found", {
  df <- data.frame(a = 1, b = 2)
  dict <- c("x" = "c", "y" = "d")

  result <- harmonize_columns(df, dict)

  expect_equal(ncol(result), 0)
  expect_s3_class(result, "data.frame")
})

test_that("harmonize_columns handles empty dictionary gracefully", {
  df <- data.frame(a = 1, b = 2)
  dict <- character(0)

  result <- harmonize_columns(df, dict)

  expect_equal(ncol(result), 0)
  expect_s3_class(result, "data.frame")
})

test_that("harmonize_columns preserves data values correctly after renaming", {
  df <- data.frame(Q1_age = c(20, 30), Q2_sex = c("M", "F"))
  dict <- c("age" = "Q1_age", "gender" = "Q2_sex")

  result <- harmonize_columns(df, dict)

  expect_equal(result$age, c(20, 30))
  expect_equal(result$gender, c("M", "F"))
})
