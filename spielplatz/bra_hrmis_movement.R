# set-up ------------------------------------------------------------------
library(readr)
library(dplyr)
library(lubridate)
library(here)

# read-in data ------------------------------------------------------------
contract <- read_rds(
  here("spielplatz", "bra_hrmis_contract.rds")
)

worker <- read_rds(
  here("inst/extdata/bra_hrmis_worker.rds")
)

# infer movement ----------------------------------------------------------
# the movement table should have:
# 1) contract_id
# 2) ref_date
# 3) event type: hire, dismissal, retirement, reallocation.

# 1. infer hire
# a hire is defined as a new contract when the worker
# was not present in the dataset in the previous period
contract_hire <- contract |>
  # only retain contracts when worker was active
  # at any point in our sample
  inner_join(
    worker |>
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

# if the worker does not appear in the previous ref_date, this is a hire
event_hire <- contract_hire |>
  mutate(
    ref_date_lag = ref_date - years(1)
  ) |>
  anti_join(
    worker |> select(worker_id, ref_date),
    by = c("worker_id", "ref_date_lag" = "ref_date")
  ) |>
  mutate(
    type_event = "hire"
  ) |>
  select(-ref_date_lag)

# 2. infer fire
contract_fire <- contract |>
  # only retain contracts when worker was active
  # at any point in our sample
  inner_join(
    worker |>
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

# if the worker does not appear in the next ref_date, this is a firing
event_fire <- contract_fire |>
  mutate(
    ref_date_lead = ref_date + years(1)
  ) |>
  anti_join(
    worker |> select(worker_id, ref_date),
    by = c("worker_id", "ref_date_lead" = "ref_date")
  ) |>
  mutate(
    type_event = "fire"
  ) |>
  select(-ref_date_lead)

# 3. infer retirement
# if the worker appears as retired in the next ref_date, this is a retirement
worker_retired <- worker |>
  group_by(worker_id) |>
  mutate(
    lag_status = lag(status)
  ) |>
  ungroup() |>
  filter(
    status == "inactive" &
      lag_status == "active"
  )

event_retire <- worker_retired |>
  select(worker_id, ref_date) |>
  mutate(
    type_event = "retire"
  )

# 4. infer movement
# rename orgao id
contract_rename_org <- contract |>
  mutate(
    org_id = str_remove_all(org_id, "\\d+|-"),
    ref_date = org_date
  )

contract_reallocation <- contract_rename_org |>
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
