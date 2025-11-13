# Deduplicate values within grouped data

This function deduplicates values within groups defined by a combination
of identifier and date columns. It provides three strategies:

1.  `"mode"`: returns the most frequent (modal) value in the group.

2.  `"first"`: returns the first value in the group, even if `NA`.

3.  `"first_nonmissing"`: returns the first non-missing value in the
    group.

## Usage

``` r
dedup_values(
  data,
  id_col,
  date_col,
  value_col,
  method = c("mode", "first", "first_nonmissing")
)
```

## Arguments

- data:

  A data frame or tibble containing the data to deduplicate.

- id_col:

  Column name identifying the grouping unit (e.g., individual, firm).

- date_col:

  Column name identifying the date or time grouping variable.

- value_col:

  Column name containing the values to deduplicate.

- method:

  A string specifying the deduplication method. Must be one of `"mode"`,
  `"first"`, or `"first_nonmissing"`.

## Value

A tibble with one row per unique combination of `id_col` and `date_col`,
containing the deduplicated `value_col`.

## Details

For `method = "mode"`, ties are broken arbitrarily by selecting the
first encountered maximum. Missing values are ignored when computing the
mode.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:data.table’:
#> 
#>     between, first, last
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

df <- tibble(
  id = c(1,1,1, 2,2,2, 3,3,3),
  date = c("2020-01","2020-01","2020-01",
           "2020-02","2020-02","2020-02",
           "2021-01","2021-01","2021-01"),
  gender = c("M","M","F", NA,"F","M", "M","F",NA)
)

dedup_values(df, id, date, gender, method = "mode")
#> # A tibble: 3 × 3
#>      id date    gender
#>   <dbl> <chr>   <chr> 
#> 1     1 2020-01 M     
#> 2     2 2020-02 F     
#> 3     3 2021-01 F     
dedup_values(df, id, date, gender, method = "first")
#> # A tibble: 3 × 3
#>      id date    gender
#>   <dbl> <chr>   <chr> 
#> 1     1 2020-01 M     
#> 2     2 2020-02 NA    
#> 3     3 2021-01 M     
dedup_values(df, id, date, gender, method = "first_nonmissing")
#> # A tibble: 3 × 3
#>      id date    gender
#>   <dbl> <chr>   <chr> 
#> 1     1 2020-01 M     
#> 2     2 2020-02 F     
#> 3     3 2021-01 M     
```
