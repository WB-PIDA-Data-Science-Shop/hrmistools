# set-up ------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(ggthemes)

# read-in data ------------------------------------------------------------
hrmis_worker <- read_rds(
  here("inst", "extdata", "bra_hrmis_worker.rds")
)


