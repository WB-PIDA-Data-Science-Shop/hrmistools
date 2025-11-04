### lets compare using data.table and tidyverse for the functions

library(bench)

dt2 <-
  contract_harmonized |>
  slice(rep(1:n(), 10000))


bench::mark(
  compute_summary = compute_summary(
    data = dt2,
    cols = c("base_salary_lcu", "gross_salary_lcu", "net_salary_lcu"),
    fns = c("mean", "sum"),
    output = "long",
    groups = c("occupation_isconame", "paygrade", "year")
  ),
  fast_summary = fast_summary(
    data = dt,
    cols = c("base_salary_lcu", "gross_salary_lcu", "net_salary_lcu"),
    fns = c("mean", "sum"),
    output = "long",
    groups = c("occupation_isconame", "paygrade", "year")
  ),
  check = FALSE
)
