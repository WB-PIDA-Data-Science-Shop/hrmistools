# Compute grouped summary statistics for multiple variables

A flexible wrapper around \`dplyr::summarise()\` and \`dplyr::across()\`
that computes one or more summary statistics for a set of numeric
variables, optionally grouped by one or more categorical variables.
Users can choose from built-in summary functions defined in
\[define_fns()\] or supply their own.

## Usage

``` r
compute_summary(
  data,
  cols,
  fns = NULL,
  groups = NULL,
  output = c("long", "wide")
)
```

## Arguments

- data:

  A data frame or tibble containing the variables to summarize.

- cols:

  A character vector of variable names to summarize, or a list with an
  element \`vars\` (e.g., \`list(vars = c("var1", "var2"))\`).

- fns:

  Optional. A specification of the summary functions to apply: -
  \`NULL\` (default): applies all default functions returned by
  \[define_fns()\]. - A \*\*character vector\*\* of function names
  (e.g., \`c("mean", "sd")\`) referring to defaults in
  \[define_fns()\]. - A \*\*list\*\* of formulas (e.g., \`list(mean =
  ~mean(.x, na.rm = TRUE))\`) or a mix of character names and formulas.

- groups:

  A character vector of grouping variables used for aggregation.

- output:

  Character, either \`"long"\` or \`"wide"\`. If \`"long"\`, reshapes
  the results into a tidy format with columns \`indicator\` and
  \`value\`. Defaults to \`"long"\`.

## Value

A tibble containing grouped summary statistics. - If \`output =
"wide"\`, each statistic appears as a separate column. - If \`output =
"long"\`, the data are in tidy (long) format with one row per
group-variable-statistic combination.

## Details

This function simplifies grouped summaries by handling: - Flexible
function definitions (\`fns\`) using formula notation \`~expr(.x)\`. -
Integration with user-defined functions via \[define_fns()\]. - Optional
long/wide reshaping for tidy analysis workflows.

## Default Functions

The default functions are defined in \[define_fns()\] and typically
include: \`sum\`, \`mean\`, \`median\`, \`cv\`, and \`cp_ratio\`. These
can be customized or extended by modifying \`define_fns()\`.

## See also

\[define_fns()\], \[dplyr::summarise()\], \[tidyr::pivot_longer()\]

## Examples

``` r
df <- tibble::tibble(
  country = rep(c("A", "B"), each = 5),
  year = rep(2020:2021, times = 5),
  income = runif(10, 1000, 2000),
  expenditure = runif(10, 500, 1500)
)

 # Default summaries by country and year
compute_summary(data = df,
                cols = c("income", "expenditure"),
                groups = c("country", "year"),
                fns = "mean")
#> # A tibble: 8 × 4
#>   country  year indicator        value
#>   <chr>   <int> <chr>            <dbl>
#> 1 A        2020 income_mean      1589.
#> 2 A        2020 expenditure_mean  995.
#> 3 A        2021 income_mean      1469.
#> 4 A        2021 expenditure_mean 1034.
#> 5 B        2020 income_mean      1364.
#> 6 B        2020 expenditure_mean  930.
#> 7 B        2021 income_mean      1481.
#> 8 B        2021 expenditure_mean 1055.

 # Select specific functions
 compute_summary(data = df,
                cols = c("income"),
                groups = c("country"),
                fns = c("mean", "sd"),
                output = "wide")
#> # A tibble: 2 × 3
#>   country income_mean income_sd
#>   <chr>         <dbl>     <dbl>
#> 1 A             1541.      397.
#> 2 B             1434.      295.

 # Custom function
 compute_summary(df,
                cols = "income",
                groups = "country",
                fns = list("cv",
                           q90 = ~quantile(.x, 0.9, na.rm = TRUE)))
#> # A tibble: 4 × 3
#>   country indicator     value
#>   <chr>   <chr>         <dbl>
#> 1 A       income_cv     0.258
#> 2 A       income_q90 1885.   
#> 3 B       income_cv     0.206
#> 4 B       income_q90 1693.   
```
