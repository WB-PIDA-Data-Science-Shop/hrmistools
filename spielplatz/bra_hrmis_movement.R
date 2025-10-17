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
worker_hire_df <- worker_df |>
  detect_worker_event(
    id_col = "worker_id",
    event_type = "hire",
    start_date = "2007-09-01",
    end_date = "2018-09-01"
  )

# 2. infer fire
worker_fire_df <- worker_df |>
  detect_worker_event(
    id_col = "worker_id",
    event_type = "fire",
    start_date = "2007-09-01",
    end_date = "2018-09-01"
  )

# 3. infer retirement
# if the worker_df appears as retired in the next ref_date, this is a retirement
worker_retired_df <- worker_df |>
  detect_retirement()

# 4. infer movement
# rename orgao id
contract_rename_org_df <- contract_df |>
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
worker_reallocation_df <- contract_rename_org_df |>
  detect_reallocation(
    worker_hire = worker_hire_df
  )
