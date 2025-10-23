#' Plot grouped line chart with labeled points
#'
#' This function creates a line plot with labeled points, showing how a variable
#' (y) evolves along another variable (x).
#'
#' @param data A data frame or tibble containing the variables to plot.
#' @param x Column to be mapped to the x-axis.
#' @param y Column to be mapped to the y-axis.
#' @param group Column specifying the grouping variable (mapped to color).
#' @param label Column specifying the labels for each point (optional).
#' @param ... Any other arguments passed to \code{aes()}.
#'
#' @return A \code{ggplot} object representing the grouped line chart.
#'
#' @examples
#' \dontrun{
#' ggplot_point_line(
#'   data,
#'   x = year,
#'   y = median_base_salary_ppp,
#'   group = paygrade,
#'   label = year
#' )
#' }
#'
#' @import ggplot2
#' @importFrom ggrepel geom_text_repel
#' @importFrom ggthemes scale_color_solarized
#' @importFrom rlang enquo
#'
#' @export
ggplot_point_line <- function(data,
                              x,
                              y,
                              group = NULL,
                              label = NULL,
                              ...) {
  plot <- ggplot(data, aes(x = {{ x }}, y = {{ y }}, color = {{ group }}, ...)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 4)

  # Add labels if provided
  if (!rlang::quo_is_null(rlang::enquo(label))) {
    plot <- plot +
      ggrepel::geom_text_repel(
        aes(label = {{ label }}),
        size = 3.5,
        segment.linetype = 6,
        direction = "y",
        min.segment.length = 0,
        show.legend = FALSE,
        max.overlaps = Inf,
        color = "grey40"
      )
  }

  if (!rlang::quo_is_null(rlang::enquo(group))) {
    plot <- plot +
      ggthemes::scale_colour_solarized()
  }

  plot <- plot +
    theme_minimal(base_size = 14) +
    theme(legend.position = "bottom")

  return(plot)
}
