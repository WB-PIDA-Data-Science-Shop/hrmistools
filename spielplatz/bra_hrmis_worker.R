# set-up ------------------------------------------------------------------
library(dplyr)
library(readxl)
library(purrr)
library(janitor)
library(furrr)

devtools::load_all()

plan(multisession, workers = 6)
set.seed(1789)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"

workers_active_list <-
  list.files(path = file_path,
             pattern = "^Ativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(
    \(file) read_xlsx(file, na = c("", "-")) |>
      clean_names()
  )

workers_inactive_list <-
  list.files(path = file_path,
             pattern = "^Inativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(
    \(file) read_xlsx(file, na = c("", "-")) |>
      clean_names()
  )

# harmonization -----------------------------------------------------------
# what we want is two things: (1) uniqueness in the cross-section (entities are uniquely identified) and
# (2) consistency (those unique ids refer to the same entities across the panel)

inactive_inconsistent_cols <- workers_inactive_list |>
  find_inconsistent_colnames() |>
  pull(colnames)

detect_inconsistent_cols <- function(data, inconsistent_cols) {
  n_inconsistent_cols <- data |>
    select(
      any_of(inconsistent_cols)
    ) |>
    ncol()

  if_else(
    n_inconsistent_cols > 0,
    TRUE,
    FALSE
  )
}

# Worker
#   - Worker ID (worker_id)
#   - Organization ID (org_id)
#   - Timestamp (org_date)
#   - Date of Birth (birth_date)
#   - Gender (gender)
#   - Education Attainment (educat4, educat5, educat7, and educat10)
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

dictionary <- tibble(
  from = c("ano_pagamento", "mes_referencia", "matricula", "cpf", "data_nascimento", "genero", "escolaridade"),
  to = c("year", "month", "worker_id", "national_id", "date_birth", "gender", "education")
)

# extract worker module
workers_active <- workers_active_list |>
  map(
    \(data){
      data |>
        harmonize_columns(dictionary)
      }
  ) |>
  bind_rows()

workers_active |>
  glimpse()
