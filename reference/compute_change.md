# Compute Year-over-Year Growth for a Numeric Column

This function calculates the year-over-year growth rate for a specified
numeric column in a data frame or tibble. It automatically completes
missing time periods based on the range of the date column, ensuring
continuous sequences before computing growth. Growth is computed only
for consecutive years where both the current and previous values are
available. If a year is missing in the sequence, the growth for the next
available year is set to \`NA\`.

## Usage

``` r
compute_change(data, col, date_col)
```

## Arguments

- data:

  A data frame or tibble containing the variables of interest.

- col:

  The numeric column for which to compute growth (unquoted).

- date_col:

  The date or year column used to order and complete the data
  (unquoted).

## Value

A tibble containing the original columns plus a new column that holds
the computed year-over-year growth rates.

## Details

The function uses \`tidyr::complete()\` to fill missing time periods
between \`min(date_col)\` and \`max(date_col)\`, and \`dplyr::mutate()\`
to compute growth as: \$\$growth_t = \frac{x_t}{x\_{t-1}} - 1\$\$

However, growth is only computed when the difference between consecutive
periods equals 1 (i.e., consecutive years). If the time gap is greater
than one year, the growth value is set to \`NA\`.

## Examples

``` r
# Example data
df <- tibble::tibble(
  year = c(2020, 2021, 2023),
  gdp = c(100, 110, 130)
)

# Compute year-over-year growth
compute_change(df, gdp, year)
#> # A tibble: 4 × 3
#>    year   gdp gdp_growth
#>   <dbl> <dbl>      <dbl>
#> 1  2020   100     NA    
#> 2  2021   110      0.100
#> 3  2022    NA     NA    
#> 4  2023   130     NA    

```
