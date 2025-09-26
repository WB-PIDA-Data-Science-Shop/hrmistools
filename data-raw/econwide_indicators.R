## code to prepare `economy_wide` variables for wage diagnostics

idvar_list <- list("gdp" = "WB_WDI_NY_GDP_MKTP_CN",
                   "pexpenditure" = "WB_WDI_GC_XPN_TOTL_CN",
                   "prevenue" = "WB_WDI_GC_REV_XGRT_CN",
                   "taxrevenue" = "WB_WDI_GC_TAX_TOTL_CN",
                   "emp_pop_rate" = "WB_WDI_SL_EMP_TOTL_SP_NE_ZS",
                   "tot_pop" = "WB_WDI_SP_POP_TOTL",
                   "salaried_rate" = "WB_WDI_SL_EMP_WORK_ZS")



df <- lapply(X = idvar_list,
             FUN = get_data360_api,
             dataset_id = "WB_WDI") |>
      Reduce(f = "merge_wrapper") |>
      as_tibble()

econwide_indicators <- df

rm(df)

econwide_indicators <-
  econwide_indicators |>
  mutate(across(starts_with("wb_wdi_"), as.numeric))

usethis::use_data(econwide_indicators, overwrite = TRUE)











usethis::use_data(economy_wide, overwrite = TRUE)
