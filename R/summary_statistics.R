#' Compute grouped summary statistics (mean, median, sd)
#'
#' This function computes summary statistics (mean, median, and standard deviation)
#' for specified numeric variables, optionally grouped.
#'
#' @param data A data frame or tibble.
#' @param group_vars One or more unquoted grouping variables (passed to [dplyr::group_by()]).
#' @param cols Columns to summarise (passed to [dplyr::across()]). Should be numeric.
#'
#' @return A tibble with grouped summary statistics for each specified variable.
#' @examples
#' library(dplyr)
#' library(purrr)
#'
#' # Example data
#' df <- tibble(
#'   paygrade = c("A", "A", "B", "B"),
#'   year = c(2020, 2021, 2020, 2021),
#'   base_salary_ppp = c(40000, 42000, 38000, 39500)
#' )
#'
#' compute_grouped_summary(
#'   df,
#'   group_vars = c(paygrade, year),
#'   cols = c(base_salary_ppp)
#' )
#'
#' @import dplyr
#' @import purrr
#' @importFrom stats median sd
#' @export
compute_grouped_summary <- function(data, group_vars = NULL, cols) {
  data %>%
    dplyr::group_by(
      dplyr::across({{ group_vars }})
    ) %>%
    dplyr::summarise(
      dplyr::across(
        {{ cols }},
        list(
          mean = purrr::partial(mean, na.rm = TRUE),
          median = purrr::partial(stats::median, na.rm = TRUE),
          sd = purrr::partial(stats::sd, na.rm = TRUE)
        ),
        .names = "{.fn}_{.col}"
      ),
      .groups = "drop"
    )
}
