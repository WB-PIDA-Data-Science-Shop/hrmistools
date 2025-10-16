#' Compute grouped summary statistics for multiple variables
#'
#' @description
#' A flexible wrapper around `dplyr::summarise()` and `dplyr::across()` that
#' computes one or more summary statistics for a set of numeric variables,
#' optionally grouped by one or more categorical variables. Users can choose
#' from built-in summary functions defined in [define_fns()] or supply their own.
#'
#' @param data A data frame or tibble containing the variables to summarize.
#'
#' @param cols A character vector of variable names to summarize, or a list
#'   with an element `vars` (e.g., `list(vars = c("var1", "var2"))`).
#'
#' @param fns Optional. A specification of the summary functions to apply:
#'   - `NULL` (default): applies all default functions returned by [define_fns()].
#'   - A **character vector** of function names (e.g., `c("mean", "sd")`)
#'     referring to defaults in [define_fns()].
#'   - A **list** of formulas (e.g., `list(mean = ~mean(.x, na.rm = TRUE))`)
#'     or a mix of character names and formulas.
#'
#' @param groups A character vector of grouping variables used for aggregation.
#'
#' @param output Character, either `"long"` or `"wide"`. If `"long"`, reshapes
#'   the results into a tidy format with columns `indicator` and `value`.
#'   Defaults to `"long"`.
#'
#' @return
#' A tibble containing grouped summary statistics.
#' - If `output = "wide"`, each statistic appears as a separate column.
#' - If `output = "long"`, the data are in tidy (long) format with one row per
#'   group-variable-statistic combination.
#'
#' @details
#' This function simplifies grouped summaries by handling:
#' - Flexible function definitions (`fns`) using formula notation `~expr(.x)`.
#' - Integration with user-defined functions via [define_fns()].
#' - Optional long/wide reshaping for tidy analysis workflows.
#'
#' @section Default Functions:
#' The default functions are defined in [define_fns()] and typically include:
#' `sum`, `mean`, `median`, `cv`, and `cp_ratio`. These can be customized or
#' extended by modifying `define_fns()`.
#'
#' @examples
#' df <- tibble::tibble(
#'   country = rep(c("A", "B"), each = 5),
#'   year = rep(2020:2021, times = 5),
#'   income = runif(10, 1000, 2000),
#'   expenditure = runif(10, 500, 1500)
#' )
#'
#'  # Default summaries by country and year
#' compute_summary(data = df,
#'                 cols = c("income", "expenditure"),
#'                 groups = c("country", "year"),
#'                 fns = "mean")
#'
#'  # Select specific functions
#'  compute_summary(data = df,
#'                 cols = c("income"),
#'                 groups = c("country"),
#'                 fns = c("mean", "sd"),
#'                 output = "wide")
#'
#'  # Custom function
#'  compute_summary(df,
#'                 cols = "income",
#'                 groups = "country",
#'                 fns = list("cv",
#'                            q90 = ~quantile(.x, 0.9, na.rm = TRUE)))
#'
#' @seealso [define_fns()], [dplyr::summarise()], [tidyr::pivot_longer()]
#' @importFrom dplyr group_by summarise across all_of n_distinct
#' @importFrom tidyr pivot_longer
#' @importFrom glue glue
#' @importFrom rlang is_formula
#' @export

compute_summary <- function(data,
                            cols,
                            fns = NULL,
                            groups,
                            output = c("long", "wide")) {

  # --- 0. Match output argument ---
  output <- match.arg(output)

  # --- 1. Define default summary functions ---
  default_fns <- define_fns()

  # --- 2. Resolve which functions to use ---
  if (is.null(fns)) {
    # No functions specified → use all defaults
    selected_fns <- default_fns

  } else if (is.character(fns)) {
    # Character vector → use named defaults
    unknown <- setdiff(fns, names(default_fns))
    if (length(unknown) > 0) {
      stop(glue::glue("Unknown function name(s): {toString(unknown)}"))
    }
    selected_fns <- default_fns[fns]

  } else if (is.list(fns)) {
    # List of formulas or a mix (character names + formulas)
    char_fns <- fns[sapply(fns, is.character)]
    formula_fns <- fns[sapply(fns, rlang::is_formula)]

    # Add default functions where names are characters
    selected_fns <- c(
      default_fns[intersect(unlist(char_fns), names(default_fns))],
      formula_fns
    )
  } else {
    stop("`fns` must be NULL, a character vector, or a list of formulas.")
  }

  # --- 3. Handle cols input (list or character vector) ---
  if (is.list(cols) && !is.null(cols$vars)) {
    summary_vars <- cols$vars
  } else if (is.character(cols)) {
    summary_vars <- cols
  } else {
    stop("`cols` must be a character vector or a list with element `vars`.")
  }

  # --- 4. Identify grouping variables ---
  group_vars <- groups

  # --- 5. Compute summaries ---
  stats_df <-
    data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(summary_vars),
        selected_fns,
        .names = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )

  # --- 6. Reshape output if requested ---
  if (output == "long") {
    stats_df <- stats_df |>
      tidyr::pivot_longer(
        cols = tidyselect::matches(paste(summary_vars,
                                         collapse = "|")),
        names_to = "indicator",
        values_to = "value"
      )
  }

  return(stats_df)
}

#' Compute Shares of Summary Indicators Relative to Macro Indicators
#'
#' This function calculates the ratio (share) of summarized microdata indicators
#' to macro-level indicators (e.g., GDP, total population, etc.). It automatically
#' detects common join keys between the micro-level summary and macro-level data,
#' merges them, and computes the ratios for all possible combinations of
#' summarized and macro variables.
#'
#' @param data A data frame containing the microdata to be summarized.
#' @param macro_data A data frame containing macro-level indicators. Defaults to
#'   \code{macro_indicators} if available in the environment.
#' @param macro_cols A character vector specifying the names of the macro
#'   indicator columns in \code{macro_data} to use for share computation.
#' @param cols A named list passed to \code{compute_summary()}, specifying
#'   which variables to summarize (e.g. \code{list(vars = "varname")}).
#' @param groups A character vector specifying the grouping variables common to
#'   both datasets. Defaults to \code{c("country_code", "ref_date")}.
#' @param fns A list of summary functions passed to \code{compute_summary()},
#'   typically defined as formulas (e.g. \code{list(mean = ~mean(.x, na.rm = TRUE))}).
#' @param output Character string indicating the desired output format:
#'   \code{"long"} (default) for a tidy data frame with one row per share, or
#'   \code{"wide"} for a data frame with one column per computed indicator.
#'
#' @details
#' The function proceeds in five steps:
#' \enumerate{
#'   \item Summarizes the microdata using \code{compute_summary()}.
#'   \item Automatically detects join keys shared between the summary and macro data.
#'   \item Merges the summarized and macro data on those join keys.
#'   \item Computes the ratio of each summarized indicator to each macro indicator.
#'   \item Formats the output as either long or wide form, depending on the \code{output} argument.
#' }
#'
#' The output always includes the computed shares (e.g. \code{employment_per_GDP}),
#' as well as the underlying macro and summary values used to compute them.
#'
#' @return
#' A data frame containing the computed ratios (shares).
#' If \code{output = "long"}, columns include:
#' \itemize{
#'   \item Grouping variables (e.g., \code{country_code}, \code{ref_date})
#'   \item \code{macro_var}, \code{macro_value}
#'   \item \code{summary_var}, \code{summary_value}
#'   \item \code{indicator} – constructed name of the ratio
#'   \item \code{value} – computed share
#' }
#' If \code{output = "wide"}, each ratio indicator is returned as a separate column.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' compute_share(data = contract_harmonized,
#'               macro_cols = c("gdp_lcu", "prevenue_lcu"),
#'               cols = c("gross_salary_lcu", "net_salary_lcu"),
#'               fns = c("mean", "sum"),
#'               output = "wide")
#' }
#'
#' @seealso \code{\link{compute_summary}}
#'
#' @importFrom dplyr left_join select mutate distinct
#' @importFrom tidyr pivot_longer pivot_wider
#' @export

compute_share <- function(data,
                          macro_data = macro_indicators,
                          macro_cols,
                          cols,
                          groups = c("country_code", "ref_date"),
                          fns,
                          output = c("long", "wide")) {
  ## ensure valid argument
  output <- match.arg(output)

  # --- 1. Compute summarized data ---
  summary_df <- compute_summary(data = data,
                                cols = cols,
                                fns = fns,
                                groups = groups,
                                output = "wide")

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




#' Calculate annual growth rates for a numeric column
#'
#' @description
#' Computes the year-over-year growth rate of a numeric column in a data frame.
#' The function first completes the date sequence using `tidyr::complete()` to
#' ensure all years between the minimum and maximum are represented, then
#' calculates the growth rate using lagged values.
#'
#' @param data A data frame or tibble containing the data.
#' @param col A numeric column (unquoted) for which the growth rate will be calculated.
#' @param date_col A date column (unquoted) used to order the data and define the time sequence.
#'
#' @return A tibble with two columns:
#' \itemize{
#'   \item The `date_col` column (yearly sequence from min to max).
#'   \item A new column named `"growth_<col>"` containing the calculated
#'   year-over-year growth rates.
#' }
#'
#' @details
#' - The function uses `tidyr::complete()` to fill in missing years in the date sequence.
#'   Missing values in `col` will result in `NA` for the corresponding growth rate.
#' - The first observation (or any where the lag is missing) will have `NA`.
#' - Grouping is by the date column to summarise across the entire dataset; if you
#'   have multiple series (e.g., countries), consider grouping beforehand.
#'
#' @examples
#' library(dplyr)
#' library(tidyr)
#'
#' df <- tibble(
#'   year = c(2020, 2021, 2023),
#'   gdp = c(100, 110, 130)
#' )
#'
#' compute_change(df, gdp, year)
#'
#' @export
compute_change <- function(data, col, date_col){
  data |>
    complete(
      {{date_col}} := min({{date_col}}):max({{date_col}})
    ) |>
    transmute(
      {{date_col}},
      "{{col}}_growth" := {{col}}/lag({{col}}) - 1,
      .groups = "drop"
    )
}







