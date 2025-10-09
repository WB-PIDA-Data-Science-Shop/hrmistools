#' Compute summary statistics for selected variables
#'
#' @description
#' Computes one or more summary statistics for a set of numeric variables in a
#' data frame, optionally grouped by specified variables (e.g., year, department, etc.).
#' Supports both built-in summary statistics (sum, mean, median, cv) and user-defined
#' functions, with flexible output in either long or wide format.
#'
#' @param data A data frame or tibble containing the variables to summarize.
#' @param cols A list specifying which columns to summarize and which to group by.
#'   Must include:
#'   \itemize{
#'     \item \code{vars} — Character vector of variable names to summarize.
#'     \item \code{groups} — Character vector of grouping variables (defaults to \code{"year"}).
#'   }
#' @param fns A list specifying which summary functions to apply.
#'   Must include:
#'   \itemize{
#'     \item \code{default} — Character vector of names of built-in summary functions to use.
#'       Available options are \code{"sum"}, \code{"mean"}, \code{"median"}, and \code{"cv"}.
#'     \item \code{user} — Optional named list of user-defined functions written in
#'       formula syntax (e.g., \code{list(p90 = ~quantile(.x, 0.9, na.rm = TRUE))}).
#'   }
#' @param output A character string specifying the desired output format.
#'   Must be one of:
#'   \itemize{
#'     \item \code{"long"} — Returns a tidy long-format tibble with \code{indicator} and \code{value} columns.
#'     \item \code{"wide"} — Returns a wide-format tibble with one column per computed statistic.
#'   }
#'
#' @details
#' The function summarizes numeric variables using the specified statistics and optionally
#' reshapes the output into long format. The coefficient of variation (\code{cv}) is assumed
#' to be available as a helper function (e.g., \code{cv <- function(x) sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)}).
#'
#' @return
#' A tibble containing the requested summary statistics, either:
#' \itemize{
#'   \item In *long* format: grouping variables, \code{indicator}, and \code{value}.
#'   \item In *wide* format: grouping variables and one column per computed statistic.
#' }
#'
#' @examples
#' # Example data
#' df <- tibble::tibble(
#'   year = rep(2020:2022, each = 3),
#'   department = rep(c("A", "B", "C"), 3),
#'   wage = c(1000, 1200, 1100, 1500, 1300, 1400, 1600, 1550, 1500),
#'   bonus = c(100, 120, 110, 150, 130, 140, 160, 155, 150)
#' )
#'
#' # Compute mean and sum of wages and bonuses by year and department (long)
#' compute_summary(
#'   data = df,
#'   cols = list(vars = c("wage", "bonus"), groups = c("year", "department")),
#'   fns = list(default = c("sum", "mean")),
#'   output = "long"
#' )
#'
#' # Same computation, wide format
#' compute_summary(
#'   data = df,
#'   cols = list(vars = c("wage", "bonus"), groups = c("year", "department")),
#'   fns = list(default = c("sum", "mean")),
#'   output = "wide"
#' )
#'
#' # Add a user-defined percentile function
#' compute_summary(
#'   data = df,
#'   cols = list(vars = c("wage"), groups = "year"),
#'   fns = list(
#'     default = c("mean"),
#'     user = list(p90 = ~quantile(.x, 0.9, na.rm = TRUE))
#'   ),
#'   output = "long"
#' )
#'
#' @export


compute_summary <- function(data,
                            cols = list(vars = NULL, groups = "year"),
                            fns  = list(default = c("sum", "mean", "median", "cv"),
                                        user = NULL),
                            output = c("long", "wide")) {
  # --- 0. Match output argument ---
  output <- match.arg(output)

  # --- 1. Define default functions ---
  default_fns <- list(
    sum    = ~sum(.x, na.rm = TRUE),
    mean   = ~mean(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    cv     = ~cv(.x)
  )

  # --- 2. Select only requested defaults ---
  selected_fns <- default_fns[intersect(fns$default, names(default_fns))]

  # --- 3. Merge user-defined functions (if any) ---
  if (!is.null(fns$user)) {
    selected_fns <- c(selected_fns, fns$user)
  }

  # --- 4. Identify grouping and summary columns ---
  group_vars <- cols$groups
  summary_vars <- cols$vars

  # --- 5. Compute summaries ---
  stats_df <-
    data |>
    group_by(across(all_of(group_vars))) |>
    summarise(
      across(all_of(summary_vars),
             selected_fns,
             .names = "{.col}_{.fn}"),
      .groups = "drop"
    )

  # --- 6. Reshape output if requested ---
  if (output == "long") {
    stats_df <- stats_df |>
      pivot_longer(
        cols = matches(paste(summary_vars, collapse = "|")),
        names_to = "indicator",
        values_to = "value"
      )
  }

  return(stats_df)
}

#' Compute ratio (share) indicators relative to macro data
#'
#' @description
#' Computes ratios of summarized values from a dataset to corresponding macro-level indicators
#' (e.g., wage bill as a share of GDP or population). Uses `compute_summary()` internally.
#'
#' @param data A data frame containing the microdata.
#' @param macro_data A data frame containing macro-level indicators.
#' @param cols A list defining variables and groups for `compute_summary()` (see `?compute_summary`).
#' @param macro_cols Character vector of macro indicator columns to use.
#' @param fns A list of summary functions (default and/or user-defined).
#' @param output Either `"long"` or `"wide"` (default `"long"`).
#'
#' @return A tibble containing ratio indicators (shares) in long or wide format.
#' @export
#'
compute_share <- function(data,
                          macro_data = macro_indicators,
                          cols = list(vars = NULL, groups = "year"),
                          macro_cols,
                          fns = list(default = c("sum"), user = NULL),
                          output = c("long", "wide")) {
  ## ensure valid argument
  output <- match.arg(output)

  # --- 1. Compute summarized data ---
  summary_df <- compute_summary(data = data, cols = cols, fns = fns, output = "wide")

  # --- 2. Detect join keys automatically ---
  join_vars <- intersect(names(summary_df), names(macro_data))
  if (length(join_vars) == 0)
    stop("No common grouping variables found between data and macro_data.")

  # --- 3. Merge with macro data ---
  merged_df <-
    summary_df |>
    left_join(macro_data |>
                select(all_of(c(join_vars, macro_cols))),
              by = join_vars)

  # --- 4. Compute shares (always work in long form internally) ---
  ratio_df <-
    merged_df |>
    pivot_longer(cols = all_of(macro_cols),
                 names_to = "macro_var",
                 values_to = "macro_value") |>
    pivot_longer(cols = setdiff(names(summary_df), join_vars),
                 names_to = "summary_var",
                 values_to = "summary_value") |>
    mutate(indicator = paste0(summary_var, "_per_", macro_var),
           value = summary_value / macro_value) |>
    select(all_of(join_vars), macro_var, macro_value,
           summary_var, summary_value, indicator, value)

  # --- 5. Format output ---
  if (output == "wide") {

    keep_df <-
      left_join(ratio_df |>
                  dplyr::select(all_of(join_vars),
                                macro_var,
                                macro_value) |>
                  unique() |>
                  pivot_wider(names_from = macro_var,
                              values_from = macro_value),
                ratio_df |>
                  dplyr::select(all_of(join_vars),
                                summary_var,
                                summary_value) |>
                  unique() |>
                  pivot_wider(names_from = summary_var,
                              values_from = summary_value),
                by = join_vars)


    ratio_df <-
      ratio_df |>
      distinct() |>  # prevent duplicates
      dplyr::select(join_vars, indicator, value) |>
      pivot_wider(names_from = indicator,
                  values_from = value) |>
      left_join(keep_df, by = join_vars)

  }


  return(ratio_df)
}











