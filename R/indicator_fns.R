

compute_budgetshare <- function(contract_df, wage_vars, macro_vars) {

  # 1. Aggregate wages by year
  totwage_df <-
    contract_df %>%
    group_by(year) %>%
    summarise(across(all_of(wage_vars),
                     ~ sum(.x, na.rm = TRUE))) |>
    mutate(year = as.integer(year))

  # 2. Subset relevant macro indicators
  econwide_df <-
    macro_indicators %>%
    filter(country_code == unique(contract_df[["country_code"]]) &
             year >= min(totwage_df[["year"]]) &
             year <= max(totwage_df[["year"]])) |>
    mutate(year = as.integer(year))

  # 3. Merge
  merged_df <-
    totwage_df %>%
    left_join(econwide_df %>% select(-country_code), by = "year")

  # 4. Compute all ratios and pivot longer
  stats_df <-
    merged_df %>%
    pivot_longer(cols = all_of(wage_vars),
                 names_to = "wage_var",
                 values_to = "wage_value") |>
    pivot_longer(cols = all_of(macro_vars),
                 names_to = "macro_var",
                 values_to = "macro_value") |>
    mutate(indicator = paste0(wage_var, "_per_", macro_var),
           value = wage_value / macro_value) %>%
    select(year, indicator, value)

  return(stats_df)
}


#' @importFrom data.table merge as.data.table

compute_wagebill_byoccup <- function(contract_df,
                                     wage_vars,
                                     isco_level = 4){

  ### add other isco levels if the isco data is not available
  if (isco_level < 4) {

    contract_df <-
      data.table::merge.data.table(x = contract_df |> data.table::as.data.table(),
                                   y = isco |> data.table::as.data.table(),
                                   by.x = "occupation_iscocode",
                                   by.y = "unit",
                                   all.x = TRUE)

  }

  class_vars <- colnames(isco)[-1]
  class_vars[class_vars == "unit"] <- "occupation_iscocode"
  class_vars[class_vars == "description"] <- "occupation_isconame"

  ## split the colnames into groups by level
  class_vars <- split(class_vars,
                      ceiling(seq_along(class_vars) / 2))

  stats_df <-
    contract_df |>
    group_by(across(all_of(class_vars[[isco_level]])), year) |>
    summarise(across(all_of(wage_vars),
                     ~ sum(.x, na.rm = TRUE)),
              , .groups = "drop") |>
    mutate(year = as.integer(year)) |>
    pivot_longer(cols = all_of(wage_vars),
                 names_to = "indicator",
                 values_to = "value")

  return(stats_df)

}




















