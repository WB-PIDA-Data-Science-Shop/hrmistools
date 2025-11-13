library(dplyr)
library(readxl)
library(furrr)
library(writexl)
library(digest)
library(labourR)
library(here)

devtools::load_all()

dir.create(
  here("inst", "extdata"),
  recursive = TRUE
)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"

plan(multisession, workers = 6)

contract_active_list <-
  list.files(path = file_path,
             pattern = "^Ativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(\(file) read_xlsx(file, na = c("", "-"), col_types = "text"))

contract_inactive_list <-
  list.files(path = file_path,
             pattern = "^Inativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  future_map(\(file) read_xlsx(file, na = c("", "-"), col_types = "text"))

# combine data ------------------------------------------------------------
contract_active <- contract_active_list |>
  bind_rows() |>
  filter(
    MES_REFERENCIA == 9 &
      ANO_PAGAMENTO >= 2014
  )

contract_inactive <- contract_inactive_list |>
  bind_rows() |>
  filter(
    MES_REFERENCIA == 9 &
      ANO_PAGAMENTO >= 2014
  )

bra_hrmis <- contract_active |>
  bind_rows(
    contract_inactive
  )

# anonymize the CPF
bra_hrmis <- bra_hrmis |>
  mutate(
    CPF = map_chr(CPF, digest, algo = "sha256")
  )

# contract module ---------------------------------------------------------\

# worker module


# write-out ---------------------------------------------------------------
usethis::use_data(bra_hrmis, overwrite = TRUE)
