## code to prepare `wwbi` dataset goes here
## code to prepare `wwbi` dataset goes here
library(dplyr)
library(readxl)
library(janitor)
library(tidyr)
library(stringr)

# accessed 2025.10.10
wwbi_indicators <- c(
  "WB_WWBI_BI_WAG_PREM_PE",
  "WB_WWBI_BI_PWK_PUBS_ED"
)

wwbi_raw <- get_data360_api(
  "WB_WWBI",
  wwbi_indicators,
  pivot = FALSE
)

wwbi_educational_attainment <- wwbi_raw |>
  filter(
    INDICATOR == "WB_WWBI_BI_PWK_PUBS_ED" &
      str_detect(COMP_BREAKDOWN_1, "^ISCED")
  ) |>
  pivot_wider(
    id_cols = c(REF_AREA, TIME_PERIOD),
    values_from = OBS_VALUE,
    names_from = c(INDICATOR, COMP_BREAKDOWN_1),
    names_sep = "_"
  ) |>
  rename(
    country_code = REF_AREA,
    year = TIME_PERIOD,
    share_no_edu = WB_WWBI_BI_PWK_PUBS_ED_ISCED11_N,
    share_primary_edu = WB_WWBI_BI_PWK_PUBS_ED_ISCED11_1,
    share_secondary_edu = WB_WWBI_BI_PWK_PUBS_ED_ISCED11_2_3,
    share_tertiary_edu = WB_WWBI_BI_PWK_PUBS_ED_ISCED11_5T8
  )

wwbi_wage_premium <- wwbi_raw |>
  filter(
    INDICATOR == "WB_WWBI_BI_WAG_PREM_PE"
  ) |>
  pivot_wider(
    id_cols = c(REF_AREA, TIME_PERIOD),
    values_from = OBS_VALUE,
    names_from = c(INDICATOR, COMP_BREAKDOWN_1, SEX),
    names_sep = "_"
  ) |>
  rename(
    country_code = REF_AREA,
    year = TIME_PERIOD,
    ps_wage_premium_pooled = WB_WWBI_BI_WAG_PREM_PE__Z__T,
    ps_wage_premium_female = WB_WWBI_BI_WAG_PREM_PE__Z_F,
    ps_wage_premium_male = WB_WWBI_BI_WAG_PREM_PE__Z_M,
    ps_wage_premium_edu_sector = WB_WWBI_BI_WAG_PREM_PE_WB_WWBI_INED__T,
    ps_wage_premium_hea_sector = WB_WWBI_BI_WAG_PREM_PE_WB_WWBI_INHE__T
  )

wwbi <- wwbi_educational_attainment |>
  full_join(
    wwbi_wage_premium,
    by = c("country_code", "year")
  ) |>
  mutate(
    across(
      -c(country_code, year),
      as.numeric
    )
  )

usethis::use_data(wwbi, overwrite = TRUE)
