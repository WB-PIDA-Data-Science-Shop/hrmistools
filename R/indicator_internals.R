#' Compute the Coefficient of Variation (CV)
#'
#' Calculates the coefficient of variation for a numeric vector, defined as the
#' ratio of the standard deviation to the mean. This provides a unitless measure
#' of relative dispersion, allowing comparison of variability across variables
#' or groups with different scales.
#'
#' @param x A numeric vector of values.
#' @param na.rm Logical; if `TRUE`, missing values (`NA`) are removed before
#' computation. Defaults to `TRUE`.
#'
#' @details
#' The function safely handles missing values and cases where the mean is zero
#' (to avoid division by zero). If the input vector is empty or the mean equals
#' zero, the function returns `NA_real_`.
#'
#' @return A numeric value representing the coefficient of variation (CV).
#' Returns `NA_real_` if the computation is not possible (e.g., all values are
#' missing or the mean is zero).
#'
#' @examples
#' x <- c(10, 12, 8, 15, NA)
#' cv(x)
#'
#' @export
cv <- function(x, na.rm = TRUE) {

  ## handling missing values
  if (na.rm) {
    x <- x[!is.na(x)]
  }

  ## compute the vector mean
  m <- mean(x)

  ## numerator-denominator handling to avoid dividing by 0
  if (length(x) == 0 || is.na(m) || m == 0) {

    return(NA_real_)

  }

  y <- sd(x) / m

  return(y)

}

#' Compute a Compression Ratio Between Two Percentiles
#'
#' Calculates a wage (or value) compression ratio by dividing one quantile by
#' another, typically the 90th percentile divided by the 10th percentile.
#' This provides a measure of wage inequality or spread within a group.
#'
#' @param x A numeric vector of values (e.g., wages or salaries).
#' @param upper Numeric; the upper percentile to compute (default is `0.9` for
#' the 90th percentile).
#' @param lower Numeric; the lower percentile to compute (default is `0.1` for
#' the 10th percentile).
#' @param na.rm Logical; if `TRUE`, missing values (`NA`) are removed before
#' computation. Defaults to `TRUE`.
#'
#' @details
#' The function computes the specified upper and lower quantiles and returns
#' their ratio (`upper / lower`). If either quantile is `NA` or the lower
#' quantile is zero, the function returns `NA_real_`.
#'
#' @return A numeric value representing the ratio of the specified upper to
#' lower percentile values. Returns `NA_real_` if computation is not possible
#' (e.g., due to missing data or zero denominator).
#'
#' @examples
#' wages <- c(1000, 1200, 900, 3000, 5000, NA)
#' cp_ratio(wages)             # default 90/10 ratio
#' cp_ratio(wages, 0.75, 0.25) # 75/25 ratio
#'
#' @export
cp_ratio <- function(x, upper = 0.9, lower = 0.1, na.rm = TRUE){

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  q <- quantile(x, probs = c(lower, upper), na.rm = na.rm)

  if (any(is.na(q)) || q[1] == 0) return(NA_real_)

  ratio <- q[2] / q[1]

  return(ratio)

}
