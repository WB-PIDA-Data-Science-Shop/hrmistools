## code to prepare `social_sustainability` dataset goes here
social_sustainability_raw <- get_data360_api(
  "WB_SSGD",
  "WB_SSGD_PCT_POP_CONF_GOV",
  pivot = FALSE
)

social_sustainability <- social_sustainability_raw |>
  # filter only national level values
  filter(
    AGE == "_T",
    SEX == "_T",
    URBANISATION == "_T",
    COMP_BREAKDOWN_1 == "_T",
    COMP_BREAKDOWN_2 == "_T"
  ) |>
  pivot_data360() |>
  rename(
    confidence_in_gov = wb_ssgd_pct_pop_conf_gov
  )

usethis::use_data(social_sustainability, overwrite = TRUE)
