## code to prepare `cpi` dataset goes here
cpi_raw <- get_data360_api(
  "WB_WDI",
  "WB_WDI_FP_CPI_TOTL"
)

cpi <- cpi_raw |>
  transmute(
    country_code,
    year,
    cpi = as.numeric(wb_wdi_fp_cpi_totl)
  )

usethis::use_data(cpi, overwrite = TRUE)
