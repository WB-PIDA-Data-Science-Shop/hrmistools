
### 3.1
wage_vars <- c("gross_salary_lcu",
               "net_salary_lcu",
               "base_salary_lcu")

lcu_vars <- colnames(macro_indicators)[grepl("_lcu",
                                             colnames(macro_indicators))]

contract_harmonized <-
  contract_harmonized |>
  mutate(year = lubridate::year(ref_date)) |>
  as.data.table()


# wage bill by gdp, expenditures, revenues by year
# compute_share(data = contract_harmonized,
#               cols = wage_vars,
#               groups = c("country_code", "year"),
#               macro_cols = c("gdp_lcu", "pexpenditure_lcu",
#                              "prevenue_lcu", "taxrevenue_lcu"),
#               fns = list(default = c("sum", "mean")),
#               output = "long")

wagebill_shares_df <-
compute_fastshare(data = contract_harmonized,
                  cols = wage_vars,
                  macro_cols = lcu_vars,
                  groups = c("country_code", "year"),
                  fns = "sum",
                  output = "long")

wagebill_decomp <-
compute_summary(data = contract_harmonized,
                cols = wage_vars,
                fns = c("sum", "mean"),
                groups = c("occupation_isconame", "occupation_iscocode", "year"),
                output = "long")

# wage bill decomposed by administrative and industrial classification
compute_summary(data = contract_df,
                cols = list(vars = wage_vars,
                            groups = c("year", "occupation_isconame",
                                       "occupation_iscocode")),
                fns = list(default = c("sum", "mean", "median", "cv"),
                           user = NULL),
                output = "long")

# industry and occupational distribution of public sector employment
compute_summary(data = contract_df,
                cols = list(vars = "worker_id",
                            groups = c("year", "occupation_isconame",
                                       "occupation_iscocode")),
                fns = list(default = NULL,
                           user = list(n_unique_workers = ~dplyr::n_distinct(.x, na.rm = T))),
                output = "long")


# public sector employment share of total employment, paid employment, formal paid employment
compute_share(data = contract_df,
              cols = list(vars = "worker_id",
                          groups = c("country_code","year")),
              macro_cols = c("emp_pop", "salaried_pop"),
              fns = list(user = list(n_unique_workers = ~dplyr::n_distinct(.x, na.rm = T))),
              output = "long")


## educational profile of public-sector workers
compute_summary(
  data = worker_df,
  cols = list(vars = "worker_id",
              groups = c("educat7", "gender")),
  fns = list(user = list(n_workers = ~dplyr::n_distinct(.x)))
)

## distribution of public sector workers by pay grade
compute_summary(
  data = contract_df,
  cols = list(vars = "worker_id",
              groups = c("paygrade", "year")),
  fns = list(user = list(n_workers = ~dplyr::n_distinct(.x)))
)

## public sector compression ratios
compute_summary(data = contract_df,
                cols = list(vars = wage_vars,
                            groups = c("year", "occupation_isconame",
                                       "occupation_iscocode")),
                fns = list(default = c("cv"),
                           user = list(cp_ratio = ~cp_ratio(.x))),
                output = "wide")












