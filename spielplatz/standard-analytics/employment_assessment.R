# reference:
# https://documents1.worldbank.org/curated/en/324801640074379484/pdf/Public-Sector-Employment-and-Compensation-An-Assessment-Framework.pdf

# set-up ------------------------------------------------------------------
library(here)
library(dplyr)
library(readr)
library(ggplot2)
library(ggthemes)

theme_set(
  theme_solarized()
)

# read-in data ------------------------------------------------------------
worker <- read_rds(
  here("inst", "extdata", "bra_hrmis_worker.rds")
)

contract <- read_rds(
  here("spielplatz", "bra_hrmis_contract.rds")
)

# analysis ----------------------------------------------------------------
# 3.6.1. percentage of staff receiving highest performance ratings

# 3.6.2. annual, within-grade pay increases
contract_ppp <- contract |>
  convert_constant_ppp(
    ends_with("lcu")
  )

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
    pct_change
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
  labs(
    x = "Year",
    y = "Annual Change (%)",
    title = "Annual Change in Median Salary by Paygrade"
  )

# 3.6.3. percentage of staff receiving a performance bonus

# 3.6.4. performance bonus as a percentage of basic pay
