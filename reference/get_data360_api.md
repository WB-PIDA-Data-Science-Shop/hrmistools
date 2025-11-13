# This function retrieves data from the Data360 API.

This function retrieves data from the Data360 API.

## Usage

``` r
get_data360_api(dataset_id, indicator_id, pivot = TRUE)
```

## Arguments

- dataset_id:

  Unique identifier for the database.

- indicator_id:

  Indicator ID. If a vector of indicators is provided, the query
  retrieves all indicators.

- pivot:

  Whether or not to pivot the extracted data. Default is true.

## Value

A tibble containing data, including country codes, country names, years,
and values.

## Examples

``` r
if (FALSE) { # \dontrun{
  cpi_data <- get_data360_api("WB_WDI", "WB_WDI_FP_CPI_TOTL")
  head(cpi_data)
} # }
```
