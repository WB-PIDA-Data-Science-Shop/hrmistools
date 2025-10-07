
#' Compute Wage Budget Shares/Rates of Macroeconomic Indicators
#'
#' Aggregates wage variables from a contracts dataset and computes ratios of total wages to selected macroeconomic indicators.
#'
#' @param contract_df A data frame containing contract-level wage data with a \code{year} and \code{country_code} column.
#' @param wage_vars A character vector of column names in \code{contract_df} corresponding to wage-related variables to aggregate.
#' @param macro_vars A character vector of macroeconomic indicators to use as denominators when computing ratios.
#'
#' @details
#' The function aggregates total wage payments by year, merges them with the relevant subset of the global
#' \code{macro_indicators} dataset for the same country and time period, and computes ratios of each
#' wage variable to each selected macro variable.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{year}{Year of observation.}
#'   \item{indicator}{Name of computed ratio (\code{wage_var_per_macro_var}).}
#'   \item{value}{Computed ratio value.}
#' }
#'
#' @importFrom dplyr group_by summarise mutate left_join select across
#' @importFrom tidyr pivot_longer
#' @export

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

#' Compute Wage Bill by Occupation
#'
#' Aggregates wage bill variables by occupational group and year, optionally merging with ISCO classifications.
#'
#' @param contract_df A data frame of individual contract-level records including occupational codes.
#' @param wage_vars A character vector of wage-related variables to sum.
#' @param group_var A grouping variable (e.g., ministry, region) for disaggregated computation.
#' @param isco_level Integer (1–4). Specifies the ISCO aggregation level. Defaults to 4 (unit level).
#'
#' @details
#' If \code{isco_level < 4}, the function merges \code{contract_df} with the \code{isco} lookup table to include
#' broader occupational categories. The wage bill is then summed by occupation group and year, and reshaped to
#' a long format for further analysis.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{occupation_iscocode}{ISCO code of the occupation group.}
#'   \item{year}{Year of observation.}
#'   \item{indicator}{Name of wage variable.}
#'   \item{value}{Sum of wages for that occupation and year.}
#' }
#'
#' @importFrom data.table as.data.table merge.data.table
#' @importFrom dplyr group_by summarise mutate across
#' @importFrom tidyr pivot_longer
#' @export

compute_wagebill_byoccup <- function(contract_df,
                                     wage_vars,
                                     group_var,
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

#' Compute Summary Statistics and Custom Metrics by Group
#'
#' Computes selected summary statistics (sum, mean, median, coefficient of variation, etc.)
#' for one or more numeric variables, grouped by one or more categorical variables
#' and optionally by a time variable. Users can also pass in **custom summary functions**.
#'
#' @param contract_df A data frame containing the data to summarize.
#' @param wage_vars Character vector of column names in `contract_df` to summarize.
#' @param group_vars Character vector of column names to group by (e.g., "paygrade").
#' @param time_var Character string specifying an optional time variable. Defaults to `"year"`.
#'                 If `NULL`, no time grouping is applied.
#' @param choice_fns Character vector of names of default summary functions to compute.
#'                   Options include `"sum"`, `"mean"`, `"median"`, `"cv"`. Defaults to all four.
#' @param user_fns Named list of **user-defined functions** or formulas to compute additional statistics.
#'                 Example: `list(cp_ratio = ~cp_ratio(.x))`.
#'
#' @details
#' The function computes the selected summary statistics for each combination of `group_vars`
#' and `time_var` (if provided). The results are returned in **long format** with columns:
#' \code{indicator} (variable and statistic) and \code{value} (computed result).
#'
#' **Default functions included:**
#' - `sum` : total sum of values
#' - `mean` : arithmetic mean
#' - `median` : median value
#' - `cv` : coefficient of variation (sd/mean)
#'
#' Users can define their own functions (e.g., compression ratios) and pass them via `user_fns`.
#'
#' @return A tibble in long format with columns:
#' \describe{
#'   \item{group_vars}{Grouping variables used.}
#'   \item{time_var}{Time variable if provided.}
#'   \item{indicator}{The variable and statistic, e.g., `base_salary_lcu_mean`.}
#'   \item{value}{The computed value.}
#' }
#'
#'
#' @export


compute_wagebill_bygroup <- function(contract_df,
                                     wage_vars,
                                     group_vars,
                                     time_var = "year",
                                     choice_fns = c("sum", "mean", "median", "cv"),
                                     user_fns = NULL) {

  # Default summary functions
  default_fns <- list(
    sum    = ~sum(.x, na.rm = TRUE),
    mean   = ~mean(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    cv     = ~cv(.x)
  )

  # Select only requested ones
  selected_fns <- default_fns[intersect(choice_fns, names(default_fns))]

  # Merge user functions if any
  if (!is.null(user_fns)) {
    selected_fns <- c(selected_fns, user_fns)
  }

  # Compute
  stats_df <-
    contract_df |>
    group_by(across(all_of(c(group_vars, time_var)))) |>
    summarise(
      across(all_of(wage_vars),
             selected_fns,
             .names = "{.col}_{.fn}"),
      .groups = "drop"
    ) |>
    pivot_longer(
      cols = matches(paste(wage_vars, collapse = "|")),
      names_to = "indicator",
      values_to = "value"
    )

  return(stats_df)
}

#' Compute Public Employment Shares
#'
#' Calculates the ratio of public sector employment counts to selected macroeconomic aggregates.
#'
#' @param worker_df A data frame of worker-level data containing a \code{ref_date} and \code{country_code}.
#' @param macro_vars A character vector of macroeconomic indicators to serve as denominators.
#'
#' @details
#' The function counts government employees by year and merges this with national macroeconomic data from
#' \code{macro_indicators}, restricted to the corresponding country and time range. The resulting share is the ratio
#' of government employment to each macroeconomic indicator.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{year}{Year of observation.}
#'   \item{indicator}{Name of macroeconomic indicator used.}
#'   \item{value}{Macro variable value.}
#'   \item{govcount_share}{Share of government employment relative to the macro indicator.}
#' }
#'
#' @importFrom dplyr mutate filter select group_by summarise
#' @importFrom tidyr pivot_longer
#' @importFrom lubridate year
#' @export


compute_pubempshare <- function(worker_df,
                                macro_vars){

  ## ensure the year variable is an integer
  worker_df <-
    worker_df |>
    mutate(year = as.integer(lubridate::year(ref_date)))

  ## subset the set of macro indicators
  macro_df <-
    macro_indicators |>
    dplyr::select(all_of(macro_vars), year, country_code) |>
    dplyr::filter(year <= max(worker_df[["year"]]) &
                    year >= min(worker_df[["year"]]) &
                    country_code == unique(worker_df$country_code)) |>
    mutate(year = as.integer(year))

  ## compute the stats by dividing macro variables by count of government
  ## workers
  stats_df <-
    worker_df |>
    group_by(year) |>
    summarise(govcount = n()) |>
    merge(macro_df,
          by = "year",
          all.x = TRUE) |>
    dplyr::select(-country_code) |>
    pivot_longer(cols = all_of(macro_vars),
                 names_to = "indicator",
                 values_to = "value") |>
    mutate(govcount_share = govcount / value)

  return(stats_df)


}

#' Compute ISCO-Level Wage Bill Shares
#'
#' Calculates each occupation's share of the total wage bill within a given year and indicator.
#'
#' @param ... Arguments passed to \code{compute_wagebill_byoccup()}.
#'
#' @details
#' This function first computes the wage bill by occupation using \code{compute_wagebill_byoccup()},
#' then calculates the proportional share of each occupation’s wage bill in the total for the same
#' year and wage indicator.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{occupation_iscocode}{ISCO code of the occupation group.}
#'   \item{occupation_isconame}{Name of the occupation group.}
#'   \item{year}{Year of observation.}
#'   \item{indicator}{Name of the wage variable.}
#'   \item{isco_share}{Occupation’s share of the total wage bill.}
#' }
#'
#' @importFrom data.table as.data.table
#' @importFrom tibble as_tibble
#' @importFrom dplyr select
#' @export

compute_isco_share <- function(...){


  ### first compute the wagebill by occupation
  df <- compute_wagebill_byoccup(...)

  df <-
  df |>
    as.data.table() %>%
    .[,totals := sum(value, na.rm = TRUE), by = c("indicator",
                                                  "year")] %>%
    .[,isco_share := value / totals] |>
    as_tibble() |>
    dplyr::select(occupation_iscocode,
                  occupation_isconame,
                  year, indicator, isco_share)


  return(df)

}

#' Compute Teacher-to-Student Ratios
#'
#' Estimates the ratio of teachers (based on ISCO classification) to student counts or enrollment-related macro indicators.
#'
#' @param contract_df A data frame of contract-level records including occupational codes and years.
#' @param macro_vars A character vector of macroeconomic indicators corresponding to student populations or enrollment.
#'
#' @details
#' Teachers are identified using ISCO major group 23 ("Teaching Professionals"). The function counts unique teachers per year
#' and merges with selected macro indicators representing the number of students or school-age population to derive
#' the teacher-to-student ratio.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{year}{Year of observation.}
#'   \item{ts_ratio}{Teacher-to-student ratio for each year.}
#' }
#'
#' @importFrom dplyr mutate filter select group_by summarise
#' @importFrom tidyr pivot_longer
#' @export


compute_teacher_student_ratios <- function(contract_df,
                                           macro_vars){

  ## subset the contract data to only teacher professionals under the isco
  isco_set <- isco$unit[isco$sub_major == "23"]

  teacher_df <-
    contract_df |>
    mutate(year = as.integer(year)) |>
    dplyr::filter(occupation_iscocode %in% isco_set) |>
    dplyr::select(worker_id, year, occupation_iscocode, occupation_isconame) |>
    group_by(year) |>
    unique()

  ## compute the number of teachers in each year
  teacher_df <-
  teacher_df |>
    group_by(year) |>
    summarise(num_teachers = n())


  ## compute the teacher data
  student_df <-
    macro_indicators |>
    dplyr::select(all_of(macro_vars), year, country_code) |>
    dplyr::filter(year <= max(contract_df[["year"]]) &
                    year >= min(contract_df[["year"]]) &
                    country_code == unique(contract_df$country_code)) |>
    mutate(year = as.integer(year))

  df <-
    teacher_df |>
    merge(student_df, by = "year", all.x = TRUE) |>
    dplyr::select(-country_code) |>
    as_tibble() |>
    pivot_longer(cols = all_of(macro_vars),
                 names_to = "indicator",
                 values_to = "value") |>
    mutate(ts_ratio = num_teachers / value) |>
    dplyr::select(year, ts_ratio)


  return(df)


}

#' Compute Distribution Profiles
#'
#' Computes the proportion of observations within each category of specified variables, optionally over time.
#'
#' @param df A data frame containing the variables of interest.
#' @param profile_vars A character vector of categorical variables to compute distributions for.
#' @param time_var A string specifying the time variable (default: \code{"ref_date"}).
#' @param na.rm Logical; if \code{TRUE}, missing values are ignored in totals (default: \code{TRUE}).
#'
#' @details
#' The function tabulates counts and proportions of categorical variable combinations within each time period.
#' Useful for descriptive summaries of workforce composition or demographic patterns.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{time_var}{Time variable (e.g., reference date).}
#'   \item{profile_vars}{Grouping variables.}
#'   \item{n}{Count of records.}
#'   \item{total}{Total count within the time period.}
#'   \item{prop}{Proportion of total represented by each group.}
#' }
#'
#' @importFrom dplyr group_by summarise mutate ungroup across n
#' @export


compute_profile <- function(df,
                            profile_vars,
                            time_var = "ref_date",
                            na.rm = TRUE){

  ## ensure profile_vars is a character vector
  stopifnot(is.character(profile_vars))

  ## computing the tabulations
  tab_df <-
  df |>
    group_by(across(all_of(c(time_var, profile_vars)))) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop_last") |>
    dplyr::mutate(total = sum(n, na.rm = na.rm)) |>
    dplyr::mutate(prop = n / total) |>
    dplyr::ungroup()

  return(tab_df)

}










