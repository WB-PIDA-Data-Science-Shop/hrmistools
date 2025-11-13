# Compute Shares of Summary Indicators Relative to Macro Indicators

This function calculates the ratio (share) of summarized microdata
indicators to macro-level indicators (e.g., GDP, total population,
etc.). It automatically detects common join keys between the micro-level
summary and macro-level data, merges them, and computes the ratios for
all possible combinations of summarized and macro variables.

## Usage

``` r
compute_share(
  data,
  macro_data = macro_indicators,
  macro_cols,
  cols,
  groups,
  fns,
  output = c("long", "wide")
)
```

## Arguments

- data:

  A data frame containing the microdata to be summarized.

- macro_data:

  A data frame containing macro-level indicators. Defaults to
  `macro_indicators` if available in the environment.

- macro_cols:

  A character vector specifying the names of the macro indicator columns
  in `macro_data` to use for share computation.

- cols:

  A named list passed to
  [`compute_summary()`](https://wb-pida-data-science-shop.github.io/hrmistools/reference/compute_summary.md),
  specifying which variables to summarize (e.g.
  `list(vars = "varname")`).

- groups:

  A character vector specifying the grouping variables common to both
  datasets. Defaults to `c("country_code", "ref_date")`.

- fns:

  A list of summary functions passed to
  [`compute_summary()`](https://wb-pida-data-science-shop.github.io/hrmistools/reference/compute_summary.md),
  typically defined as formulas (e.g.
  `list(mean = ~mean(.x, na.rm = TRUE))`).

- output:

  Character string indicating the desired output format: `"long"`
  (default) for a tidy data frame with one row per share, or `"wide"`
  for a data frame with one column per computed indicator.

## Value

A data frame containing the computed ratios (shares). If
`output = "long"`, columns include:

- Grouping variables (e.g., `country_code`, `ref_date`)

- `macro_var`, `macro_value`

- `summary_var`, `summary_value`

- `indicator` – constructed name of the ratio

- `value` – computed share

If `output = "wide"`, each ratio indicator is returned as a separate
column.

## Details

The function proceeds in five steps:

1.  Summarizes the microdata using
    [`compute_summary()`](https://wb-pida-data-science-shop.github.io/hrmistools/reference/compute_summary.md).

2.  Automatically detects join keys shared between the summary and macro
    data.

3.  Merges the summarized and macro data on those join keys.

4.  Computes the ratio of each summarized indicator to each macro
    indicator.

5.  Formats the output as either long or wide form, depending on the
    `output` argument.

The output always includes the computed shares (e.g.
`employment_per_GDP`), as well as the underlying macro and summary
values used to compute them.

## See also

[`compute_summary`](https://wb-pida-data-science-shop.github.io/hrmistools/reference/compute_summary.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage
compute_share(data = contract_harmonized,
              macro_cols = c("gdp_lcu", "prevenue_lcu"),
              cols = c("gross_salary_lcu", "net_salary_lcu"),
              fns = c("mean", "sum"),
              output = "wide")
} # }
```
