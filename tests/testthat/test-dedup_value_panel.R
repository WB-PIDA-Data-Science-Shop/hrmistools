test_that("deduplication works", {
  df <- tibble(
    worker_id = c(1, 1, 1, 2, 2, 2, 2),
    gender    = c(NA, "M", "F", "F", NA, "M", "F"),
    ref_date  = as.Date(
      c(
        "2023-01-01",
        "2023-01-02",
        "2023-01-02",
        "2023-01-01",
        "2023-01-02",
        "2023-01-03",
        "2023-01-03"
      )
    )
  )

  df_expected <- tibble(
    worker_id = c(1, 1, 2, 2, 2),
    ref_date = as.Date(
      c("2023-01-01", "2023-01-02", "2023-01-01", "2023-01-02", "2023-01-03")
    ),
    gender = c(NA, "M", "F", NA, "M")
  )

  expect_equal(
    df |> dedup_value_panel(gender, worker_id, ref_date),
    df_expected
    )
})
