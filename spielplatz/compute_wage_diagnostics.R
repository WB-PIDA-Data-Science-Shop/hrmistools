################################################################################
################### QUICKLY COMPUTE WAGE BILL DIAGNOSTICS ######################
################################################################################

### first let us read in the harmonized data
contract_df <- readRDS("spielplatz/bra_hrmis_contract.rds")
worker_df <- readRDS("spielplatz/bra_hrmis_worker.rds")
org_df <- readRDS("spielplatz/bra_hrmis_organization.rds")

### wage bill planning

#3.1.1  wage bill as a share of GDP, expenditures and revenues

## compute wage bill as a share of GDP for each year

totwage_df <-
  contract_df |>
  group_by(year) |>
  summarise(base_salary_lcu = sum(base_salary_lcu, na.rm = T),
            gross_salary_lcu = sum(gross_salary_lcu, na.rm = T),
            net_salary_lcu = sum(net_salary_lcu, na.rm = T)) |>
  mutate(year = as.integer(year))

econwide_df <-
  econwide_indicators |>
  filter(country_code == "BRA" &
           year >= min(totwage_df[["year"]]) &
                 year <= max(totwage_df[["year"]]))

wagebillstats_df <-
  totwage_df |>
  merge(econwide_df |>
          dplyr::select(-country_code),
        by = "year",
        all = TRUE) |>
  as_tibble() |>
  mutate(base_salary_lcu_gdprate = base_salary_lcu / wb_wdi_ny_gdp_mktp_cn,
         gross_salary_lcu_gdprate = gross_salary_lcu / wb_wdi_ny_gdp_mktp_cn,
         net_salary_lcu_gdprate = net_salary_lcu / wb_wdi_ny_gdp_mktp_cn)
