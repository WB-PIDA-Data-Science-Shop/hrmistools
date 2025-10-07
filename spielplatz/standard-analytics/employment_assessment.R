# reference:
# https://documents1.worldbank.org/curated/en/324801640074379484/pdf/Public-Sector-Employment-and-Compensation-An-Assessment-Framework.pdf

# set-up ------------------------------------------------------------------
library(here)
library(dplyr)
library(readr)
library(ggplot2)
library(purrr)
library(ggthemes)

theme_set(
  theme_clean()
)

devtools::load_all()

# read-in data ------------------------------------------------------------
worker <- read_rds(
  here("inst", "extdata", "bra_hrmis_worker.rds")
)

contract <- read_rds(
  here("spielplatz", "bra_hrmis_contract.rds")
)

# process data ------------------------------------------------------------
contract_ppp <- contract |>
  convert_constant_ppp(
    ends_with("lcu"),
    macro_indicators |> mutate(year = as.numeric(year))
  )

contract_summary_ppp <- contract_ppp |>
  compute_grouped_summary(
    group_vars = c(year, paygrade),
    cols = c(base_salary_ppp, allowance_ppp)
  )

# analysis ----------------------------------------------------------------
# 3.6.1. percentage of staff receiving highest performance ratings
# N/A

# 3.6.2. annual, within-grade pay increases
contract_ppp |>
  filter(
    paygrade %in% seq(1, 4, 1)
  ) |>
  mutate(
    year = as.numeric(year)
  ) |>
  group_by(
    paygrade,
    year
  ) |>
  summarise(
    mean_base_salary_ppp = mean(base_salary_ppp),
    median_base_salary_ppp = median(base_salary_ppp)
  ) |>
  ggplot_point_line(
    year,
    median_base_salary_ppp,
    group = paygrade
  ) +
  scale_color_brewer(
    name = "Paygrade",
    palette = "Paired"
  ) +
  theme(
    legend.position = "bottom"
  ) +
  labs(
    x = "Year",
    y = "Median Salary (Constant International Dollars)"
  )

# as growth rates
contract_ppp |>
  filter(
    paygrade %in% seq(1, 4, 1)
  ) |>
  mutate(
    year = as.integer(year)
  ) |>
  group_by(paygrade, year) |>
  summarise(
    median_base_salary_ppp = median(base_salary_ppp, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(paygrade, year) |>
  group_by(paygrade) |>
  mutate(
    pct_change = 100 * (median_base_salary_ppp - lag(median_base_salary_ppp))/ lag(median_base_salary_ppp)
  ) |>
  ggplot_point_line(
    year,
    pct_change,
    label = round(pct_change, 1)
  ) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  scale_color_brewer(
    name = "Paygrade", palette = "Paired"
  ) +
  scale_x_continuous(
    breaks = scales::pretty_breaks()
  ) +
  theme(
    legend.position = "bottom"
  ) +
  facet_wrap(
    vars(paygrade)
  ) +
  coord_cartesian(
    ylim = c(-10, 40)
  ) +
  labs(
    x = "Year",
    y = "Annual Change (%)",
    title = "Annual Change in Median Salary by Paygrade"
  )

# 3.6.3. percentage of staff receiving a performance bonus
performance_bonus_worker <- contract |>
  filter(
    !is.na(allowance_lcu)
  ) |>
  group_by(year) |>
  summarise(
    total_performance = n_distinct(worker_id)
  )

contract |>
  group_by(year) |>
  summarise(
    total = n_distinct(worker_id)
  ) |>
  left_join(
    performance_bonus_worker,
    by = "year"
  ) |>
  mutate(
    year = as.numeric(year),
    share_performance = total_performance/total
  ) |>
  ggplot_point_line(
    year,
    share_performance
  ) +
  scale_y_continuous(
    labels = scales::percent_format()
  ) +
  labs(
    x = "Year",
    y = "Share of personnel"
  )

# 3.6.4. performance bonus as a percentage of basic pay
contract_summary_ppp |>
  mutate(
    share_allowance = mean_allowance_ppp/mean_base_salary_ppp
  ) |>
  filter(
    paygrade %in% seq(1, 4, 1)
  ) |>
  ggplot_point_line(
    year,
    share_allowance,
    group = paygrade
  ) +
  facet_wrap(
    vars(paygrade)
  ) +
  scale_color_brewer(
    name = "Paygrade", palette = "Paired"
  ) +
  scale_y_continuous(
    labels = scales::percent_format()
  ) +
  labs(
    x = "Year",
    y = "Share of personnel"
  )

# 3.6.6. hardship allowance and percentage of staff receiving it
# n/a: no data on hardship available


