## code to prepare `isco` dataset goes here
# accessed 8/22/2025
library(janitor)
library(dplyr)
library(readr)

# isco_url <- "https://www.ilo.org/ilostat-files/ISCO/newdocs-08-2021/ISCO-08/ISCO-08%20EN%20Structure%20and%20definitions.xlsx"
# isco_path <- file.path(tempdir(), "isco.xlsx")
#
#
# download.file(
#   isco_url,
#   isco_path,
#   mode = "wb"
# )
#
# isco_input <- read_excel(
#   isco_path
# )
#
# isco <- isco_input |>
#   clean_names()

isco <-
  read_csv("https://www.ilo.org/ilostat-files/Documents/ISCO.csv") |>
  as_tibble() |>
  filter(ISCO_version == "ISCO-08") |>
  clean_names()

usethis::use_data(isco, overwrite = TRUE)
