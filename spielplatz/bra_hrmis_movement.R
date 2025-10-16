# set-up ------------------------------------------------------------------
library(readr)
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)
library(here)

# read-in data ------------------------------------------------------------
contract_df <- read_rds(
  here("spielplatz", "bra_hrmis_contract.rds")
)

worker_df <- read_rds(
  here("inst/extdata/bra_hrmis_worker.rds")
)

# infer movement ----------------------------------------------------------
# the movement table should have:
# 1) contract_id
# 2) ref_date
# 3) event type: hire, dismissal, retirement, reallocation.

# 1. infer hire
# a hire is defined as a new contract when the worker_df
# was not present in the dataset in the previous period
contract_hire_df <- contract_df |>
  # only retain contracts when worker_df was active
  # at any point in our sample
  inner_join(
    worker_df |>
      group_by(worker_id) |>
      filter(any(status == "active")) |>
      ungroup() |>
      distinct(worker_id),
    by = "worker_id"
  ) |>
  rename(
    ref_date = org_date
  ) |>
  filter(
    ref_date > min(ref_date)
  ) |>
  group_by(worker_id, contract_id) |>
  summarise(
    ref_date = first(ref_date),
    .groups = "drop"
  )

# if the worker_df does not appear in the previous ref_date, this is a hire
event_hire_df <- contract_hire |>
  mutate(
    ref_date_lag = ref_date - years(1)
  ) |>
  anti_join(
    worker_df |> select(worker_id, ref_date),
    by = c("worker_id", "ref_date_lag" = "ref_date")
  ) |>
  mutate(
    type_event = "hire"
  ) |>
  select(-ref_date_lag)

event_hire_test_df <- detect_hire_events(
  worker_df,
  contract_df
)

worker_interval_df <- worker_df |>
  head(1e5) |>
  arrange(
    worker_id, ref_date
  ) |>
  calculate_date_intervals(
    ref_date,
    group_vars = worker_id
  )

worker_df |>
  filter(status == "active") |>
  arrange(worker_id, ref_date) |>
  group_by(worker_id) |>
  # this is creating issues
  complete(
    ref_date = seq(ymd("2007-09-01"), ymd("2018-01-01"), by = "year")
  ) |>
  mutate(
    status_lag = lag(status),
    type_event = if_else(
      status == "active" & is.na(status_lag),
      "hire",
      "no hire"
    )
  ) |>
  ungroup()


# 2. infer fire
contract_fire_df <- contract |>
  # only retain contracts when worker_df was active
  # at any point in our sample
  inner_join(
    worker_df |>
      group_by(worker_id) |>
      filter(any(status == "active")) |>
      ungroup() |>
      distinct(worker_id),
    by = "worker_id"
  ) |>
  rename(
    ref_date = org_date
  ) |>
  filter(
    ref_date < max(ref_date)
  ) |>
  group_by(worker_id, contract_id) |>
  summarise(
    ref_date = last(ref_date),
    .groups = "drop"
  )

# if the worker_df does not appear in the next ref_date, this is a firing
event_fire_df <- contract_fire |>
  mutate(
    ref_date_lead = ref_date + years(1)
  ) |>
  anti_join(
    worker_df |> select(worker_id, ref_date),
    by = c("worker_id", "ref_date_lead" = "ref_date")
  ) |>
  mutate(
    type_event = "fire"
  ) |>
  select(-ref_date_lead)

# 3. infer retirement
# if the worker_df appears as retired in the next ref_date, this is a retirement
worker_retired_df <- worker_df |>
  group_by(worker_id) |>
  mutate(
    lag_status = lag(status)
  ) |>
  ungroup() |>
  filter(
    status == "inactive" &
      lag_status == "active"
  )

event_retire_df <- worker_retired |>
  select(worker_id, ref_date) |>
  mutate(
    type_event = "retire"
  )

# 4. infer movement
# rename orgao id
contract_rename_org_df <- contract |>
  rename(
    ref_date = org_date
  ) |>
  inner_join(
    worker_df |> filter(status == "active"),
    by = c("worker_id", "ref_date"),
    relationship = "many-to-many"
  ) |>
  mutate(
    org_id = str_remove_all(org_id, "\\d+|-")
  )

# option 1: contract level
contract_reallocation_df <- contract_rename_org |>
  arrange(ref_date, contract_id) |>
  group_by(contract_id) |>
  mutate(
    lag_org_id = lag(org_id, order_by = ref_date)
  ) |>
  ungroup() |>
  mutate(
    type_event = if_else(
      org_id != lag_org_id,
      "reallocation",
      NA_character_
    )
  ) |>
  filter(
    type_event == "reallocation"
  ) |>
  select(
    org_id, worker_id, contract_id, ref_date, type_event
  )

# option 2: worker_df level
worker_reallocation_df <- contract_rename_org |>
  arrange(worker_id, ref_date, org_id) |>
  select(worker_id, ref_date, org_id) |>
  group_by(worker_id, ref_date) |>
  nest(
    .key = "org_id_nested"
  ) |>
  group_by(worker_id) |>
  # if the set of organizations worked for in the previous reference data
  # do not match identically, it is a reallocation
  mutate(
    type_event = map2_chr(
      org_id_nested,
      lag(org_id_nested),
      ~ ifelse(
        !identical(.x, .y),
        "reallocation",
        "no reallocation"
      )
    )
  ) |>
  ungroup() |>
  # remove hires
  anti_join(
    event_hire |>
      distinct(worker_id, ref_date),
    by = c("worker_id", "ref_date")
  ) |>
  # remove earliest ref_date in sample
  filter(
    ref_date > min(ref_date)
  )

