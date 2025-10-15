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

# first infer hire
# a hire is defined as a new contract when the worker
# was not present in the dataset in the previous period
contract_hire <- contract |>
  # only retain contracts when worker was active
  inner_join(
    worker |> filter(status == "active"),
    by = "worker_id"
  ) |>
  rename(
    ref_date = org_date
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

