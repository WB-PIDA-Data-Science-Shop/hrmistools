#' Plot grouped line chart with points
#'
#' This function creates a line plot with points, showing how a variable
#' (y) evolves along another variable (x)
#'
#' @param data A data frame or tibble containing the variables to plot.
#' @param x Column to be mapped to the x-axis.
#' @param y Column to be mapped to the y-axis.
#' @param group Column specifying the grouping variable.
#'   This will be mapped to color.
#' @param ... Any other arguments passed to aes().
#'
#' @return A \code{ggplot} object representing the grouped line chart.
#'
#' @examples
#' \dontrun{
#' ggplot_point_line(
#'   data,
#'   x = year,
#'   y = median_base_salary_ppp,
#'   group = paygrade
#' )
#' }
#'
#' @import ggplot2
#'
#' @export
ggplot_point_line <- function(data, x, y, group = NULL, ...) {
  data |>
    ggplot(
      aes(
        x = {{ x }},
        y = {{ y }},
        color = {{ group }},
        ...
      )
    ) +
    geom_line(linewidth = 1.5) +
    geom_point(size = 5)
}
