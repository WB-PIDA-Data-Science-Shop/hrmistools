# set-up ------------------------------------------------------------------
library(dplyr)
library(readxl)
library(purrr)
library(furrr)

plan(multisession, workers = 6)
set.seed(1789)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"

workers_active_list <-
  list.files(path = file_path,
             pattern = "^Ativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(
    \(file) read_xlsx(file, na = c("", "-"))
  )

workers_inactive_list <-
  list.files(path = file_path,
             pattern = "^Inativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(
    \(file) read_xlsx(file, na = c("", "-"))
  )

# harmonization -----------------------------------------------------------
# what we want is two things: (1) uniqueness in the cross-section (entities are uniquely identified) and
# (2) consistency (those unique ids refer to the same entities across the panel)

workers_inactive_list |>
  find_inconsistent_colnames()
