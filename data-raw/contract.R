################################################################################
############ PREPARE THE CONTRACT DATA FOR PACKAGE DATA AND DOC ################
################################################################################


contract_tbl <- readr::read_csv("data-raw/contract_data_zambia.csv")

contract_tbl <-
  contract_tbl |>
  mutate(across(
    .cols = c("ref_date", "start_date", "end_date"),
    .fns = ~ as.Date(gsub("/", "-", .x), format = "%m-%d-%Y")
  ))

contract_harmonized <- contract_tbl

usethis::use_data(contract_harmonized,
                  overwrite = TRUE)
