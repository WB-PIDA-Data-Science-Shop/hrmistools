################################################################################
############ PREPARE THE CONTRACT DATA FOR PACKAGE DATA AND DOC ################
################################################################################


contract_tbl <- readr::read_csv("data-raw/contract_df_sim_brazil.csv")

contract_harmonized <- contract_tbl

usethis::use_data(contract_harmonized,
                  overwrite = TRUE)
