################################################################################
######## CREATING A UNIQUE CONTRACT DATASET FROM THE ALAGOAS HRMIS DATA ########
################################################################################

### install package from github if not already available
# remotes::install_github("worldbank/dlw")

library(dplyr)
library(readxl)
library(purrr)
library(furrr)
library(writexl)
# library(dlw)
library(pointblank)

# read-in data ------------------------------------------------------------
file_path <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"
#
# token_chr <- readLines("spielplatz/dlw_token.txt")
#
# dlw_set_token(token_chr)
#
# gmdsupport_dt <- dlw_get_gmd_support()

plan(multisession, workers = 6)

contract_active_list <-
  list.files(
    path = file_path,
    pattern = "^Ativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  future_map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    )
  )

contract_inactive_list <-
  list.files(
    path = file_path,
    pattern = "^Inativos_[0-9]{4}\\.xlsx$",
    full.names = T
  ) |>
  future_map(
    \(file) read_xlsx(
      file, na = c("", "-"), col_types = "text"
    )
  )

#### quickly harmonize column classes
active_alagoas_tbl <- bind_rows(contract_active_list)
inactive_alagoas_tbl <- bind_rows(contract_inactive_list)

#### apparently we ought to keep only September
active_alagoas_tbl <-
  active_alagoas_tbl |>
  filter(MES_REFERENCIA == 9)

##### now we are ready to harmonize!

###### first let us confirm our data is unique at the matricula level
###### lets check how contracts there are to unique workers
active_alagoas_tbl |>
  group_by(ANO_PAGAMENTO) |>
  summarize(unique_cpf = length(unique(CPF)), nobs = length(CPF))

active_alagoas_tbl |>
  group_by(ANO_PAGAMENTO) |>
  summarize(unique_mtr = length(unique(MATRICULA)), nobs = length(MATRICULA))

### first let us figure out how many contracts each person has per year
contract_alagoas_tbl <-
  bind_rows(active_alagoas_tbl |>
              transmute(contract_id = MATRICULA,
                        worker_id = CPF,
                        org_id = paste(ORGAO, COD_ORGAO, ANO_PAGAMENTO, sep = "-"),
                        org_date = as.Date(paste(ANO_PAGAMENTO, MES_REFERENCIA, "01", sep = "-")),
                        country_code = "BRA",
                        year = ANO_PAGAMENTO,
                        base_salary_lcu = SALARIO_BASE,
                        gross_salary_lcu = SALARIO_BRUTO,
                        net_salary_lcu = SALARIO_LIQUIDO,
                        spdef = NA,
                        whours = as.numeric(JORNADA),
                        country_code = "BRA",
                        country_name = "Brazil",
                        adm1_name = "Alagoas",
                        adm1_code = "AL",
                        start_date = as.Date(as.integer(DATA_ADMISSAO),
                                             origin = "1899-12-30"),
                        end_date = NA),
            inactive_alagoas_tbl |>
              transmute(contract_id = MATRICULA,
                        worker_id = CPF,
                        org_id = paste(ORGAO, "000000", sep = "-"),
                        org_date = as.Date(paste(ANO_PAGAMENTO, MES_REFERENCIA, "01", sep = "-")),
                        country_code = "BRA",
                        year = ANO_PAGAMENTO,
                        base_salary_lcu = NA,
                        gross_salary_lcu = VALOR_BRUTO,
                        net_salary_lcu = VALOR_LIQUIDO,
                        spdef = NA,
                        whours = 0,
                        country_code = "BRA",
                        country_name = "Brazil",
                        adm1_name = "Alagoas",
                        adm1_code = "AL",
                        start_date = as.Date(as.integer(DATA_ADMISSAO),
                                             origin = "1899-12-30"),
                        end_date = as.Date(as.integer(DATA_APOSENTADORIA),
                                           origin = "1899-12-30")))

contract_alagoas_tbl <-
  contract_alagoas_tbl %>%
  mutate(across(
    c(base_salary_lcu, gross_salary_lcu, net_salary_lcu, whours),
    ~ as.numeric(.)
  ))

contract_alagoas_tbl_clean <-
  contract_alagoas_tbl |>
  convert_constant_ppp(
    ends_with("_lcu")
  ) |>
  rename_with(
    ~ str_replace(., "_lcu", "")
  )

### include cpi, ppp and temporal and spatial pricing data for Brazil
year_list <-
  contract_alagoas_tbl[["start_date"]] |>
  lubridate::year() |>
  unique()

qualitycheck_contractmod(contract_tbl = contract_alagoas_tbl)

saveRDS(contract_alagoas_tbl,
        "spielplatz/bra_hrmis_contract.rds")
