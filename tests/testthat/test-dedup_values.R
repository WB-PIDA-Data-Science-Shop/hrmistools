test_that("dedup_values(mode) returns modal value per group", {
  df <- tibble::tibble(
    id = c(1,1,1, 2,2,2),
    date = c("2020-01","2020-01","2020-01",
             "2020-02","2020-02","2020-02"),
    gender = c("M","M","F", "F","M","M")
  )

  result <- dedup_values(df, id, date, gender, method = "mode")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$gender[result$id == 1], "M") # modal value
  expect_equal(result$gender[result$id == 2], "M") # M appears twice vs F once
})

test_that("dedup_values(first) returns first value per group (even if NA)", {
  df <- tibble::tibble(
    id = c(1,1,1, 2,2,2),
    date = c("2020-01","2020-01","2020-01",
             "2020-02","2020-02","2020-02"),
    gender = c(NA,"M","F", "F",NA,"M")
  )

  result <- dedup_values(df, id, date, gender, method = "first")

  expect_equal(result$gender[result$id == 1], NA_character_)
  expect_equal(result$gender[result$id == 2], "F")
})

test_that("dedup_values(first_nonmissing) skips missing values correctly", {
  df <- tibble::tibble(
    id = c(1,1,1, 2,2,2),
    date = c("2020-01","2020-01","2020-01",
             "2020-02","2020-02","2020-02"),
    gender = c(NA,"M","F", NA,NA,"F")
  )

  result <- dedup_values(df, id, date, gender, method = "first_nonmissing")

  expect_equal(result$gender[result$id == 1], "M")
  expect_equal(result$gender[result$id == 2], "F")
})

test_that("dedup_values(mode) ignores NA when counting mode", {
  df <- tibble::tibble(
    id = c(1,1,1),
    date = c("2020-01","2020-01","2020-01"),
    gender = c(NA,"M","M")
  )

  result <- dedup_values(df, id, date, gender, method = "mode")

  expect_equal(result$gender, "M")
})

test_that("dedup_values(mode) handles ties by picking one value deterministically", {
  df <- tibble::tibble(
    id = c(1,1,1,1),
    date = c("2020-01","2020-01","2020-01","2020-01"),
    gender = c("M","F","M","F") # tie: both appear twice
  )

  result <- dedup_values(df, id, date, gender, method = "mode")

  expect_true(result$gender %in% c("M","F"))
  expect_equal(nrow(result), 1)
})

test_that("dedup_values(first_nonmissing) returns NA if all values missing", {
  df <- tibble::tibble(
    id = c(1,1),
    date = c("2020-01","2020-01"),
    gender = c(NA, NA)
  )

  result <- dedup_values(df, id, date, gender, method = "first_nonmissing")

  expect_true(is.na(result$gender))
})

test_that("dedup_values(first) and first_nonmissing produce same output when no NAs", {
  df <- tibble::tibble(
    id = c(1,1, 2,2),
    date = c("2020-01","2020-01","2020-02","2020-02"),
    gender = c("M","F","F","M")
  )

  first_res <- dedup_values(df, id, date, gender, method = "first")
  fnm_res <- dedup_values(df, id, date, gender, method = "first_nonmissing")

  expect_equal(first_res$gender, fnm_res$gender)
})
