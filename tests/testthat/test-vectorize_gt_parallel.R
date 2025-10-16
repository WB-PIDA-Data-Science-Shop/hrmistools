library(testthat)

test_that("vectorize_gt_parallel returns correct length and order", {

  input_vec <- c("bonjour", "merci", "salut")
  result <- vectorize_gt_parallel(
    vector = input_vec,
    target_language = "en",
    source_language = "fr",
    workers = 2,
    chunk_size = 2
  )

  # Check length and order
  expect_equal(length(result), length(input_vec))

})


test_that("vectorize_gt_parallel handles empty input gracefully", {

  result <- vectorize_gt_parallel(
    vector = character(0),
    target_language = "en",
    source_language = "fr"
  )

  expect_equal(result, NULL)
})


test_that("vectorize_gt_parallel produces expected results", {

  result <- vectorize_gt_parallel(
    vector = "bonjour",
    target_language = "en",
    source_language = "fr"
  )

  expect_equal(result, "Good morning")
})


