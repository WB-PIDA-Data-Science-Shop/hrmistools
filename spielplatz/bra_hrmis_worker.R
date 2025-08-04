# set-up ------------------------------------------------------------------
library(dplyr)
library(readxl)
library(purrr)
library(janitor)
library(lubridate)
library(furrr)
library(pointblank)
library(ggplot2)

devtools::load_all()

set.seed(1789)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"
#
# plan(multisession, workers = 3)

workers_active_list <-
  list.files(
    path = file_path,
    pattern = "^Ativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    ) |>
      clean_names()
  )

workers_inactive_list <-
  list.files(
    path = file_path,
    pattern = "^Inativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    ) |>
      clean_names()
  )
#
# future::plan(sequential)

# harmonization -----------------------------------------------------------
# what we want is two things: (1) uniqueness in the cross-section (entities are uniquely identified) and
# (2) consistency (those unique ids refer to the same entities across the panel)

inactive_inconsistent_cols <- workers_inactive_list |>
  find_inconsistent_colnames() |>
  pull(colnames)

# Worker
#   - Worker ID (contract_id)
#   - Date of Birth (birth_date)
#   - Gender (gender)
#   - Education Attainment (educat7)
#   - Tribe (tribe)
#   - Race (race)
#   - Status (active/retired)

# identify if a dataset contains inconsistent colnames
workers_inactive_list |>
  keep(
    ~ detect_inconsistent_cols(.x, inactive_inconsistent_cols)
  )

dictionary_worker <- tibble(
  from = c(
    "ano_pagamento", "orgao", "mes_referencia", "matricula", "cpf", "data_nascimento", "genero", "escolaridade"
  ),
  to = c(
    "year", "department", "month", "contract_id", "worker_id", "date_birth", "gender", "educat7"
  )
)

# extract worker module
workers_active <- workers_active_list |>
  map(
    \(data){
      data |>
        harmonize_columns(dictionary_worker)
    }
  ) |>
  bind_rows() |>
  filter(month == 9)

# we need to create quality-checks that are specific to each standardized column
# does it match our expectations
workers_active <- workers_active |>
  mutate(
    date_birth = as_date(
      as.numeric(date_birth), origin = "1899-12-30"
    ),
    ref_date = ymd(
      paste(year, month, "01", sep = "-")
    ),
    age = interval(
      date_birth, ref_date
    ) |>
      as.numeric("years") |>
      floor(),
    educat7 = case_when(
      educat7 == "ANALFABETO" ~ "No educat7",
      educat7 %in% c(
        "1 A 4 SERIE DO PRIM. GRAU INCOMPLETO",
        "5 A 8 SERIE DO PRIM. GRAU INCOMPLETO"
      ) ~ "Primary incomplete",
      educat7 %in% c(
        "1 A 4 SERIE DO PRIM. GRAU COMPLETO",
        "5 A 8 SERIE DO PRIM. GRAU COMPLETO"
      ) ~ "Primary complete",
      educat7 == "SEGUNDO GRAU INCOMPLETO" ~ "Secondary incomplete",
      educat7 == "SEGUNDO GRAU COMPLETO" ~ "Secondary complete",
      educat7 %in% c(
        "ESPECIALIZAÇÃO COMPLETO",
        "ESPECIALIZAÇÃO INCOMPLETO",
        "ESPECIALIZA«√O COMPLETO",
        "ESPECIALIZA«√O INCOMPLETO"
      ) ~ "Higher than secondary, not university",
      educat7 %in% c(
        "CURSO SUPERIOR COMPLETO",
        "CURSO SUPERIOR INCOMPLETO",
        "MESTRADO INCOMPLETO"
      ) ~ "University incomplete or complete",
      educat7 == "NA" ~ NA_character_,
      TRUE ~ NA_character_
    )
  )

# check age
workers_active <- workers_active |>
  mutate(
    age = if_else(
      age <= 17 & is.na(educat7),
      NA_real_,
      age
    )
  )

# check for uniqueness per year
worker_quality_check <- create_agent(tbl = workers_active) |>
  rows_distinct(
    columns = contract_id,
    segments = vars(year),
    step_id = "check_unique_contract_id",
    label = "Check for uniqueness of worker ID per year"
  ) |>
  rows_distinct(
    columns = c(contract_id),
    preconditions = . %>% distinct(contract_id, worker_id),
    step_id = "check_unique_worker_and_worker_id",
    label = "Check for uniqueness of worker ID and national ID combinations"
  )

worker_quality_check |>
  interrogate()

# deduplicate -------------------------------------------------------------
# matricula is the contract ID
workers_id <- workers_active |>
  distinct(
    contract_id,
    worker_id
  )

worker_id_duplicate <- workers_id |>
  group_by(worker_id) |>
  summarise(
    n = n_distinct(contract_id),
    .groups = "drop"
  ) |>
  filter(n > 1)

workers_active |>
  inner_join(
    worker_id_duplicate,
    by = c("worker_id")
  ) |>
  arrange(worker_id) |>
  select(
    worker_id,
    contract_id,
    year,
    date_birth,
    gender
  )

# generalize into functions
find_duplicate_ids <- function(data, identifier){
  data |>
    add_count(
      {{identifier}}
    ) |>
    filter(n > 1)
}

contract_id_duplicate_national <- workers_id |>
  group_by(contract_id) |>
  summarise(
    n_worker_id = n_distinct(worker_id),
    correct_worker_id = first(worker_id),
    .groups = "drop"
  )

workers_active |>
  inner_join(
    contract_id_duplicate_national,
    by = c("contract_id")
  ) |>
  arrange(contract_id) |>
  select(
    worker_id,
    contract_id,
    year,
    date_birth,
    gender
  ) |>
  distinct(worker_id)

# decision: override national id with the first national id for each contract_id
# 98 national ids affected
workers_active <- workers_active |>
  left_join(
    contract_id_duplicate_national,
    by = "contract_id"
  ) |>
  mutate(
    worker_id = if_else(
      n_worker_id > 1,
      correct_worker_id,
      worker_id
    )
  ) |>
  ungroup() |>
  select(
    -n_worker_id,
    -correct_worker_id
  )

# extract worker module
# Worker
#   - Worker ID (contract_id)
#   - Date of Birth (birth_date)
#   - Gender (gender)
#   - Education Attainment (educat7)
#   - Tribe (tribe)
#   - Race (race)
#   - Status (active/retired)
workers_module <- workers_active |>
  distinct(
    worker_id,
    ref_date,
    date_birth,
    gender,
    educat7,
    status = "active"
  )

# we need to have a set protocol for how to disambiguate between
# conflicting attributes of the same worker_id
# if there are multiple educat7 values, we take the lowest one
workers_module |> 
  add_count(worker_id, ref_date) |> 
  filter(n > 1)

workers_module |> 
  filter(worker_id == "15676013672")
