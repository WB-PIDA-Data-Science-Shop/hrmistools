################################################################################
######## TESTING THE INTENDED HARMONIZATION PROCESS WITH THE BRAZIL DATA #######
################################################################################

paklist <- c("tidyverse", "polyglotr")

## silently load the libraries
invisible(lapply(paklist,
                 function(x){

                   library(x, character.only = TRUE, verbose = FALSE)

                   }))

#### lets put together the organization module of the Brazil data
fileloc <- "//egvpi/egvpi/data/harmonization/HRM/BRA/data-raw/6. Wage Bill AL/3. Microdados"


### read in the data
active_contract_tbl <-
  list.files(path = fileloc,
             pattern = "^Ativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  map(readxl::read_xlsx)

inactive_contract_tbl <-
  list.files(path = fileloc,
             pattern = "^Inativos_[0-9]{4}\\.xlsx$",
             full.names = T) |>
  map(readxl::read_xlsx)


### lets quickly label the raw data

act_list <-
  c(ANO_PAGAMENTO = "Year of payment (e.g., 2022)",
    MES_REFERENCIA = "Reference month (e.g., 1–12)",
    MATRICULA = "Employee registration number",
    CPF = "CPF (taxpayer ID)",
    DATA_NASCIMENTO = "Date of birth",
    GENERO = "Gender (M/F)",
    ESCOLARIDADE = "Education level",
    DATA_ADMISSAO = "Date of hiring / admission",
    ADMINISTRACAO = "Type of administration (e.g., direct, indirect, foundation)",
    TIPO_CONTRATO = "Type of contract (e.g., permanent, temporary, commissioned)",
    GRUPO = "Group (could be a functional or career group)",
    COD_ORGAO = "Organization code",
    ORGAO = "Organization name",
    CARREIRA = "Career (broad classification of occupation)",
    CARGO = "Position (specific job title)",
    JORNADA = "Work schedule (hours per week)",
    CLASSE = "Class (pay grade)",
    NIVEL = "Level within the class",
    DATA_ULT_PROGRESSAO = "Date of last career progression / promotion",
    SALARIO_BASE = "Base salary",
    CONTRIBUICAO_PREVIDENCIA = "Social security contribution withheld",
    ADICIONAL_TEMPO_SERVICO = "Length-of-service bonus",
    COMISSAO = "Commission or position of trust allowance",
    ABONO_PERMANENCIA = "Permanence bonus (when eligible for retirement but staying active)",
    DECISAO_JUDICIAL = "Judicial decision payments (court-ordered)",
    DEMAIS_GRATIFICACOES_TRANSITORIAS = "Other temporary bonuses / gratifications",
    DEMAIS_GRATIFICACOES_CARREIRA = "Other career-related bonuses / gratifications",
    SALARIO_BRUTO = "Gross salary (before deductions)",
    SALARIO_LIQUIDO = "Net salary (after deductions)")

inact_list <- c(
  ANO_PAGAMENTO = "Year of payment (e.g., 2022)",
  MES_REFERENCIA = "Reference month (e.g., 1–12)",
  MATRICULA = "Employee registration number",
  CPF = "CPF (taxpayer ID)",
  DATA_NASCIMENTO = "Date of birth",
  GENERO = "Gender (M/F)",
  ESCOLARIDADE = "Education level",
  DATA_ADMISSAO = "Date of hiring / admission",
  DATA_APOSENTADORIA = "Date of retirement",
  ADMINISTRACAO = "Type of administration (e.g., direct, indirect, foundation)",
  TIPO_CONTRATO = "Type of contract before retirement (e.g., permanent, temporary, commissioned)",
  GRUPO = "Group (career or functional group)",
  VALOR_BRUTO = "Gross pension amount (before deductions)",
  VALOR_LIQUIDO = "Net pension amount (after deductions)",
  ORGAO = "Organization name prior to retirement",
  CARGO = "Position held before retirement",
  CLASSE = "Class (pay grade) prior to retirement",
  NIVEL = "Level within the class"
)

####### lets combine the list of datasets into an active and inactive dataframe

#### quickly harmonize column classes
active_contract_tbl <- harmonize_col_class(active_contract_tbl)
inactive_contract_tbl <- harmonize_col_class(inactive_contract_tbl)

active_contract_tbl <- bind_rows(active_contract_tbl)
inactive_contract_tbl <- bind_rows(inactive_contract_tbl)


#### ready to prepare the organization module


### for active
active_org_tbl <-
  active_contract_tbl |>
  mutate(org_id = paste0(ORGAO, " - ", COD_ORGAO)) |>
  mutate(org_name_native = ORGAO) |>
  mutate(country_code = "BRA") |>
  mutate(country_name = "Brazil") |>
  mutate(adm1_name = "Alagoas") |>
  mutate(adm1_code = "AL") |>
  mutate(org_parent = NA) |>
  mutate(org_child = NA) |>
  dplyr::select(org_id, org_name_native,
                country_code, country_name,
                starts_with("adm", ignore.case = FALSE),
                org_parent,
                org_child) |>
  unique()

### including organizational name translations

active_org_tbl <-
  active_org_tbl |>
  merge(tibble(org_name_native = unique(active_org_tbl$org_name_native),
               org_name_en = vectorize_gt(vector = unique(active_org_tbl$org_name_native),
                                          source_language = "pt")),
        by = "org_name_native",
        all.x = TRUE) |>
  as_tibble()



### for the inactive
inactive_org_tbl <-
  inactive_contract_tbl |>
  mutate(org_id = paste0(ORGAO, " - ", COD_ORGAO)) |>
  mutate(org_name_native = ORGAO) |>
  mutate(country_code = "BRA") |>
  mutate(country_name = "Brazil") |>
  mutate(adm1_name = "Alagoas") |>
  mutate(adm1_code = "AL") |>
  mutate(org_parent = NA) |>
  mutate(org_child = NA) |>
  mutate(org_date = as.Date(paste(ANO_PAGAMENTO,
                                  sprintf("%2d", MES_REFERENCIA),
                                  "01",
                                  sep = "-"))) |>
  dplyr::select(org_id, org_name_native,
                country_code, country_name,
                starts_with("adm", ignore.case = FALSE),
                org_parent,
                org_child, org_date) |>
  unique()

# ### including organizational name translations
#
# inactive_org_tbl <-
#   inactive_org_tbl |>
#   merge(tibble(org_name_native = unique(inactive_org_tbl$org_name_native),
#                org_name_en = vectorize_gt(vector = unique(inactive_org_tbl$org_name_native),
#                                           source_language = "pt")),
#         by = "org_name_native",
#         all.x = TRUE)
























































