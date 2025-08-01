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

plan(multisession, workers = 3)

workers_active_list <-
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

workers_inactive_list <-
  list.files(
    path = file_path,
    pattern = "^Inativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  future_map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    ) |>
      clean_names()
  )

future::plan(sequential)

# harmonization -----------------------------------------------------------
# what we want is two things: (1) uniqueness in the cross-section (entities are uniquely identified) and
# (2) consistency (those unique ids refer to the same entities across the panel)

inactive_inconsistent_cols <- workers_inactive_list |>
  find_inconsistent_colnames() |>
  pull(colnames)

# Worker
#   - Worker ID (worker_id)
#   - Organization ID (org_id)
#   - Timestamp (org_date)
#   - Date of Birth (birth_date)
#   - Gender (gender)
#   - Education Attainment (educat7)
#   - Tribe (tribe)
#   - Race (race)
#   - Status (active/retired)
#   - Country Code, (country_code)
#   - Country Name, (country_name)
#   - Administration 1 Name, (adm1_name)
#   - Administration 1 Code, (adm1_code)

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
    "year", "department", "month", "worker_id", "national_id", "date_birth", "gender", "educat7"
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
    columns = c(year, worker_id),
    step_id = "check_unique_worker_id",
    label = "Check for uniqueness of worker ID per year"
  ) |>
  rows_distinct(
    columns = c(worker_id),
    preconditions = . %>% distinct(worker_id, national_id),
    step_id = "check_unique_worker_and_national_id",
    label = "Check for uniqueness of worker ID and national ID combinations"
  )

worker_quality_check |>
  interrogate()

workers_id <- workers_active |>
  distinct(
    worker_id, national_id
  )

# matricula is the worker ID

national_id_duplicate <- workers_id |>
  group_by(national_id) |>
  summarise(
    n = n_distinct(worker_id),
    .groups = "drop"
  ) |>
  filter(n > 1)

workers_id |>
  group_by(worker_id) |>
  summarise(
    n = n_distinct(national_id),
    .groups = "drop"
  ) |>
  filter(n > 1)

national_id_duplicate |>
  inner_join(
    workers_active
  ) |>
  arrange(
    national_id
  )

workers_active |>
  filter(worker_id == "12946")
