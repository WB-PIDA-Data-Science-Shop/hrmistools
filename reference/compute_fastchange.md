# Calculate year-over-year growth for a numeric column (data.table version)

Computes the year-over-year growth rate for a numeric column in a
data.table. The function ensures a complete sequence of years between
the minimum and maximum in the date column, fills in any missing years,
and calculates the growth rate using lagged values.

## Usage

``` r
compute_fastchange(data, col, date_col)
```

## Arguments

- data:

  A data.table containing the data.

- col:

  A numeric column (either unquoted or as a string) for which the
  year-over-year growth rate will be calculated.

- date_col:

  A date or numeric column (either unquoted or as a string) used to
  order the data and define the time sequence (typically a year column).

## Value

A data.table with:

- The completed \`date_col\` sequence.

- A new column named \`"growth\_\<col\>"\` containing the year-over-year
  growth rates.

## Details

\- Missing years in the sequence are added automatically. - Missing
values in \`col\` result in \`NA\` for the corresponding growth rate. -
The first observation (or any row where the lag is missing) will have
\`NA\`. - The function can accept both unquoted column names or
strings. - To compute growth rates by group (e.g., country), subset or
loop by group before calling this function.

## Examples

``` r
library(data.table)

dt <- data.table(
  year = c(2020, 2021, 2023),
  gdp = c(100, 110, 130)
)


# Using strings
compute_fastchange(dt, "gdp", "year")
#> Key: <year>
#>     year   gdp gdp_growth
#>    <int> <num>      <num>
#> 1:  2020   100         NA
#> 2:  2021   110        0.1
#> 3:  2022    NA         NA
#> 4:  2023   130         NA
```
