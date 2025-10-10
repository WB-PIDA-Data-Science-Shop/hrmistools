## code to prepare `enterprise_surveys` dataset goes here
enterprise_surveys_raw <- get_data360_api(
  "WB_ES",
  "WB_ES_T_WK10",
  pivot = FALSE
)

enterprise_surveys <- enterprise_surveys_raw |>
  # only retain economy-wide indicator
  filter(
    COMP_BREAKDOWN_1 == "_T" &
      COMP_BREAKDOWN_2 == "_T" &
      COMP_BREAKDOWN_3 == "_T"
  ) |>
  pivot_data360() |>
  rename(
    workforce_constraint = wb_es_t_wk10
  )

usethis::use_data(enterprise_surveys, overwrite = TRUE)
