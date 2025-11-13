################################################################################
################## COMPUTE THE INDICATORS FOR OUR MODELS #######################
################################################################################
library(lubridate)
library(data.table)
library(dplyr)


contract_dt <- readRDS("spielplatz/bra_hrmis_contract.rds") |> as.data.table()
worker_dt <- readRDS("spielplatz/bra_hrmis_worker.rds") |> as.data.table()
org_dt <- readRDS("spielplatz/bra_hrmis_organization.rds") |> as.data.table()

### 3.1
wage_vars <- c("gross_salary_lcu",
               "net_salary_lcu",
               "base_salary_lcu")

lcu_vars <- colnames(macro_indicators)[grepl("_lcu",
                                             colnames(macro_indicators))]

contract_dt[, year := lubridate::year(ref_date)]


# wage bill by gdp, expenditures, revenues by year
# compute_share(data = contract_harmonized,
#               cols = wage_vars,
#               groups = c("country_code", "year"),
#               macro_cols = c("gdp_lcu", "pexpenditure_lcu",
#                              "prevenue_lcu", "taxrevenue_lcu"),
#               fns = list(default = c("sum", "mean")),
#               output = "long")

wagebill_shares_dt <-
compute_fastshare(data = contract_dt,
                  cols = wage_vars,
                  macro_cols = lcu_vars,
                  groups = c("country_code", "year"),
                  fns = "sum",
                  output = "long")

### public sector employment as a share of total employment
worker_dt[, year := lubridate::year(ref_date)]

pubempshare_dt <-
compute_fastshare(data = contract_dt,
                  macro_cols = "labor_force_total",
                  cols = "worker_id",
                  groups = c("country_code", "year"),
                  fns = "count_unique",
                  output = "long")


wagebill_iscodecomp_dt <-
  compute_fastsummary(data = contract_dt,
                      cols = wage_vars,
                      fns = c("sum", "mean", "cp_ratio"),
                      groups = c("occupation_isconame", "occupation_iscocode", "year"),
                      output = "long")

wagebill_occupdecomp_dt <-
  compute_fastsummary(data = contract_dt,
                      cols = wage_vars,
                      fns = c("sum", "mean"),
                      groups = c("occupation_native", "occupation_english", "year"),
                      output = "long")

wagebill_orgdecomp_dt <-
  compute_fastsummary(data = contract_dt,
                      cols = wage_vars,
                      fns = c("sum", "mean"),
                      groups = c("org_id", "year"),
                      output = "long")

### compute annual recruitment patterns over time (still need to compute the reallocations, ask Gali!)

hire_dt <- detect_worker_event(data = worker_dt,
                               id_col = "worker_id",
                               event_type = "hire",
                               start_date = min(worker_dt$ref_date, na.rm = TRUE),
                               end_date = max(worker_dt$ref_date, na.rm = TRUE))

# reallocation_dt <- detect_reallocation(data = worker_dt,
#                                        worker_hire = hire_dt)

recruitment_dt <-
  bind_rows(hire_dt,
            detect_worker_event(data = worker_dt,
                                id_col = "worker_id",
                                event_type = "fire",
                                start_date = min(worker_dt$ref_date, na.rm = TRUE),
                                end_date = max(worker_dt$ref_date, na.rm = TRUE)),
            detect_retirement(data = worker_dt))


## decomposition of public sector employment by industry and occupational group

empdecomp_dt <-
  compute_fastsummary(data = contract_dt,
                      cols = "worker_id",
                      groups = c("year", "occupation_isconame", "occupation_iscocode"),
                      output = "long",
                      fns = "count_unique") |>
  merge(isco,
        by.y = c("unit", "description"),
        by.x = c("occupation_iscocode", "occupation_isconame"),
        all.x = TRUE) |>
  rename(count = "value") %>%
  .[, prop := count / sum(count, na.rm = TRUE), by = "year"]

orgdecomp_dt <-
  compute_fastsummary(data = contract_dt,
                      cols = "worker_id",
                      groups = c("year", "org_id"),
                      output = "long",
                      fns = "count_unique") |>
  rename(count = "value") %>%
  .[, prop := count / sum(count, na.rm = TRUE), by = "year"]


## educational profile of public sector workers by gender and perhaps occupation (find out about which
## rates we need to compute)

combine_dt <- worker_dt[contract_dt, on = c("worker_id", "ref_date", "year")]

educprofile_dt <- combine_dt[, .N, by = .(year, gender, educat7,
                                          occupation_iscocode, occupation_native)]

## distribution of public sector workers by pay grade
mobilityprofile_dt <- combine_dt[, .N, by = .(year, gender, paygrade, seniority, occupation_native, occupation_iscocode)]


## to do:

#1: compute the occupation/industry transition rates
























