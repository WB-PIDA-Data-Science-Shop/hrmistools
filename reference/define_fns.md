# Define Default Summary Functions

Creates and returns a named list of default summary functions used
throughout the analytics framework (e.g., by \[compute_summary()\]).
Each function is defined as a purrr-style formula (\`~\`) that operates
on a vector \`.x\` and returns a scalar summary statistic. The returned
list can be supplied directly to a summarization pipeline or extended by
users with custom functions.

## Usage

``` r
define_fns()
```

## Format

The list includes the following summary functions:

- sum:

  Sum of values, ignoring \`NA\`s.

- mean:

  Arithmetic mean.

- median:

  Median value.

- cv:

  Coefficient of variation (requires a \`cv()\` helper).

- cp_ratio:

  Custom "cp ratio" statistic (requires a \`cp_ratio()\` helper).

- var:

  Sample variance.

- iqr:

  Interquartile range, computed as \`diff(range(.x))\`.

- min:

  Minimum value.

- max:

  Maximum value.

- count:

  Number of observations.

- count_unique:

  Number of distinct (unique) values.

- prop_na:

  Proportion of missing (\`NA\`) values.

- prop_zero:

  Proportion of zero values among non-missing data.

- p25:

  25th percentile (first quartile).

- p75:

  75th percentile (third quartile).

- p90:

  90th percentile.

- sd:

  Standard deviation.

## Value

A named list of formula functions suitable for use with
\`dplyr::across()\`, where each element name is the function label and
the value is a one-sided formula that computes the summary.

## Details

The returned list contains commonly used descriptive statistics for
numeric vectors, including measures of central tendency, dispersion,
distribution, and data quality (e.g., share of missing or zero values).
Users can extend or override the defaults by appending their own named
formulas before passing to \[compute_summary()\].

## See also

\[compute_summary()\], \[compute_share()\]

## Examples

``` r
# Load the default function set
fns <- define_fns()

# Inspect available summaries
names(fns)
#>  [1] "sum"          "mean"         "median"       "cv"           "cp_ratio"    
#>  [6] "var"          "iqr"          "min"          "max"          "count"       
#> [11] "prop"         "dtprop"       "count_unique" "prop_na"      "prop_zero"   
#> [16] "p25"          "p75"          "p90"          "sd"          

# Example usage with compute_summary()
compute_summary(
  data = contract_harmonized,
  cols = c("gross_salary_lcu", "net_salary_lcu"),
  groups = c("country_code"),
  fns = c("mean", "sd", "cv")
)
#> # A tibble: 6 × 3
#>   country_code indicator                value
#>   <chr>        <chr>                    <dbl>
#> 1 ZMB          gross_salary_lcu_mean 5321.   
#> 2 ZMB          gross_salary_lcu_sd    880.   
#> 3 ZMB          gross_salary_lcu_cv      0.165
#> 4 ZMB          net_salary_lcu_mean   4312.   
#> 5 ZMB          net_salary_lcu_sd      764.   
#> 6 ZMB          net_salary_lcu_cv        0.177
```
