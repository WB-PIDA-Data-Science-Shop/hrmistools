# library(testthat)
# library(httr)
# library(jsonlite)
# library(dplyr)
# library(tibble)
#
# test_that("get_data360_api constructs URL correctly", {
#   dataset_id <- "WB_WDI"
#   indicator_id <- "WB_WDI_FP_CPI_TOTL"
#
#   mock_modify_url <- testthat::with_mocked_bindings(
#     `httr::GET` = function(url, ...) {
#       expect_true(grepl("DATABASE_ID=WB_DATASET", url))
#       expect_true(grepl("INDICATOR=IND1,IND2", url))
#       # Return a mock response
#       structure(
#         list(status_code = 200,
#              content = charToRaw('{"count": 0, "value": []}')),
#         class = "response"
#       )
#     },
#     get_data360_api(dataset_id, indicator_id)
#   )
#
#   expect_s3_class(mock_modify_url, "tbl_df")
#   expect_equal(nrow(mock_modify_url), 0)
# })
#
# test_that("get_data360_api handles pagination correctly", {
#   # Mock first and second pages
#   mock_responses <- list(
#     '{"count": 1500, "value": [{"id":1},{"id":2},{"id":3}]}',
#     '{"count": 1500, "value": [{"id":4},{"id":5}]}'
#   )
#
#   mock_index <- 0
#   mock_get <- function(url, ...) {
#     mock_index <<- mock_index + 1
#     structure(list(
#       status_code = 200,
#       content = charToRaw(mock_responses[[mock_index]])
#     ), class = "response")
#   }
#
#   testthat::with_mock(
#     `httr::GET` = mock_get,
#     {
#       result <- get_data360_api("DATASET", "INDICATOR", pivot = FALSE)
#       expect_s3_class(result, "tbl_df")
#       expect_true(all(c("id") %in% names(result)))
#       expect_equal(nrow(result), 5)
#     }
#   )
# })
#
# test_that("get_data360_api calls pivot_data360 when pivot=TRUE", {
#   mock_data <- tibble(country = "A", year = 2020, value = 5)
#
#   testthat::with_mock(
#     `httr::GET` = function(...) structure(list(
#       status_code = 200,
#       content = charToRaw('{"count": 1, "value": [{"country": "A", "year": 2020, "value": 5}]}')
#     ), class = "response"),
#     `pivot_data360` = function(x) {
#       expect_s3_class(x, "tbl_df")
#       x$value <- x$value * 10  # mock transform
#       x
#     },
#     {
#       result <- get_data360_api("DS", "ID", pivot = TRUE)
#       expect_equal(result$value, 50)
#     }
#   )
# })
#
# test_that("get_data360_api raises error on failed request", {
#   expect_error(
#     testthat::with_mock(
#       `httr::GET` = function(...) structure(list(status_code = 404), class = "response"),
#       get_data360_api("BAD", "IND")
#     ),
#     class = "http_404"
#   )
# })

