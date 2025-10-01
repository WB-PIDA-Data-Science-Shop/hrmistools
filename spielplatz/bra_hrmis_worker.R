# set-up ------------------------------------------------------------------
library(dplyr)
library(readxl)
library(purrr)
library(janitor)
library(lubridate)
library(furrr)
library(pointblank)
library(tibble)
library(here)
library(readr)
library(ggplot2)

devtools::load_all()

set.seed(1789)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"

plan(multisession, workers = 3)

worker_active_list <-
  list.files(
    path = file_path,
    pattern = "^Ativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  future_map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    ) |>
      clean_names()
  )

worker_inactive_list <-
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

future::plan(sequential)

# harmonization -----------------------------------------------------------
# what we want is two things: (1) uniqueness in the cross-section (entities are uniquely identified) and
# (2) consistency (those unique ids refer to the same entities across the panel)

inactive_inconsistent_cols <- worker_inactive_list |>
  find_inconsistent_colnames() |>
  pull(colnames)

# identify if a dataset contains inconsistent colnames
worker_inactive_list |>
  keep(
    ~ detect_inconsistent_cols(.x, inactive_inconsistent_cols)
  )

# harmonize column names
dictionary_worker <- tibble(
  from = c(
    "ano_pagamento", "orgao", "mes_referencia", "matricula", "cpf", "data_nascimento", "genero", "escolaridade"
  ),
  to = c(
    "year", "department", "month", "contract_id", "worker_id", "birth_date", "gender", "education"
  )
)

worker_active <- worker_active_list |>
  map(
    \(data){
      data |>
        harmonize_columns(dictionary_worker)
    }
  ) |>
  bind_rows() |>
  # extract the month of september
  filter(month == 9)

# we need to create quality-checks that are specific to each standardized column
# does it match our expectations
worker_active <- worker_active |>
  mutate(
    birth_date = as_date(
      as.numeric(birth_date), origin = "1899-12-30"
    ),
    ref_date = ymd(
      paste(year, month, "01", sep = "-")
    ),
    age = interval(
      birth_date, ref_date
    ) |>
      as.numeric("years") |>
      floor(),
    educat7 = case_when(
      education == "ANALFABETO" ~ "No education",
      education %in% c(
        "1 A 4 SERIE DO PRIM. GRAU INCOMPLETO",
        "5 A 8 SERIE DO PRIM. GRAU INCOMPLETO"
      ) ~ "Primary incomplete",
      education %in% c(
        "1 A 4 SERIE DO PRIM. GRAU COMPLETO",
        "5 A 8 SERIE DO PRIM. GRAU COMPLETO"
      ) ~ "Primary complete",
      education == "SEGUNDO GRAU INCOMPLETO" ~ "Secondary incomplete",
      education == "SEGUNDO GRAU COMPLETO" ~ "Secondary complete",
      education %in% c(
        "ESPECIALIZAÇÃO COMPLETO",
        "ESPECIALIZAÇÃO INCOMPLETO",
        "ESPECIALIZA«√O COMPLETO",
        "ESPECIALIZA«√O INCOMPLETO"
      ) ~ "Higher than secondary, not university",
      education %in% c(
        "CURSO SUPERIOR COMPLETO",
        "CURSO SUPERIOR INCOMPLETO",
        "MESTRADO INCOMPLETO"
      ) ~ "University incomplete or complete",
      education == "NA" ~ NA_character_,
      TRUE ~ NA_character_
    ),
    educat7 = factor(
      educat7,
      levels = c(
        "No education", "Primary incomplete", "Primary complete",
        "Secondary incomplete", "Secondary complete",
        "Higher than secondary but not university",
        "University incomplete or complete"
      )
    )
  )

# check age
worker_active <- worker_active |>
  mutate(
    age = if_else(
      age <= 17 & is.na(educat7),
      NA_real_,
      age
    )
  )

# check for uniqueness per year
worker_quality_check <- create_agent(tbl = worker_active) |>
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
worker_id <- worker_active |>
  distinct(
    contract_id,
    worker_id
  )

worker_id_multiple_contracts <- worker_id |>
  group_by(worker_id) |>
  summarise(
    n_contract = n_distinct(contract_id),
    .groups = "drop"
  ) |>
  filter(n_contract > 1)

# there are 9.4 thousand workers with multiple contracts
worker_id_multiple_contracts |>
  count(n_contract)

# verify worker ids
worker_active |>
  inner_join(
    worker_id_duplicate,
    by = c("worker_id")
  ) |>
  arrange(worker_id) |>
  select(
    worker_id,
    contract_id,
    year,
    birth_date,
    gender
  )

contract_id_duplicate_national <- worker_id |>
  group_by(contract_id) |>
  summarise(
    n_worker_id = n_distinct(worker_id),
    correct_worker_id = first(worker_id),
    .groups = "drop"
  )

# decision: override national id with the first national id for each contract_id
# 98 national ids affected
worker_active <- worker_active |>
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

# extract worker module ---------------------------------------------------
# Worker
#   - Reference date (ref_date)
#   - Worker ID (contract_id)
#   - Date of Birth (birth_date)
#   - Gender (gender)
#   - Education Attainment (educat7)
#   - Tribe (tribe)
#   - Race (race)
#   - Status (active/retired)
worker_module <- worker_active |>
  group_by(worker_id, ref_date) |>
  summarise(
    birth_date = case_when(
      birth_date <= as_date("2010-01-01") ~ min(birth_date),
      TRUE ~ NA_Date_
    ),
    educat7 = dedup_education(educat7),
    .groups = "drop"
  )

#
worker_module_gender <- worker_active |>
  dedup_value_panel(
    gender,
    worker_id, ref_date
  )

# if the number of rows for both match, left join
worker_module <- worker_module |>
  left_join(
    worker_module_gender,
    by = c("worker_id", "ref_date")
  ) |>
  mutate(
    status = "active"
  )

# create a function that does a conformity assessment
# and fill out missing columns with NA
dictionary_worker_cols <- c(
  "ref_date", "worker_id", "birth_date", "gender", "educat7", "tribe", "race", "status"
)

worker_module_clean <- worker_module |>
  complete_columns(
    dictionary_worker_cols
  )

worker_module_clean |>
  write_rds(
    here("data", "bra", "bra_hrmis_worker.rds"),
    compress = "gz"
  )
