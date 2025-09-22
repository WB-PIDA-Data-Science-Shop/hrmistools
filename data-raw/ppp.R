## code to prepare `ppp` dataset goes here
ppp_raw <- get_data360_api(
  "WB_WDI",
  "WB_WDI_PA_NUS_PRVT_PP"
)

ppp <- ppp_raw |>
  transmute(
    country_code,
    year,
    ppp = as.numeric(wb_wdi_pa_nus_prvt_pp)
  )

usethis::use_data(ppp, overwrite = TRUE)
